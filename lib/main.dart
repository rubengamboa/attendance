import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance/providers/course_provider.dart';
import 'package:attendance/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CourseProvider())
        ],
        child: MaterialApp(
          title: 'Attendance',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            useMaterial3: true,
          ),
          // home: Navigator.pushNamed(context, Routes.classManage),
          initialRoute: Routes.courseManage,
          routes: Routes.routes,
        ));
  }
}
