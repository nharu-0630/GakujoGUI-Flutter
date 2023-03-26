import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gakujo_gui/api/provide.dart';
import 'package:gakujo_gui/app.dart';
import 'package:gakujo_gui/models/class_link.dart';
import 'package:gakujo_gui/models/contact.dart';
import 'package:gakujo_gui/models/gpa.dart';
import 'package:gakujo_gui/models/grade.dart';
import 'package:gakujo_gui/models/quiz.dart';
import 'package:gakujo_gui/models/report.dart';
import 'package:gakujo_gui/models/settings.dart';
import 'package:gakujo_gui/models/shared_file.dart';
import 'package:gakujo_gui/models/subject.dart';
import 'package:gakujo_gui/models/syllabus_result.dart';
import 'package:gakujo_gui/models/timetable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('GakujoGUI');
  } else if (Platform.isWindows) {
    WindowsTaskbar.setWindowTitle('GakujoGUI');
    WindowsTaskbar.setProgress(1, 1);
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
  }
  initializeDateFormatting('ja');
  await Hive.initFlutter((await getApplicationSupportDirectory()).path);
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(ReportAdapter());
  Hive.registerAdapter(QuizAdapter());
  Hive.registerAdapter(GradeAdapter());
  Hive.registerAdapter(SharedFileAdapter());
  Hive.registerAdapter(ClassLinkAdapter());
  Hive.registerAdapter(TimetableAdapter());
  Hive.registerAdapter(GpaAdapter());
  Hive.registerAdapter(SyllabusResultAdapter());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SettingsRepository(SettingsBox())),
        ChangeNotifierProvider(create: (_) => ContactRepository(ContactBox())),
        ChangeNotifierProvider(create: (_) => SubjectRepository(SubjectBox())),
        ChangeNotifierProvider(create: (_) => ReportRepository(ReportBox())),
        ChangeNotifierProvider(create: (_) => QuizRepository(QuizBox())),
        ChangeNotifierProvider(create: (_) => GradeRepository(GradeBox())),
        ChangeNotifierProvider(
            create: (_) => SharedFileRepository(SharedFileBox())),
        ChangeNotifierProvider(
            create: (_) => ClassLinkRepository(ClassLinkBox())),
        ChangeNotifierProvider(
            create: (_) => TimetableRepository(TimetableBox())),
        ChangeNotifierProvider(create: (_) => GpaRepository(GpaBox())),
        ChangeNotifierProvider(
            create: (_) => SyllabusResultRepository(SyllabusResultBox())),
        ChangeNotifierProvider(create: (_) => ApiRepository()),
      ],
      child: const App(),
    );
  }
}
