import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: Add Fields for editing other factors too
class Approval {
  String empId;
  String empName;
  String imageId;

  Approval({this.empId, this.empName, this.imageId});

  Approval.map(dynamic obj) {
    this.empId = obj['empId'];
    this.empName = obj['empName'];
    this.imageId = obj['imageId'];
  }

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['empId'] = empId;
    map['empName'] = empName;
    map['imageId'] = imageId;
    return map;
  }

  Approval.fromMap(Map<dynamic, dynamic> map) {
    this.empId = map['empId'];
    this.empName = map['empName'];
    this.imageId = map['imageId'];
  }

  Approval.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}
