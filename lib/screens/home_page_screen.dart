import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance/providers/course_provider.dart';
import 'package:attendance/routes.dart';
import 'package:attendance/widgets/class_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final courseProvider = Provider.of<CourseProvider>(context);
    courseProvider.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    // Scaffold is a layout for
    // the major Material Components.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Align(
            alignment: const FractionalOffset(1, .5),
            child: FilledButton.icon(
                icon: const Icon(Icons.edit_note),
                label: const Text("Manage Classes"),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.courseList);
                })),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.all(10)),
            ClassList(
                key: const Key("somekey"),
                type: 'view',
                courses: courseProvider.courses)
          ],
        ),
      ),
    );
  }
}
