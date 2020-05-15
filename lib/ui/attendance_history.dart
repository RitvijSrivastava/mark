import 'package:attendance/models/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceHistory extends StatefulWidget {
  final String userId;

  AttendanceHistory({this.userId});

  @override
  _AttendanceHistoryState createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('history')
            .where("userId", isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // TODO: USE [table_sticky_headers] for building the data table.

          return ListView(
            shrinkWrap: true,
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text("Date"),
                    ),
                    DataColumn(
                      label: Text("Check In"),
                    ),
                    DataColumn(
                      label: Text("Check Out"),
                    ),
                    DataColumn(
                      label: Text("Hours Spent"),
                    ),
                  ],
                  rows: _buildList(context, snapshot.data.documents),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DataRow> _buildList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return snapshot.map((data) => _buildListItem(context, data)).toList();
  }

  DataRow _buildListItem(BuildContext context, DocumentSnapshot data) {
    final history = History.fromSnapshot(data);

    DateTime checkIn = DateTime.parse(history.checkIn);
    DateTime checkOut;
    if(history.checkOut != "-") checkOut = DateTime.parse(history.checkOut);
    String hrs = history.hrsSpent;

    String date = checkIn.day.toString() +
        "/" +
        checkIn.month.toString() +
        "/" +
        checkIn.year.toString();
    String inTime = checkIn.hour.toString() + ":" + checkIn.minute.toString();
    String outTime = history.checkOut == "-" ? "-" :
        checkOut.hour.toString() + ":" + checkOut.minute.toString();

    return DataRow(cells: [
      DataCell(Text(date)),
      DataCell(Text(inTime)),
      DataCell(Text(outTime)),
      DataCell(Text(hrs)),
    ]);
  }
}
