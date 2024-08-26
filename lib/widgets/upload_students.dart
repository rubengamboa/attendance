import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:attendance/models/course.dart';

class StudentUpload extends StatefulWidget {
  final Course course;
  final void Function(File?) fileChange;
  const StudentUpload(
      {super.key, required this.course, required this.fileChange});

  @override
  State<StudentUpload> createState() => _StudentUploadState();
}

class _StudentUploadState extends State<StudentUpload> {
  File? fileToRead;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          FilledButton.icon(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform
                  .pickFiles(type: FileType.custom, allowedExtensions: ["csv"]);
              if (result != null) {
                setState(() {
                  fileToRead = File(result.files.single.path as String);
                  widget.fileChange(fileToRead);
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              }
            },
            label: const Text("Upload Roster"),
            icon: const Icon(Icons.upload),
          ),
          if (fileToRead?.path != null)
            Text(
              fileToRead?.path != null
                  ? fileToRead?.path as String
                  : "Unknown File",
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 10,
              textAlign: TextAlign.center,
            )
        ])
        // )
        );
  }
}
