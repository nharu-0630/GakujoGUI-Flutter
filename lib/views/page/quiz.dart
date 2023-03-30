import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _searchStatus = false;
  bool _filterStatus = false;
  List<Quiz> _quizzes = [];
  List<Quiz> _suggestQuizzes = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<QuizRepository>().getAll(),
      builder: (_, AsyncSnapshot<List<Quiz>> snapshot) {
        if (snapshot.hasData) {
          _quizzes = snapshot.data!;
          _quizzes.sort(((a, b) => b.compareTo(a)));
          var filteredQuizzes = _quizzes
              .where((e) => _filterStatus
                  ? !(e.isArchived ||
                      !(!e.isSubmitted &&
                          e.endDateTime.isAfter(DateTime.now())))
                  : true)
              .toList();
          return Scaffold(
            floatingActionButton: buildFloatingActionButton(
              onPressed: context.read<ApiRepository>().fetchQuizzes,
              iconData: KIcons.update,
            ),
            body: NestedScrollView(
              headerSliverBuilder: (_, __) => [_buildAppBar()],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchQuizzes(),
                child: filteredQuizzes.isEmpty
                    ? buildCenterItemLayoutBuilder(KIcons.quiz, '小テストはありません')
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _searchStatus
                            ? _suggestQuizzes.length
                            : filteredQuizzes.length,
                        itemBuilder: (_, index) => _searchStatus
                            ? _buildCard(_suggestQuizzes[index])
                            : _buildCard(filteredQuizzes[index]),
                      ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildAppBar() {
    return Builder(builder: (context) {
      return SliverAppBar(
        centerTitle: true,
        floating: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(KIcons.back),
          ),
        ),
        title: _searchStatus
            ? TextField(
                onChanged: (value) => setState(() => _suggestQuizzes =
                    _quizzes.where((e) => e.contains(value)).toList()),
                autofocus: true,
                textInputAction: TextInputAction.search,
              )
            : const Text('小テスト'),
        actions: _searchStatus
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: (() => setState(() => _searchStatus = false)),
                    icon: Icon(KIcons.close),
                  ),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: (() =>
                        setState(() => _filterStatus = !_filterStatus)),
                    icon: Icon(
                        _filterStatus ? KIcons.filterOn : KIcons.filterOff),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: (() => setState(() {
                          _searchStatus = true;
                          _suggestQuizzes = [];
                        })),
                    icon: Icon(KIcons.search),
                  ),
                ),
              ],
        bottom: buildAppBarBottom(),
      );
    });
  }

  Widget _buildCard(Quiz quiz) {
    return Builder(builder: (context) {
      return Slidable(
        key: Key(quiz.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => context
                  .read<QuizRepository>()
                  .setArchive(quiz.id, !quiz.isArchived)
                  .then((value) => setState(() {})),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: quiz.isArchived ? KIcons.unarchive : KIcons.archive,
              label: quiz.isArchived ? 'アーカイブ解除' : 'アーカイブ',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async =>
                  context.read<ApiRepository>().fetchDetailQuiz(quiz),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: KIcons.update,
              label: '更新',
            ),
          ],
        ),
        child: ListTile(
          onTap: () async {
            if (quiz.isAcquired) {
              showModalOnTap(context, buildQuizModal(quiz));
            } else {
              await showOkCancelAlertDialog(
                        context: context,
                        title: '未取得の小テストです。',
                        message: '取得しますか？',
                        okLabel: '取得',
                        cancelLabel: 'キャンセル',
                      ) ==
                      OkCancelResult.ok
                  ? context.read<ApiRepository>().fetchDetailQuiz(quiz)
                  : showModalOnTap(context, buildQuizModal(quiz));
            }
          },
          leading: Icon(
            (() {
              if (quiz.isSubmitted) {
                if (quiz.endDateTime.isAfter(DateTime.now())) {
                  return KIcons.checkedAfter;
                } else {
                  return KIcons.checkedBefore;
                }
              } else {
                if (quiz.endDateTime.isAfter(DateTime.now())) {
                  return KIcons.uncheckedAfter;
                } else {
                  return KIcons.uncheckedBefore;
                }
              }
            })(),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Visibility(
                visible: quiz.fileNames?.isNotEmpty ?? false,
                child: Text(
                  '${quiz.fileNames?.length ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Visibility(
                visible: quiz.fileNames?.isNotEmpty ?? false,
                child: Icon(KIcons.attachment),
              ),
              Visibility(
                visible: quiz.isArchived,
                child: Icon(KIcons.archive),
              )
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quiz.subject,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                quiz.endDateTime.toLocal().toDetailString(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: (() {
                    if (!quiz.isSubmitted &&
                        quiz.endDateTime.isBefore(
                            DateTime.now().add(const Duration(days: 1)))) {
                      return Theme.of(context).colorScheme.error;
                    }
                    return Theme.of(context).textTheme.bodySmall!.color;
                  })(),
                  fontWeight: (() {
                    if (!quiz.isSubmitted &&
                        quiz.endDateTime.isBefore(
                            DateTime.now().add(const Duration(days: 1)))) {
                      return FontWeight.bold;
                    }
                    return FontWeight.normal;
                  })(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

Widget buildQuizModal(Quiz quiz) {
  return Builder(builder: (context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              quiz.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                quiz.startDateTime.toLocal().toDetailString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '-',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                quiz.endDateTime.toLocal().toDetailString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildRadiusBadge(quiz.status),
              buildRadiusBadge(quiz.isSubmitted ? '提出済' : '未提出'),
              Visibility(
                visible: quiz.isArchived,
                child: Icon(KIcons.archive),
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(quiz.isAcquired ? quiz.description : '未取得'),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(quiz.isAcquired ? quiz.message : '未取得'),
        ),
        Visibility(
          visible: quiz.fileNames?.isNotEmpty ?? false,
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Divider(thickness: 2.0),
          ),
        ),
        Visibility(
          visible: quiz.fileNames?.isNotEmpty ?? false,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: buildFileList(quiz.fileNames),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<QuizRepository>()
                        .setArchive(quiz.id, !quiz.isArchived);
                    Navigator.of(context).pop();
                  },
                  child:
                      Icon(quiz.isArchived ? KIcons.unarchive : KIcons.archive),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async =>
                      context.read<ApiRepository>().fetchDetailQuiz(quiz),
                  child: Icon(KIcons.update),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () => Share.share(
                      '${quiz.description}\n\n${quiz.message}',
                      subject: quiz.title),
                  child: Icon(KIcons.share),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  });
}
