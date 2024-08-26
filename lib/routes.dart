import 'package:flutter/material.dart';
import 'package:attendance/screens/view_class_screen.dart';
import 'package:attendance/screens/view_student_screen.dart';
import 'package:attendance/screens/home_page_screen.dart';
import 'package:attendance/screens/course_list_screen.dart';
import 'package:attendance/screens/edit_class_screen.dart';
import 'package:attendance/screens/attendance_screen.dart';

class Routes {
  Routes._();
  // static variables
  static const String courseManage = '/';
  static const String courseList = '/course-list';
  static const String courseEdit = '/course-edit';
  static const String courseView = '/course-view';
  static const String studentView = '/student-view';
  static const String attendanceView = '/attendance-view';
  static final dynamic routes = <String, WidgetBuilder>{
    courseManage: (BuildContext context) =>
        const HomePage(title: 'Manage Classes'),
    courseList: (BuildContext context) =>
        const CourseListScreen(title: 'Class List'),
    courseEdit: (BuildContext context) =>
        const EditClassPage(title: 'Edit Class'),
    courseView: (BuildContext context) => const ViewClassScreen(),
    studentView: (BuildContext context) => const ViewStudentScreen(),
    attendanceView: (BuildContext context) => const AttendanceScreen(),
  };
}
