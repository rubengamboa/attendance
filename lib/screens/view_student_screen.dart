import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/models/student.dart';
import 'package:attendance/routes.dart';
import 'package:attendance/services/database_service.dart';

class StudentArguments {
  final Course course;
  final int studentIndex;
  final List<Student> studentList;

  StudentArguments(
      {required this.course,
      required this.studentIndex,
      required this.studentList});
}

class ViewStudentScreen extends StatefulWidget {
  const ViewStudentScreen({super.key});

  @override
  State<ViewStudentScreen> createState() => _ViewStudentScreenState();
}

class _ViewStudentScreenState extends State<ViewStudentScreen> {
  // void changeRoute() {
  //   setState(() {
  //     Navigator.pushNamed(context, Routes.courseView,
  //         arguments: Course(id: "", name: ""));
  //   });
  // }

  Course course = Course();
  Student student =
      Student(id: "", firstname: "", lastname: "", attendance: []);
  Attendance todaysAttendance =
      Attendance(studentId: "", courseId: "", date: Attendance.today());
  // String history = "<<<history>>>";

  Future<File?> get _image async {
    Directory? path = await _localPath;
    if (path != null) {
      var fullPath = "${path.path}/studentphotos/${student.id}";
      if (await File("$fullPath.png").exists()) {
        return File("$fullPath.png");
      } else if (await File("$fullPath.jpg").exists()) {
        return File("$fullPath.jpg");
      }
    }

    return null;
  }

  Future<Directory?> get _localPath async {
    return await getApplicationDocumentsDirectory();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final courseProvider = Provider.of<CourseProvider>(context);
  //   course = ModalRoute.of(context)!.settings.arguments as Course;
  //   courseProvider.fetchStudents(course);
  // }

  Future<Attendance> markHere() async {
    todaysAttendance =
        await DatabaseService().saveAttendance(course, student, true);
    return todaysAttendance;
  }

  Future<Attendance> markAbsent() async {
    todaysAttendance =
        await DatabaseService().saveAttendance(course, student, false);
    return todaysAttendance;
  }

  List<bool> getSelectionState(Attendance attendance) {
    return [
      attendance.here != null && attendance.here == true ? true : false,
      attendance.here != null && attendance.here == false ? true : false
    ];
  }

  @override
  Widget build(BuildContext context) {
    // final courseProvider = Provider.of<CourseProvider>(context);
    var args = ModalRoute.of(context)!.settings.arguments as StudentArguments;
    course = args.course;
    student = args.studentList[args.studentIndex];
    // history = "<<<EMPTY history>>>";
    var today = Attendance.today();
    for (var item in student.attendance) {
      if (item.date == today) {
        todaysAttendance = item;
        break;
      }
    }
    var isSelected = getSelectionState(todaysAttendance);

    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(student.name),
      ),
      body: Center(
        child: Row(
          children: [
            // const SizedBox(width: 60),
            const Spacer(flex: 1),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FutureBuilder<File?>(
                  future: _image,
                  builder: (context, snapshot) {
                    var file = snapshot.data;
                    if (file != null) {
                      return Container(
                          margin: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(3)),
                          ),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minHeight: 200,
                                  minWidth: 200,
                                  maxWidth: 240,
                                  maxHeight: 350),
                              child: Image.file(
                                file,
                                fit: BoxFit.scaleDown,
                              )));
                    } else {
                      return Container(
                        margin: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 2,
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3)),
                        ),
                        child: const Icon(
                          Icons.account_box_rounded,
                          size: 200,
                        ),
                      );
                    }
                  },
                ),
                Text("${student.attended}/${student.attendance.length}"),
                const Spacer(flex: 1),
                ToggleButtons(
                    onPressed: (int index) async {
                      if (index == 0) {
                        todaysAttendance = await markHere();
                      } else {
                        todaysAttendance = await markAbsent();
                      }
                      setState(() {
                        isSelected = getSelectionState(todaysAttendance);
                      });
                    },
                    isSelected: isSelected,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    children: const [
                      Tooltip(
                        message: "Mark Here",
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 10),
                          child: Icon(Icons.event_available),
                        ),
                      ),
                      Tooltip(
                          message: "Mark Absent",
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 36, vertical: 10),
                            child: Icon(Icons.event_busy),
                          )),
                    ]),
                const Spacer(flex: 1),
                // const Text("Present"),
                // AttendanceList(attendance: student.attendance, isPresent: true),
                // const Text("Absent"),
                // AttendanceList(attendance: student.attendance, isPresent: false),
                // Row(children: <Widget>[
                //   Column(children: [
                //     const Text("Present"),
                //     // AttendanceList(attendance: student.attendance, isPresent: true)
                //   ],),
                //   // const Spacer(flex: 1),
                //   Column(children: [
                //     const Text("Absent"),
                //     // AttendanceList(attendance: student.attendance, isPresent: false)
                //   ],),
                // ],),
                // Text(history),
                const SizedBox(height: 60),
                // StudentList(
                //     key: const Key("student_list"),
                //     course: course,
                //     students: courseProvider.students)
              ],
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.attendanceView,
                    arguments: student);
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(const SnackBar(content: Text("Coming Soon!")));
        },
        tooltip: 'History',
        child: const Icon(Icons.calendar_month),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: () {
                int next = args.studentIndex - 1;
                if (next < 0) {
                  next = args.studentList.length - 1;
                }

                Navigator.popAndPushNamed(context, Routes.studentView,
                    arguments: StudentArguments(
                        course: course,
                        studentIndex: next,
                        studentList: args.studentList));
              },
              label: const Text("Prev"),
              icon: const Icon(Icons.arrow_back),
              iconAlignment: IconAlignment.start,
            ),
            const Spacer(
              flex: 1,
            ),
            FilledButton.icon(
              onPressed: () {
                int next = args.studentIndex + 1;
                if (next >= args.studentList.length) {
                  next = 0;
                }

                Navigator.popAndPushNamed(context, Routes.studentView,
                    arguments: StudentArguments(
                        course: course,
                        studentIndex: next,
                        studentList: args.studentList));
              },
              label: const Text("Next"),
              icon: const Icon(Icons.arrow_forward),
              iconAlignment: IconAlignment.end,
            )
          ],
        )
      ],
    );
  }
}
