import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/constants/kicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:url_launcher/url_launcher_string.dart';

Widget? buildFloatingActionButton({
  required Function() onPressed,
  required IconData iconData,
}) {
  return (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
      ? FloatingActionButton(
          onPressed: () async => onPressed(),
          child: Icon(iconData),
        )
      : null;
}

Widget buildElevatedButton({
  required Function() onPressed,
  required String text,
  required IconData iconData,
  bool isDestructiveAction = false,
}) {
  return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: isDestructiveAction
            ? ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              )
            : ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
        onPressed: () async => onPressed(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData),
              const SizedBox(width: 8.0),
              Text(
                text,
                style: isDestructiveAction
                    ? Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.onError)
                    : Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  });
}

void showModalOnTap(BuildContext context, Widget widget) {
  MediaQuery.of(context).orientation == Orientation.portrait
      ? showModalBottomSheet(
          backgroundColor: Theme.of(context).colorScheme.surface,
          isScrollControlled: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.zero)),
          context: context,
          builder: (_) => widget,
        )
      : SideSheet.right(
          sheetColor: Theme.of(context).colorScheme.surface,
          body: SizedBox(
            width: MediaQuery.of(context).size.width * .6,
            child: widget,
          ),
          context: context,
        );
}

Widget buildIconItem(IconData iconData, String text) {
  return Builder(builder: (context) {
    return Column(
      children: [
        Icon(iconData),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  });
}

Widget buildShortItem(String title, String body) {
  return Builder(builder: (context) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  });
}

List<Widget> buildLongItem(String title, String body) {
  return [
    Builder(builder: (context) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }),
    Builder(builder: (context) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildAutoLinkText(body),
        ),
      );
    }),
    const SizedBox(height: 8.0)
  ];
}

Widget buildRadiusBadge(String text) {
  return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 4.0,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  });
}

LayoutBuilder buildCenterItemLayoutBuilder(IconData iconData, String text) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  iconData,
                  size: 48.0,
                ),
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Flash buildErrorFlashBar(
    BuildContext context, FlashController<Object?> controller, Object? e) {
  return Flash(
    controller: controller,
    behavior: FlashBehavior.floating,
    position: FlashPosition.bottom,
    backgroundColor: Theme.of(context).colorScheme.onError,
    child: FlashBar(
      icon: Icon(
        LineIcons.exclamationTriangle,
        color: Theme.of(context).colorScheme.error,
      ),
      primaryAction: IconButton(
        onPressed: () => controller.dismiss(),
        icon: Icon(
          KIcons.close,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      title: Text(
        'エラー',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      content: Text(
        e.toString(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
  );
}

Flash buildInfoFlashBar(
    BuildContext context, FlashController<Object?> controller,
    {String? title, required String content}) {
  return Flash(
    controller: controller,
    behavior: FlashBehavior.floating,
    position: FlashPosition.bottom,
    backgroundColor: Theme.of(context).colorScheme.onSecondary,
    child: FlashBar(
      icon: Icon(
        LineIcons.infoCircle,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: title != null
          ? Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : null,
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
  );
}

Widget buildFileList(List<String>? fileNames,
    {Axis scrollDirection = Axis.vertical}) {
  return fileNames?.isNotEmpty ?? false
      ? ListView.builder(
          scrollDirection: scrollDirection,
          padding: const EdgeInsets.all(0.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fileNames!.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              leading: _buildExtIcon(
                  p.extension(fileNames[index]).replaceFirst('.', '')),
              title: Text(
                p.basename(fileNames[index]),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () async => _openFile(fileNames[index]),
            ),
          ),
        )
      : const SizedBox.shrink();
}

void _openFile(String filename) async {
  var path = p.join((await getApplicationDocumentsDirectory()).path, filename);
  if (File(path).existsSync()) {
    OpenFile.open(path);
  } else {
    showFlash(
      context: App.navigatorKey.currentState!.overlay!.context,
      builder: (context, controller) =>
          buildErrorFlashBar(context, controller, 'ファイルが存在しません'),
    );
  }
}

Icon _buildExtIcon(String ext) {
  switch (ext) {
    case 'pdf':
      return const Icon(LineIcons.pdfFile);
    case 'doc':
    case 'docx':
      return const Icon(LineIcons.wordFile);
    case 'xls':
    case 'xlsx':
      return const Icon(LineIcons.excelFile);
    case 'ppt':
    case 'pptx':
      return const Icon(LineIcons.powerpointFile);
    case 'zip':
    case 'rar':
      return const Icon(LineIcons.archiveFile);
    case 'csv':
      return const Icon(LineIcons.fileCsv);
    case 'txt':
      return const Icon(LineIcons.alternateFile);
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return const Icon(LineIcons.imageFile);
    case 'mp4':
    case 'mov':
      return const Icon(LineIcons.videoFile);
    case 'mp3':
    case 'wav':
      return const Icon(LineIcons.audioFile);
    default:
      return const Icon(LineIcons.file);
  }
}

Widget buildAutoLinkText(String text) {
  return Builder(builder: (context) {
    return SelectableAutoLinkText(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
      linkStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      onTap: (url) => launchUrlString(url, mode: LaunchMode.inAppWebView),
      onLongPress: (url) => Share.share(url),
      linkRegExpPattern:
          r'https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
    );
  });
}

PreferredSize buildAppBarBottom() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(6.0),
    child: Builder(
      builder: (context) => Visibility(
        visible: context.watch<ApiRepository>().isLoading,
        child: LinearProgressIndicator(
          minHeight: 3.0,
          valueColor: context.watch<ApiRepository>().isError
              ? AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.error)
              : AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
          value: context.watch<ApiRepository>().progress != -1
              ? context.watch<ApiRepository>().progress
              : null,
        ),
      ),
    ),
  );
}
