import 'package:flutter/material.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/models/student.dart';
import 'package:attendance/routes.dart';
import 'package:attendance/screens/view_student_screen.dart';

class StudentList extends StatelessWidget {
  const StudentList({super.key, required this.course, required this.students});
  final Course course;
  final List<Student> students;

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for
    // the major Material Components.
    if (students.isNotEmpty) {
      return Flexible(
        child: ListView.builder(
          itemCount: students.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
                // color: Theme.of(context).primaryColorLight,
                height: 40,
                child: TextButton(
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("${index+1}) ${students[index].name}"),
                    const SizedBox(width: 20),
                    if (students[index].attendance.isNotEmpty)
                      Opacity(
                        opacity: .76,
                        child: Text(
                            "${students[index].attended}/${students[index].attendance.length}"),
                      ),
                    if (students[index].attendance.isEmpty)
                      const Opacity(opacity: .76, child: Text("")),
                  ]),
                  onPressed: () => {
                    Navigator.pushNamed(context, Routes.studentView,
                        arguments: StudentArguments(
                            course: course,
                            studentIndex: index,
                            studentList: students))
                  },
                ));
          },
          // separatorBuilder: (BuildContext context, int index) => const Divider(),
        ));
    } else {
      return Column(children: [
        const SizedBox(height: 20),
        const Text("This class has no students yet."),
        const SizedBox(height: 20),
        FilledButton.icon(
            icon: const Icon(Icons.edit_note),
            label: const Text("Edit Class"),
            onPressed: () {
              Navigator.pushNamed(context, Routes.courseEdit,
                  arguments: course);
            }),
      ]);
    }
  }
}
