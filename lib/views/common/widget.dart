import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/shared_file.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

ListView buildFileList(List<String>? fileNames) {
  return ListView.builder(
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

SelectableAutoLinkText buildAutoLinkText(BuildContext context, String text) {
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
        child: SelectableText(
          quiz.isAcquired ? quiz.description : '未取得',
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SelectableText(
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
        child: SelectableText(
          report.isAcquired ? report.description : '未取得',
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SelectableText(
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              sharedFile.publicPeriod,
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
        child: SelectableText(
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
