import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/provide.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _searchStatus = false;
  bool _filterStatus = false;
  List<Quiz> _suggestQuizzes = [];

  @override
  Widget build(BuildContext context) {
    final List<Quiz> quizzes = context
        .watch<ApiProvider>()
        .api
        .quizzes
        .where((e) => _filterStatus
            ? !(e.isArchived ||
                !(!e.isSubmitted && e.endDateTime.isAfter(DateTime.now())))
            : true)
        .toList();
    quizzes.sort(((a, b) => b.compareTo(a)));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          quizzes.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.beach_access_rounded,
                            size: 48.0,
                          ),
                        ),
                        Text(
                          'タスクはありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: _searchStatus
                        ? SliverChildBuilderDelegate(
                            (_, index) =>
                                _buildCard(context, _suggestQuizzes[index]),
                            childCount: _suggestQuizzes.length,
                          )
                        : SliverChildBuilderDelegate(
                            (_, index) => _buildCard(context, quizzes[index]),
                            childCount: quizzes.length,
                          ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      title: _searchStatus
          ? TextField(
              onChanged: (value) {
                setState(() {
                  _suggestQuizzes = context
                      .read<ApiProvider>()
                      .api
                      .quizzes
                      .where((e) => e.title.contains(value))
                      .toList();
                });
              },
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : const Text('小テスト'),
      actions: _searchStatus
          ? [
              IconButton(
                onPressed: (() {
                  setState(() {
                    _searchStatus = false;
                  });
                }),
                icon: const Icon(Icons.close),
              ),
            ]
          : [
              IconButton(
                onPressed: (() {
                  setState(() {
                    _filterStatus = !_filterStatus;
                  });
                }),
                icon: Icon(
                    _filterStatus ? Icons.filter_alt : Icons.filter_alt_off),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: (() {
                    setState(() {
                      _searchStatus = true;
                      _suggestQuizzes = [];
                    });
                  }),
                  icon: const Icon(Icons.search),
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
            onPressed: ((context) {
              context
                  .read<ApiProvider>()
                  .setArchiveQuiz(quiz.id, !quiz.isArchived);
            }),
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: quiz.isArchived ? Icons.unarchive : Icons.archive,
            label: quiz.isArchived ? 'アーカイブ解除' : 'アーカイブ',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async =>
                context.read<ApiProvider>().fetchDetailQuiz(quiz),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.sync,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () => showModalBottomSheet(
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
          context: context,
          builder: (context) => DraggableScrollableSheet(
            expand: false,
            builder: (context, controller) {
              return _buildModal(quiz, controller);
            },
          ),
        ),
        leading: Icon(
          (() {
            if (quiz.isSubmitted) {
              if (quiz.endDateTime.isAfter(DateTime.now())) {
                return Icons.check_box_outlined;
              } else {
                return Icons.check_box_rounded;
              }
            } else {
              if (quiz.endDateTime.isAfter(DateTime.now())) {
                return Icons.crop_square_outlined;
              } else {
                return Icons.square_rounded;
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
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(quiz.endDateTime.toLocal()),
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
              ),
            ),
            Visibility(
              visible: quiz.isArchived,
              child: const Icon(Icons.archive_outlined),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModal(Quiz quiz, ScrollController controller) {
    return ListView(
      controller: controller,
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
                DateFormat('yyyy/MM/dd HH:mm', 'ja')
                    .format(quiz.startDateTime.toLocal()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Icon(Icons.arrow_right_alt_rounded),
              Text(
                DateFormat('yyyy/MM/dd HH:mm', 'ja')
                    .format(quiz.endDateTime.toLocal()),
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
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.archive_outlined),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            quiz.isAcquired ? quiz.description : '未取得',
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            quiz.isAcquired ? quiz.message : '未取得',
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
                        .read<ApiProvider>()
                        .setArchiveQuiz(quiz.id, !quiz.isArchived);
                    Navigator.of(context).pop();
                  },
                  child: Icon(quiz.isArchived
                      ? Icons.unarchive_rounded
                      : Icons.archive_rounded),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async =>
                      context.read<ApiProvider>().fetchDetailQuiz(quiz),
                  child: const Icon(Icons.sync_rounded),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.share_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
