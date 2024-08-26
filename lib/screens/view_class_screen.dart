import 'dart:io';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/models/student.dart';
import 'package:attendance/providers/course_provider.dart';
import 'package:attendance/routes.dart';
import 'package:attendance/screens/view_student_screen.dart';
import 'package:attendance/widgets/student_list.dart';

class ViewClassScreen extends StatefulWidget {
  const ViewClassScreen({super.key});

  @override
  State<ViewClassScreen> createState() => _ViewClassScreenState();
}

class _ViewClassScreenState extends State<ViewClassScreen> {
  Future<String> get courseFilename async {
    Directory? path = await _localPath;
    if (path != null) {
      if (course.name != "") {
        String name = course.name.replaceAll(" ", "");
        return "${path.path}/export/$name.csv";
      } else {
        return "${path.path}/export/UnknownCourse.csv";
      }
    } else {
      return "No Valid Downloads Folder";
    }
  }

  Future<Directory?> get _localPath async {
    return await getApplicationDocumentsDirectory();
  }

  void changeRoute() {
    setState(() {
      Navigator.pushNamed(context, Routes.courseView,
          arguments: Course(id: "", name: ""));
    });
  }

  Course course = Course();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final courseProvider = Provider.of<CourseProvider>(context);
    course = ModalRoute.of(context)!.settings.arguments as Course;
    courseProvider.fetchStudents(course);
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(course.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            StudentList(
                key: const Key("student_list"),
                course: course,
                students: courseProvider.students)
          ],
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            TextButton.icon(
                onPressed: () async {
                  var randomized = Student.randomize(courseProvider.students);
                  randomized.shuffle();
                  Navigator.pushNamed(context, Routes.studentView,
                      arguments: StudentArguments(
                          course: course,
                          studentIndex: 0,
                          studentList: randomized));
                },
                label: const Text("Randomize"),
                icon: const Icon(Icons.shuffle)),
            const Spacer(
              flex: 1,
            ),
            FilledButton.icon(
              onPressed: () async {
                // var path = await courseFilename;

                List<Student> students = courseProvider.students;
                List<String> headers = [ 'ID', 'Last Name', 'First Name', 'Attended', 'Checked Attendance' ];
                Set<DateTime> meetings = {};
                for (Student student in students) {
                  for (Attendance att in student.attendance) {
                    meetings.add(att.date);
                  }
                }
                List meetingsList = meetings.toList();
                meetingsList.sort();
                for (DateTime dt in meetingsList) {
                  String dateStr = "${dt.year.toString()}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}";
                  headers.add(dateStr);
                }
                List<List<dynamic>> rows = [headers];
                for (var student in students) {
                  List<dynamic> row = [
                    student.id,
                    student.lastname,
                    student.firstname,
                    student.attended,
                    student.attendance.length
                  ];
                  Map<DateTime, bool> attendanceHistory = {};
                  for (Attendance att in student.attendance) {
                    if (att.here != null) {
                        attendanceHistory[att.date] = att.here as bool;
                    }
                  }
                  for (DateTime dt in meetingsList) {
                    if (!attendanceHistory.containsKey(dt)) {
                      row.add("");
                    } 
                    else {
                      row.add(attendanceHistory[dt]);
                    }
                  }
                  rows.add(row);
                }
                String csv = const ListToCsvConverter().convert(rows);
                String? path = await FilePicker.platform.saveFile(
                  dialogTitle: 'Please select an output file:',
                  fileName: 'course-list.csv',
                  type: FileType.custom,
                  allowedExtensions: ['csv'],
                  bytes: utf8.encode(csv),
                );

                if (path != null) {
                  // File f = File(path);
                  // await f.create(recursive: true);
                  // await f.writeAsString(csv);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Downloaded $path")));
                  }
                }
              },
              label: const Text("Download"),
              icon: const Icon(Icons.download),
            )
          ],
        )
      ],
    );
  }
}
