import 'dart:math';

class Student {
  String id;
  String firstname;
  String lastname;
  List<Attendance> attendance;

  String get name {
    return "$firstname $lastname".trim();
  }

  int get attended {
    if (attendance.isEmpty) {
      return 0;
    } else {
      return attendance.map((item) {
        var value = item.here;
        if (value != null) {
          return value ? 1 : 0;
        } else {
          return 0;
        }
      }).reduce((count, item) => count + item);
    }
  }

  static List<Student> randomize(List<Student> students) {
    final rnd = Random();
    List<Student> randomized = [];
    int maxweight = 0;
    for (Student student in students) {
      if (student.attendance.length > maxweight) {
        maxweight = student.attendance.length;
      }
    }
    List<int> weights = [];
    for (int i=0; i<students.length; i++) {
      weights.add(maxweight-students[i].attendance.length+1);
    }
    for (int i=0; i<students.length; i++) {
      int sum = weights.fold(0, (x,y) => x+y);
      int choice = 1 + rnd.nextInt(sum);
      int cumulative = 0;
      for (int j=0; j<students.length; j++) {
        cumulative += weights[j];
        if (choice <= cumulative) {
          weights[j] = 0;
          randomized.add(students[j]);
          break;
        }
      }
    }

    return randomized;
  }

  Student(
      {required this.id,
      required this.firstname,
      required this.lastname,
      required this.attendance});

  // Map<String, Object?> toMap() {
  //   var map = <String, Object?>{
  //     id: id,
  //     firstname: firstname,
  //     lastname: lastname
  //   };
  //   return map;
  // }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map["id"] as String,
      firstname: map["firstname"] as String,
      lastname: map["lastname"] as String,
      attendance: [],
    );
  }
}

class Attendance {
  String studentId;
  String courseId;
  DateTime date;
  bool? here;

  static DateTime today() {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Attendance(
      {required this.studentId,
      required this.courseId,
      required this.date,
      this.here});

  factory Attendance.fromMap(Map<String, Object?> map) {
    var dateStr = map["date"] as String;
    var dateParts = dateStr.split("-");
    var date = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]),
        int.parse(dateParts[2]));
    bool? here;
    if (map["here"] == 1 || map["here"] == "1") {
      here = true;
    } else if (map["here"] == 0 || map["here"] == "0") {
      here = false;
    }

    return Attendance(
      studentId: map["studentId"] as String,
      courseId: map["courseId"] as String,
      date: date,
      here: here,
    );
  }
}
