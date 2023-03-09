import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/class_link.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/gpa.dart';
import 'package:gakujo_task/models/grade.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/models/shared_file.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/models/timetable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  initializeDateFormatting('ja');
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(ReportAdapter());
  Hive.registerAdapter(QuizAdapter());
  Hive.registerAdapter(GradeAdapter());
  Hive.registerAdapter(SharedFileAdapter());
  Hive.registerAdapter(ClassLinkAdapter());
  Hive.registerAdapter(TimetableAdapter());
  Hive.registerAdapter(GpaAdapter());
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
        ChangeNotifierProvider(create: (_) => ApiRepository()),
        ChangeNotifierProvider(create: (_) => ContactRepository(ContactBox())),
        ChangeNotifierProvider(create: (_) => SubjectRepository(SubjectBox())),
        ChangeNotifierProvider(
            create: (_) => SettingsRepository(SettingsBox())),
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
      ],
      child: const App(),
    );
  }
}
