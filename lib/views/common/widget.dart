import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:cached_memory_image/provider/cached_memory_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/models/class_link.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/models/shared_file.dart';
import 'package:gakujo_task/models/timetable.dart';
import 'package:gakujo_task/views/page/class_link.dart';
import 'package:gakujo_task/views/page/grade.dart';
import 'package:gakujo_task/views/page/quiz.dart';
import 'package:gakujo_task/views/page/report.dart';
import 'package:gakujo_task/views/page/shared_file.dart';
import 'package:gakujo_task/views/settings/settings.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

ListView buildFileList(List<String>? fileNames,
    {Axis scrollDirection = Axis.vertical}) {
  return ListView.builder(
    scrollDirection: scrollDirection,
    padding: const EdgeInsets.all(0.0),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: fileNames?.length ?? 0,
    itemBuilder: (context, index) {
      return ListTile(
        title: Row(
          children: [
            _buildExtIcon(p.extension(fileNames![index]).replaceFirst('.', '')),
            const SizedBox(width: 8.0),
            Text(p.basename(fileNames[index])),
          ],
        ),
        onTap: () async => _openFile(fileNames[index]),
      );
    },
  );
}

void _openFile(String filename) async {
  var path = p.join((await getApplicationDocumentsDirectory()).path, filename);
  if (File(path).existsSync()) {
    OpenFile.open(path);
  } else {
    Fluttertoast.showToast(
      msg: 'Not exist file.',
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 5,
    );
  }
}

Icon _buildExtIcon(String ext) {
  switch (ext) {
    case 'pdf':
      return const Icon(FontAwesomeIcons.filePdf);
    case 'doc':
    case 'docx':
      return const Icon(FontAwesomeIcons.fileWord);
    case 'xls':
    case 'xlsx':
      return const Icon(FontAwesomeIcons.fileExcel);
    case 'ppt':
    case 'pptx':
      return const Icon(FontAwesomeIcons.filePowerpoint);
    case 'zip':
    case 'rar':
      return const Icon(FontAwesomeIcons.fileZipper);
    case 'csv':
      return const Icon(FontAwesomeIcons.fileCsv);
    case 'txt':
      return const Icon(FontAwesomeIcons.fileLines);
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return const Icon(FontAwesomeIcons.fileImage);
    case 'mp4':
    case 'mov':
      return const Icon(FontAwesomeIcons.fileVideo);
    case 'mp3':
    case 'wav':
      return const Icon(FontAwesomeIcons.fileAudio);
    default:
      return const Icon(FontAwesomeIcons.file);
  }
}

Widget buildAutoLinkText(BuildContext context, String text) {
  return SelectableAutoLinkText(
    text,
    style: Theme.of(context).textTheme.bodyMedium,
    linkStyle: const TextStyle(color: Colors.blueAccent),
    onTap: (url) => launchUrlString(url, mode: LaunchMode.inAppWebView),
    onLongPress: (url) => Share.share(url),
    linkRegExpPattern:
        r'https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
  );
}

