import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_gui/api/parse.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:gakujo_gui/models/questionnaire.dart';
import 'package:gakujo_gui/views/common/widget.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({Key? key}) : super(key: key);

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  bool _searchStatus = false;
  bool _filterStatus = false;
  List<Questionnaire> _questionnaires = [];
  List<Questionnaire> _suggestQuestionnaires = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<QuestionnaireRepository>().getAll(),
      builder: (_, AsyncSnapshot<List<Questionnaire>> snapshot) {
        if (snapshot.hasData) {
          _questionnaires = snapshot.data!;
          _questionnaires.sort(((a, b) => b.compareTo(a)));
          var filteredQuestionnaires = _questionnaires
              .where((e) => _filterStatus
                  ? !(e.isArchived ||
                      !(!e.isSubmitted &&
                          e.endDateTime.isAfter(DateTime.now())))
                  : true)
              .toList();
          return Scaffold(
            floatingActionButton: buildFloatingActionButton(
              onPressed: context.read<ApiRepository>().fetchQuestionnaires,
              iconData: KIcons.update,
            ),
            body: NestedScrollView(
              headerSliverBuilder: (_, __) => [_buildAppBar()],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchClassLinks(),
                child: filteredQuestionnaires.isEmpty
                    ? buildCenterItemLayoutBuilder(
                        KIcons.questionnaire, '授業アンケートはありません')
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8.0),
                        itemCount: _searchStatus
                            ? _suggestQuestionnaires.length
                            : _questionnaires.length,
                        itemBuilder: (_, index) => _searchStatus
                            ? _buildCard(_suggestQuestionnaires[index])
                            : _buildCard(_questionnaires[index]),
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
                onChanged: (value) => setState(() => _suggestQuestionnaires =
                    _questionnaires.where((e) => e.contains(value)).toList()),
                autofocus: true,
                textInputAction: TextInputAction.search,
              )
            : const Text('授業アンケート'),
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
                          _suggestQuestionnaires = [];
                        })),
                    icon: Icon(KIcons.search),
                  ),
                ),
              ],
        bottom: buildAppBarBottom(),
      );
    });
  }

  Widget _buildCard(Questionnaire questionnaire) {
    return Builder(builder: (context) {
      return Slidable(
        key: Key(questionnaire.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => context
                  .read<QuestionnaireRepository>()
                  .setArchive(questionnaire.id, !questionnaire.isArchived)
                  .then((value) => setState(() {})),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon:
                  questionnaire.isArchived ? KIcons.unarchive : KIcons.archive,
              label: questionnaire.isArchived ? 'アーカイブ解除' : 'アーカイブ',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async => context
                  .read<ApiRepository>()
                  .fetchDetailQuestionnaire(questionnaire),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: KIcons.update,
              label: '更新',
            ),
          ],
        ),
        child: ListTile(
          onTap: () async {
            if (questionnaire.isAcquired) {
              showModalOnTap(context, buildQuestionnaireModal(questionnaire));
            } else {
              await showOkCancelAlertDialog(
                        context: context,
                        title: '取得しますか？',
                        message: '未取得の授業アンケートです。取得するためにはログイン状態である必要があります。',
                        okLabel: '取得',
                        cancelLabel: 'キャンセル',
                      ) ==
                      OkCancelResult.ok
                  ? context
                      .read<ApiRepository>()
                      .fetchDetailQuestionnaire(questionnaire)
                  : showModalOnTap(
                      context, buildQuestionnaireModal(questionnaire));
            }
          },
          leading: Icon(
            (() {
              if (questionnaire.isSubmitted) {
                if (questionnaire.endDateTime.isAfter(DateTime.now())) {
                  return KIcons.checkedAfter;
                } else {
                  return KIcons.checkedBefore;
                }
              } else {
                if (questionnaire.endDateTime.isAfter(DateTime.now())) {
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
                  questionnaire.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Visibility(
                visible: questionnaire.fileNames?.isNotEmpty ?? false,
                child: Text(
                  '${questionnaire.fileNames?.length ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Visibility(
                visible: questionnaire.fileNames?.isNotEmpty ?? false,
                child: Icon(KIcons.attachment),
              ),
              Visibility(
                visible: questionnaire.isArchived,
                child: Icon(KIcons.archive),
              )
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  questionnaire.subject,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                questionnaire.endDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: (() {
                    if (!questionnaire.isSubmitted &&
                        questionnaire.endDateTime.isBefore(
                            DateTime.now().add(const Duration(days: 1)))) {
                      return Theme.of(context).colorScheme.error;
                    }
                    return Theme.of(context).textTheme.bodySmall!.color;
                  })(),
                  fontWeight: (() {
                    if (!questionnaire.isSubmitted &&
                        questionnaire.endDateTime.isBefore(
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

Widget buildQuestionnaireModal(Questionnaire questionnaire) {
  return Builder(builder: (context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              questionnaire.title,
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
                questionnaire.startDateTime.toLocal().toDateTimeString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '-',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                questionnaire.endDateTime.toLocal().toDateTimeString(),
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
              buildRadiusBadge(questionnaire.status),
              buildRadiusBadge(questionnaire.isSubmitted ? '提出済' : '未提出'),
              Visibility(
                visible: questionnaire.isArchived,
                child: Icon(KIcons.archive),
              )
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(
              questionnaire.isAcquired ? questionnaire.description : '未取得'),
        ),
        const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(
              questionnaire.isAcquired ? questionnaire.message : '未取得'),
        ),
        Visibility(
          visible: questionnaire.fileNames?.isNotEmpty ?? false,
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Divider(thickness: 2.0),
          ),
        ),
        Visibility(
          visible: questionnaire.fileNames?.isNotEmpty ?? false,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: buildFileList(questionnaire.fileNames),
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
                    context.read<QuestionnaireRepository>().setArchive(
                        questionnaire.id, !questionnaire.isArchived);
                    Navigator.of(context).pop();
                  },
                  child: Icon(questionnaire.isArchived
                      ? KIcons.unarchive
                      : KIcons.archive),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () async => context
                      .read<ApiRepository>()
                      .fetchDetailQuestionnaire(questionnaire),
                  child: Icon(KIcons.update),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () => Share.share(
                      '${questionnaire.description}\n\n${questionnaire.message}',
                      subject: questionnaire.title),
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
