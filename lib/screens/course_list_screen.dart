import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/providers/course_provider.dart';
import 'package:attendance/routes.dart';
import 'package:attendance/widgets/class_list.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  void changeRoute() {
    setState(() {
      Navigator.pushNamed(context, Routes.courseEdit,
          arguments: Course(id: "", name: ""));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final courseProvider = Provider.of<CourseProvider>(context);
    courseProvider.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClassList(
                key: const Key("course_list"),
                type: 'manage',
                courses: courseProvider.courses)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeRoute,
        tooltip: 'New Class',
        child: const Icon(Icons.add),
      ),
    );
  }
}
