import 'dart:math';

import 'package:flutter/material.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/models/student.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static DatabaseService? _databaseHelper; //Singleton object of the class
  static Database? _database;
  DatabaseService._createInstance();
  factory DatabaseService() {
    //initializing the object
    _databaseHelper ??= DatabaseService._createInstance();
    return _databaseHelper!;
  }

  final Map<int, CommandScript> versionCommands = {
    1: CommandScriptV1()
  };
  // void setCommand(int version, CommandScript command) {
  //   //match the version number with a command script.
  //   versionCommands[version] = command;
  // }

  Future<Database> get database async {
    _database ??= await openDb();
    return _database!;
  }

  Future<List<Course>> courses() async {
    Database db = await openDb();
    List<Map<String, Object?>> data = await db.query('Course', orderBy: 'name');
    return data.map((o) => Course.fromMap(o)).toList();
  }

  Future<List<Student>> students(Course course) async {
    Database db = await openDb();
    List<Map<String, Object?>> data = await db.rawQuery('''
      SELECT * FROM Student s 
        INNER JOIN CourseStudent cs 
        ON cs.studentId = s.id 
          AND cs.courseId = ?
      ORDER BY s.lastname, s.firstname
    ''', [course.id]);
    var students = data.map((o) => Student.fromMap(o)).toList();

    try {
      List<Map<String, Object?>> attendanceData = await db.rawQuery('''
        SELECT * FROM StudentAttendance a 
            WHERE a.courseId = ?
      ''', [course.id]);
      var attendanceList = attendanceData.map((a) => Attendance.fromMap(a));
      Map<String, List<Attendance>> attendance = {};
      for (var item in attendanceList) {
        if (!attendance.containsKey(item.studentId)) {
          attendance[item.studentId] = [];
        }
        attendance[item.studentId]?.add(item);
      }
      for (var student in students) {
        if (attendance.containsKey(student.id)) {
          var studentAttendance = attendance[student.id];
          if (studentAttendance != null) {
            studentAttendance.sort((a, b) => a.date.compareTo(b.date));
            student.attendance = studentAttendance;
          }
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }

    return students;
  }

  Future<void> addStudents(Course course, List<Student> students) async {
    Database db = await openDb();
    await db
        .rawQuery('DELETE FROM CourseStudent WHERE courseId = ?', [course.id]);
    for (Student student in students) {
      await db.rawQuery('''
        INSERT INTO Student (id, firstname, lastname) VALUES (?, ?, ?) 
          ON CONFLICT(id) DO UPDATE SET firstname = excluded.firstname, lastname = excluded.lastname
      ''', [student.id, student.firstname, student.lastname]);

      await db.rawQuery('''
        INSERT OR REPLACE INTO CourseStudent (courseId, studentId) VALUES (?, ?)
      ''', [course.id, student.id]);

      for (Attendance att in student.attendance) {
        if (att.here != null) {
          await db.rawQuery('''
            INSERT INTO StudentAttendance (courseId, studentId, date, here) VALUES (?, ?, ?, ?)
              ON CONFLICT(courseId, studentId, date) DO UPDATE SET here = excluded.here
            ''', [
              att.courseId,
              att.studentId,
              att.date.toIso8601String().substring(0, 10),
              att.here as bool ? 1 : 0
            ]);
        }
      }
    }

    return;
  }

  Future<Attendance> saveAttendance(
      Course course, Student student, bool value) async {
    Database db = await openDb();

    Attendance attendance = Attendance(
        studentId: student.id,
        courseId: course.id,
        date: Attendance.today(),
        here: value);

    await db.rawQuery('''
      INSERT INTO StudentAttendance (courseId, studentId, date, here) VALUES (?, ?, ?, ?)
        ON CONFLICT(courseId, studentId, date) DO UPDATE SET here = excluded.here
    ''', [
      attendance.courseId,
      attendance.studentId,
      attendance.date.toIso8601String().substring(0, 10),
      value ? 1 : 0
    ]);

    return attendance;
  }

  Future<Course> saveCourse(Course course) async {
    Database db = await openDb();
    try {
      if (course.id == "") {
        Course newCourse = Course(id: generateID(), name: course.name);
        await db.rawInsert('INSERT INTO Course(id, name) VALUES(?, ?)',
            [newCourse.id, newCourse.name]);
        return newCourse;
      } else {
        await db.rawUpdate('UPDATE Course SET name = ? WHERE id = ?',
            [course.name, course.id]);
        return Course(id: course.id, name: course.name);
      }
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<bool> deleteCourse(Course course) async {
    Database db = await openDb();
    try {
      await db.delete('StudentAttendance',
          where: 'courseId = ?', whereArgs: [course.id]);
      await db.delete('CourseStudent',
          where: 'courseId = ?', whereArgs: [course.id]);
      var count =
          await db.delete('Course', where: 'id = ?', whereArgs: [course.id]);

      return count > 0;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  Future<Database> openDb() async {
    return await openDatabase('rubenClasses.db', version: 2,
        onOpen: (Database db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    }, onCreate: (database, version) async {
      create(database, version);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      upgrade(db, oldVersion, newVersion);
    });
  }

  Future<void> create(Database db, int version) async {
    debugPrint("Creating database ${db.path} ");
    upgrade(db, 0, version);
  }

  Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Upgrading database ${db.path} from $oldVersion to $newVersion");

    Batch batch = db.batch();

    /// executes the commands to upgrade the database schema
    for (int currentVersion = oldVersion + 1;
        currentVersion <= newVersion;
        currentVersion++) {
      CommandScript? command = versionCommands[currentVersion];
      command?.execute(batch);
    }
    await batch.commit();
  }

  static String generateID() {
    Random random = Random(DateTime.now().millisecond);

    const String hexDigits = "0123456789abcdef";
    List<String> uuid = [
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      ""
    ];

    for (int i = 0; i < 36; i++) {
      final int hexPos = random.nextInt(16);
      uuid[i] = (hexDigits.substring(hexPos, hexPos + 1));
    }

    int pos = (int.parse(uuid[19], radix: 16) & 0x3) |
        0x8; // bits 6-7 of the clock_seq_hi_and_reserved to 01

    uuid[14] = "4"; // bits 12-15 of the time_hi_and_version field to 0010
    uuid[19] = hexDigits.substring(pos, pos + 1);

    uuid[8] = uuid[13] = uuid[18] = uuid[23] = "-";

    final StringBuffer buffer = StringBuffer();
    buffer.writeAll(uuid);
    return buffer.toString();
  }
}

abstract class CommandScript {
  Future<void> execute(Batch batch);
}

class CommandScriptV1 extends CommandScript {
  @override
  Future<void> execute(Batch batch) async {
    batch.execute('''
      CREATE TABLE Course (
        id VARCHAR(80), 
        name VARCHAR(255), 
        PRIMARY KEY(id)
      )''');
    batch.execute('''
      CREATE TABLE Student (
        id VARCHAR(80), 
        firstname VARCHAR(255), 
        lastname VARCHAR(255), 
        PRIMARY KEY(id)
      )''');

    batch.execute('''
      CREATE TABLE CourseStudent (
        courseId VARCHAR(80) REFERENCES Course ON DELETE CASCADE, 
        studentId VARCHAR(80) REFERENCES Student ON DELETE CASCADE, 
        PRIMARY KEY(courseId, studentId)
      )''');
    batch.execute('''
      CREATE TABLE StudentAttendance (
        courseId VARCHAR(80) REFERENCES Course ON DELETE CASCADE, 
        studentId VARCHAR(80) REFERENCES Student ON DELETE CASCADE,
        date VARCHAR(10),
        here INT(1),
        PRIMARY KEY(courseId, studentId, date)
      )''');
  }
}