Widget buildQuizModal(
    BuildContext context, Quiz quiz, ScrollController controller) {
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
              child: const Icon(Icons.archive_rounded),
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
                    context.read<ApiRepository>().fetchDetailQuiz(quiz),
                child: const Icon(Icons.sync_rounded),
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

Widget buildReportModal(
    BuildContext context, Report report, ScrollController controller) {
  return ListView(
    controller: controller,
    padding: const EdgeInsets.all(16.0),
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            report.title,
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
                  .format(report.startDateTime.toLocal()),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.arrow_right_alt_rounded),
            Text(
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(report.endDateTime.toLocal()),
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
                report.status,
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
                report.isSubmitted
                    ? '提出済 ${DateFormat('yyyy/MM/dd HH:mm', 'ja').format(report.submittedDateTime.toLocal())}'
                    : '未提出',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Visibility(
              visible: report.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          report.isAcquired ? report.description : '未取得',
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
          report.isAcquired ? report.message : '未取得',
        ),
      ),
      Visibility(
        visible: report.fileNames?.isNotEmpty ?? false,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
      ),
      Visibility(
        visible: report.fileNames?.isNotEmpty ?? false,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildFileList(report.fileNames),
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
                      .read<ReportRepository>()
                      .setArchive(report.id, !report.isArchived);
                  Navigator.of(context).pop();
                },
                child: Icon(report.isArchived
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
                    context.read<ApiRepository>().fetchDetailReport(report),
                child: const Icon(Icons.sync_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => Share.share(
                    '${report.description}\n\n${report.message}',
                    subject: report.title),
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

Widget buildSharedFileModal(
    BuildContext context, SharedFile sharedFile, ScrollController controller) {
  return ListView(
    controller: controller,
    padding: const EdgeInsets.all(16.0),
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            sharedFile.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: sharedFile.publicPeriod.isNotEmpty,
              child: Container(
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
                  sharedFile.publicPeriod,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
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
                sharedFile.fileSize,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Visibility(
              visible: sharedFile.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          sharedFile.isAcquired ? sharedFile.description : '未取得',
        ),
      ),
      Visibility(
        visible: sharedFile.fileNames?.isNotEmpty ?? false,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
      ),
      Visibility(
        visible: sharedFile.fileNames?.isNotEmpty ?? false,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildFileList(sharedFile.fileNames),
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
                  context.read<SharedFileRepository>().setArchive(
                      sharedFile.hashCode.toString(), !sharedFile.isArchived);
                  Navigator.of(context).pop();
                },
                child: Icon(sharedFile.isArchived
                    ? Icons.unarchive_rounded
                    : Icons.archive_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () async => context
                    .read<ApiRepository>()
                    .fetchDetailSharedFile(sharedFile),
                child: const Icon(Icons.sync_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => Share.share(sharedFile.description,
                    subject: sharedFile.title),
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

Widget buildClassLinkModal(
    BuildContext context, ClassLink classLink, ScrollController controller) {
  return ListView(
    controller: controller,
    padding: const EdgeInsets.all(16.0),
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            classLink.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Visibility(
              visible: classLink.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          classLink.comment,
        ),
      ),
      Visibility(
        visible: classLink.isAcquired,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
      ),
      Visibility(
        visible: classLink.isAcquired,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(
            context,
            classLink.link,
          ),
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
                      .read<ClassLinkRepository>()
                      .setArchive(classLink.id, !classLink.isArchived);
                  Navigator.of(context).pop();
                },
                child: Icon(classLink.isArchived
                    ? Icons.unarchive_rounded
                    : Icons.archive_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () async => context
                    .read<ApiRepository>()
                    .fetchDetailClassLink(classLink),
                child: const Icon(Icons.sync_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => Share.share(
                    '${classLink.comment}\n\n${classLink.link}',
                    subject: classLink.title),
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

Widget buildTimetableModal(
    BuildContext context, Timetable timetable, ScrollController controller) {
  return ListView(
    controller: controller,
    padding: const EdgeInsets.all(16.0),
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          timetable.subject,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.category_rounded),
            const SizedBox(width: 8.0),
            Text(
              timetable.className,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 16.0),
            const Icon(Icons.pin_drop_rounded),
            const SizedBox(width: 8.0),
            Text(
              timetable.classRoom,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 16.0),
            const Icon(Icons.person_rounded),
            const SizedBox(width: 8.0),
            Text(
              timetable.teacher,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                '担当教員名',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusTeacher),
            ],
          ),
          Column(
            children: [
              Text(
                '所属等',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusAffiliation),
            ],
          ),
          Column(
            children: [
              Text(
                '研究室',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusResearchRoom),
            ],
          ),
          Column(
            children: [
              Text(
                '分担教員名',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusSharingTeacher),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                'クラス',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusClassName),
            ],
          ),
          Column(
            children: [
              Text(
                '学期',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusSemesterName),
            ],
          ),
          Column(
            children: [
              Text(
                '必修選択区分',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusSelectionSection),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                '対象学年',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusTargetGrade),
            ],
          ),
          Column(
            children: [
              Text(
                '単位数',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusCredit),
            ],
          ),
          Column(
            children: [
              Text(
                '曜日・時限',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusWeekdayPeriod),
            ],
          ),
          Column(
            children: [
              Text(
                '教室',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(timetable.syllabusClassRoom),
            ],
          ),
        ],
      ),
      Text(
        'キーワード',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusKeyword,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '授業の目標',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusClassTarget,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '学習内容',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusLearningDetail,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '授業計画',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusClassPlan,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'テキスト',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTextbook,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '参考書',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusReferenceBook,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '予習・復習について',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusPreparationReview,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '成績評価の方法･基準',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusEvaluationMethod,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'オフィスアワー',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusOfficeHour,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '担当教員からのメッセージ',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusMessage,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'アクティブ・ラーニング',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusActiveLearning,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '実務経験のある教員の有無',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTeacherPracticalExperience,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '実務経験のある教員の経歴と授業内容',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTeacherCareerClassDetail,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '教職科目区分',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusTeachingProfessionSection,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '関連授業科目',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusRelatedClassSubjects,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        'その他',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusOther,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '在宅授業形態',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusHomeClassStyle,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(
        '在宅授業形態（詳細）',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          timetable.syllabusHomeClassStyleDetail,
        ),
      ),
      const SizedBox(height: 8.0),
    ],
  );
}

Widget buildDrawer(BuildContext context) {
  return FutureBuilder(
      future: Future.wait([
        context.watch<SettingsRepository>().load(),
        context.watch<ReportRepository>().getAll(),
        context.watch<QuizRepository>().getAll()
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        return Drawer(
          child: ListView(
            children: [
              SizedBox(
                child: DrawerHeader(
                  child: Column(
                    children: [
                      Text(
                        'GakujoTask',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16.0),
                      snapshot.hasData
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.lock_clock_rounded),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      DateFormat('yyyy/MM/dd HH:mm', 'ja')
                                          .format(
                                              snapshot.data![0].lastLoginTime),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.person_rounded),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      snapshot.data![0].username ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.security_rounded),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      snapshot.data![0].accessEnvironmentName ??
                                          '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(Icons.text_snippet_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      'レポート',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Expanded(child: SizedBox()),
                    snapshot.hasData
                        ? Text(
                            snapshot.data![1]
                                .where((e) => !(e.isArchived ||
                                    !(!e.isSubmitted &&
                                        e.endDateTime.isAfter(DateTime.now()))))
                                .length
                                .toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ReportPage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(Icons.checklist_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      '小テスト',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Expanded(child: SizedBox()),
                    snapshot.hasData
                        ? Text(
                            snapshot.data![2]
                                .where((e) => !(e.isArchived ||
                                    !(!e.isSubmitted &&
                                        e.endDateTime.isAfter(DateTime.now()))))
                                .length
                                .toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        : const SizedBox.shrink()
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const QuizPage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(Icons.folder_shared_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      '授業共有ファイル',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SharedFilePage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(Icons.link_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      '授業リンク',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ClassLinkPage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(Icons.school_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      '成績情報',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const GradePage()));
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    const Icon(Icons.settings_rounded),
                    const SizedBox(width: 8.0),
                    Text(
                      '設定',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsWidget()));
                },
              ),
            ],
          ),
        );
      });
}

AppBar buildAppBar(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
  return AppBar(
    leading: FutureBuilder(
      future: context.watch<SettingsRepository>().load(),
      builder: (context, AsyncSnapshot<Settings> snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    child: snapshot.data?.profileImage == null
                        ? const Icon(
                            Icons.person_rounded,
                            size: 36.0,
                          )
                        : CircleAvatar(
                            backgroundImage: CachedMemoryImageProvider(
                              'ProfileImage',
                              base64: snapshot.data?.profileImage,
                            ),
                          ),
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    ),
    centerTitle: false,
    title: FutureBuilder(
      future: context.watch<SettingsRepository>().load(),
      builder: (context, AsyncSnapshot<Settings> snapshot) {
        if (snapshot.hasData) {
          return Row(
            children: [
              Text(
                snapshot.data?.fullName == null
                    ? 'Hi!'
                    : 'Hi, ${snapshot.data?.fullName}!',
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.login_rounded),
                onPressed: () async =>
                    context.read<ApiRepository>().fetchLogin(),
              ),
              IconButton(
                icon: const Icon(Icons.sync_rounded),
                onPressed: () async => showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text('更新'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchSubjects(),
                          child: const Text('授業科目'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchContacts(),
                          child: const Text('授業連絡'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchReports(),
                          child: const Text('レポート'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchQuizzes(),
                          child: const Text('小テスト'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchSharedFiles(),
                          child: const Text('授業共有ファイル'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchClassLinks(),
                          child: const Text('授業リンク'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchGrades(),
                          child: const Text('成績情報'),
                        ),
                        SimpleDialogOption(
                          onPressed: () async =>
                              context.read<ApiRepository>().fetchTimetables(),
                          child: const Text('個人時間割'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    ),
    bottom: buildAppBarBottom(context),
  );
}

PreferredSize buildAppBarBottom(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(6.0),
    child: Visibility(
      visible: context.watch<ApiRepository>().isLoading,
      child: LinearProgressIndicator(
        minHeight: 3.0,
        valueColor: context.watch<ApiRepository>().isError
            ? AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.error)
            : AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
      ),
    ),
  );
}
