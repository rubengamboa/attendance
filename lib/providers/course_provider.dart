import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/models/student.dart';
import 'package:attendance/services/database_service.dart';

class CourseProvider with ChangeNotifier {
  final List<Course> _courses = [];
  UnmodifiableListView<Course> get courses => UnmodifiableListView(_courses);
  final List<Student> _students = [];
  UnmodifiableListView<Student> get students => UnmodifiableListView(_students);

  bool loading = false;

  void fetchCourses() {
    DatabaseService().courses().then((value) {
      _courses.clear();
      _courses.addAll(value);
      notifyListeners();
    });
  }

  void fetchStudents(Course course) {
    DatabaseService().students(course).then((value) {
      _students.clear();
      _students.addAll(value);
      notifyListeners();
    });
  }

  void add(Course course) {
    _courses.add(course);
    _courses.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void update(Course course) {
    int toEdit = _courses.indexOf(course);
    _courses[toEdit] = course;
    _courses.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void remove(Course course) {
    _courses.remove(course);
    notifyListeners();
  }
}
