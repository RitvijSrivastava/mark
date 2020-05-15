import 'package:attendance/models/employee.dart';
import 'package:attendance/models/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ListEmployeePage extends StatefulWidget {
  @override
  _ListEmployeePageState createState() => _ListEmployeePageState();
}

class _ListEmployeePageState extends State<ListEmployeePage> {
  var streams = [
    Firestore.instance.collection('employees'),
    Firestore.instance
        .collection('employees')
        .where('storeId', isEqualTo: '123'),
    Firestore.instance
        .collection('employees')
        .where('storeId', isEqualTo: '456'),
  ];

  int _currentStreamIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentStreamIndex = 0;
  }

  /// Change stream according to the store selected
  jumpToStream(int index) {
    setState(() {
      _currentStreamIndex = index;
    });
  }

  /// Build a list of employees
  List<Widget> _buildList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return snapshot.map((data) => _buildListItem(context, data)).toList();
  }

  /// Build list item
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Employee emp = Employee.fromSnapshot(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ListEmployeeAttendance(userId: emp.id))),
        leading: CircleAvatar(
          radius: 25,
          child: ClipOval(
            child: Center(
              child: Image.network(
                emp.image,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  );
                },
              ),
            ),
          ),
        ),
        title: Text(
          "${emp.first} ${emp.last}",
          textScaleFactor: 1.2,
        ),
        subtitle: Text(
          "Store: ${emp.storeID == "123" ? "TMS001" : "Tamarind Cafe"}",
          textScaleFactor: 1.1,
        ),
        trailing: Icon(Icons.chevron_right, size: 40.0),
      ),
    );
  }

  /// Build Menu Button
  Widget _buildMenuButton(int index, String name) {
    return MaterialButton(
      elevation: 0,
      padding: EdgeInsets.all(10.0),
      onPressed: () => jumpToStream(index),
      child: Text(
        name,
        textScaleFactor: 1.1,
      ),
      textColor: _currentStreamIndex == index ? Colors.white : Colors.black,
      color: _currentStreamIndex == index ? Colors.blue : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          style: BorderStyle.solid,
          width: 1.8,
          color: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: streams[_currentStreamIndex].snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // Employee emp = Employee.fromMap(snapshot.data.documents[0].data);
          List<Widget> _empList = _buildList(context, snapshot.data.documents);

          return CustomScrollView(
            slivers: <Widget>[
              SliverStickyHeader(
                header: Container(
                  // height: MediaQuery.of(context).size.height * 0.20,
                  height: 60.0,
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildMenuButton(0, "ALL"),
                      _buildMenuButton(1, "TMS001"),
                      _buildMenuButton(2, "Tamarind Cafe"),
                    ],
                  ),
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _empList[index],
                    childCount: _empList.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ListEmployeeAttendance extends StatefulWidget {
  final String userId;
  ListEmployeeAttendance({this.userId});

  @override
  _ListEmployeeAttendanceState createState() => _ListEmployeeAttendanceState();
}

class _ListEmployeeAttendanceState extends State<ListEmployeeAttendance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance History"),
      ),
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
    DateTime checkOut = DateTime.parse(history.checkOut);
    String hrs = history.hrsSpent;

    String date = checkIn.day.toString() +
        "/" +
        checkIn.month.toString() +
        "/" +
        checkIn.year.toString();
    String inTime = checkIn.hour.toString() + ":" + checkIn.minute.toString();
    String outTime =
        checkOut.hour.toString() + ":" + checkOut.minute.toString();

    return DataRow(cells: [
      DataCell(Text(date)),
      DataCell(Text(inTime)),
      DataCell(Text(outTime)),
      DataCell(Text(hrs)),
    ]);
  }
}
