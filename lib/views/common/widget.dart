import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
