import 'package:flutter/material.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/routes.dart';

class ClassList extends StatelessWidget {
  const ClassList({super.key, required this.type, required this.courses});
  final String type;

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: ListView.builder(
      itemCount: courses.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return SizedBox(
            height: 76,
            child: TextButton(
              child: Text(courses[index].name),
              onPressed: () => {
                Navigator.pushNamed(context,
                    type == "manage" ? Routes.courseEdit : Routes.courseView,
                    arguments: courses[index])
              },
            ));
      },
    ));
  }
}
