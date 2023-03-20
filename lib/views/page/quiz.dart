import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:side_sheet/side_sheet.dart';

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
      builder: (context, AsyncSnapshot<List<Quiz>> snapshot) {
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
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) =>
                  [_buildAppBar(context)],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchQuizzes(),
                child: filteredQuizzes.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      KIcons.quiz,
                                      size: 48.0,
                                    ),
                                  ),
                                  Text(
                                    '小テストはありません',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _searchStatus
                            ? _suggestQuizzes.length
                            : filteredQuizzes.length,
                        itemBuilder: (context, index) => _searchStatus
                            ? _buildCard(context, _suggestQuizzes[index])
                            : _buildCard(context, filteredQuizzes[index]),
                      ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
                  icon:
                      Icon(_filterStatus ? KIcons.filterOn : KIcons.filterOff),
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
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCard(BuildContext context, Quiz quiz) {
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
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
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
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: KIcons.update,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (quiz.isAcquired) {
            MediaQuery.of(context).orientation == Orientation.portrait
                ? showModalBottomSheet(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    isScrollControlled: false,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(0.0))),
                    context: context,
                    builder: (context) => buildQuizModal(context, quiz),
                  )
                : SideSheet.right(
                    sheetColor: Theme.of(context).colorScheme.surface,
                    body: SizedBox(
                      width: MediaQuery.of(context).size.width * .6,
                      child: buildQuizModal(context, quiz),
                    ),
                    context: context,
                  );
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
                : null;
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
                quiz.subject,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              quiz.endDateTime.toLocal().toDetailString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                quiz.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

Widget buildQuizModal(BuildContext context, Quiz quiz) {
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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(LineIcons.arrowRight),
            Text(
              quiz.endDateTime.toLocal().toDetailString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 4.0,
              ),
              child: Text(
                quiz.status,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 4.0,
              ),
              child: Text(
                quiz.isSubmitted ? '提出済' : '未提出',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
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
        child: buildAutoLinkText(
          context,
          quiz.isAcquired ? quiz.description : '未取得',
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          quiz.isAcquired ? quiz.message : '未取得',
        ),
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
            child: Container(
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
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () async =>
                    context.read<ApiRepository>().fetchDetailQuiz(quiz),
                child: Icon(KIcons.update),
              ),
            ),
          ),
          Expanded(
            child: Container(
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
}
