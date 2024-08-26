import 'package:flutter/material.dart';
import 'package:attendance/models/student.dart';

class AttendanceList extends StatelessWidget {
  const AttendanceList({super.key, required this.student});
  final Student student;

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for
    // the major Material Components.
    List<String> dates = [];
    Set<String> here = {};
    for (Attendance at in student.attendance) {
      String dateStr ="${at.date.year.toString()}-${at.date.month.toString().padLeft(2,'0')}-${at.date.day.toString().padLeft(2,'0')}";
      dates.add(dateStr);
      if (at.here != null && at.here as bool) {
        here.add(dateStr);
      }
    }
    dates.sort();
    if (dates.isNotEmpty) {
      return // Flexible(child: 
        ListView.builder(
            itemCount: dates.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
              // color: Theme.of(context).primaryColorLight,
                height: 20,
                child: Center(child: Text("${dates[index]} ${here.contains(dates[index]) ? "here" : "absent"}")));
            }
          // )
          );
    } else {
      return const Text("None");
    }
  }
}
