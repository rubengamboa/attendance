import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_helper;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:attendance/models/course.dart';
import 'package:attendance/models/student.dart';
import 'package:attendance/providers/course_provider.dart';
import 'package:attendance/routes.dart';
import 'package:attendance/services/database_service.dart';
import 'package:attendance/widgets/class_form.dart';
import 'package:attendance/widgets/upload_images.dart';
import 'package:attendance/widgets/upload_students.dart';

class EditClassPage extends StatefulWidget {
  const EditClassPage({super.key, required this.title});

  final String title;

  @override
  State<EditClassPage> createState() => _EditClassPageState();
}

class _EditClassPageState extends State<EditClassPage> {
  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();

  //   return directory.path;
  // }
  File? file;
  File? imageZip;

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = ModalRoute.of(context)!.settings.arguments as Course;
    final newCourse = course.id == "";
    final form = CourseForm(data: course, formKey: formKey);
    final upload = StudentUpload(
        course: course,
        fileChange: (f) {
          file = f;
        });
    final photos = ImageUpload(
        course: course,
        fileChange: (f) {
          imageZip = f;
        });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(course.id != "" ? "Edit Course" : "Add Course"),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // const Spacer(flex: 1),
                form,
                // const Spacer(flex: 1),
                upload,
                photos,
                // const Spacer(flex: 1),
              ],
            )),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            if (!newCourse)
              TextButton.icon(
                onPressed: () async {
                  await _confirmationDialog(course, context);
                },
                label: const Text("Delete"),
                icon: const Icon(Icons.delete_forever),
              ),
            const Spacer(
              flex: 1,
            ),
            FilledButton.icon(
              onPressed: () async {
                Course data = form.save();
                Course saved = await DatabaseService()
                    .saveCourse(Course(id: course.id, name: data.name));
                if (file != null) {
                  List<String> lines = await file!.readAsLines();
                  List<String> headers = lines[0].split(",").map((s) => s.trim()).toList();
                  lines = lines.sublist(1); // Skip header line
                  List<Student> students = [];
                  for (String line in lines) {
                    List<String> items = line.split(",").map((s) => s.trim()).toList();
                    List<Attendance> attendance = [];
                    for (int i=5; i<items.length; i++) {
                      if (items[i].trim() != "") {
                        attendance.add(Attendance.fromMap({
                            "studentId": items[0].trim(),
                            "courseId": course.id,
                            "date": headers[i],
                            "here": (items[i] == "true" ? 1 : 0)
                        }));
                      }
                    }
                    students.add(Student(
                        id: items[0].trim(),
                        lastname: items[1].trim(),
                        firstname: items[2].trim(),
                        attendance: attendance));
                  }
                  await DatabaseService().addStudents(saved, students);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Students saved")));
                  }
                }
                var zip = imageZip;
                if (zip != null) {
                  // List<String> lines = await imageZip!.z();
                  var basePath = await getApplicationDocumentsDirectory();
                  final imgDestination =
                      Directory("${basePath.path}/studentphotos");
                  try {
                    imgDestination.create();
                    final inputStream = InputFileStream(zip.path);
                    final archive = ZipDecoder().decodeBuffer(inputStream);
                    for (final file in archive.files) {
                      final filename = path_helper.basename(file.name);
                      if (file.isFile) {
                        if (filename.endsWith(".png") ||
                            filename.endsWith(".jpg")) {
                          final data = file.content as List<int>;
                          File('${imgDestination.path}/$filename')
                            ..createSync(recursive: true)
                            ..writeAsBytesSync(data);
                        }
                      }
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Images saved")));
                  }
                }

                if (newCourse) {
                  courseProvider.add(saved);
                } else {
                  courseProvider.update(saved);
                }
                if (context.mounted) {
                  if (file == null && imageZip == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Class saved")));
                  }
                  Navigator.of(context).pop();
                }
              },
              label: const Text("Save"),
              icon: const Icon(Icons.save),
            )
          ],
        )
      ],
    );
  }

  Future<void> _confirmationDialog(Course course, BuildContext owner) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete \'${course.name}\''),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this course?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton.icon(
              label: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                var name = course.name;
                var result = await DatabaseService().deleteCourse(course);
                if (context.mounted) {
                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("'$name' deleted.")));
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.courseManage, (Route<dynamic> route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to Delete '$name'.")));
                  }
                }
              },
              icon: const Icon(Icons.delete_forever),
            ),
          ],
        );
      },
    );
  }
}
