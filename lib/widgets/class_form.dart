import 'package:flutter/material.dart';
import 'package:attendance/models/course.dart';

class CourseForm extends StatefulWidget {
  final Course data;
  final GlobalKey<FormState> formKey;
  const CourseForm({super.key, required this.data, required this.formKey});

  @override
  CourseFormState createState() => CourseFormState();

  save() {
    formKey.currentState?.save();

    return data;
  }
}

class CourseFormState extends State<CourseForm> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.data.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
        key: widget.formKey,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  // autofocus: widget.data.id != "",
                  decoration: const InputDecoration(labelText: "Class Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    widget.data.name = value as String;
                  },
                )
              ],
            )));
  }
}
