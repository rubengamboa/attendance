import 'package:flutter/material.dart';
import 'package:attendance/models/student.dart';
import 'package:attendance/widgets/attendance_list.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // void changeRoute() {
  //   setState(() {
  //     Navigator.pushNamed(context, Routes.attendanceView,
  //         arguments: Student(id: "", firstname: "", lastname: "", attendance: []));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var student = ModalRoute.of(context)!.settings.arguments as Student;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(student.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AttendanceList(
                key: const Key("attendance_list"),
                student: student)
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: changeRoute,
      //   tooltip: 'New Class',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
