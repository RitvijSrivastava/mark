import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  String checkIn;
  String checkOut;
  String hrsSpent;
  String userId;

  History({this.hrsSpent, this.userId, this.checkIn, this.checkOut});

  History.map(dynamic obj) {
    userId = obj['userId'];
    checkIn = obj['checkIn'];
    checkOut = obj['checkOut'];
    hrsSpent = obj['hrsSpent'];
  }

  String get id => userId;
  String get checkin => checkIn;
  String get checkout => checkOut;
  String get hours => hrsSpent;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['userId'] = userId;
    map['checkIn'] = checkIn;
    map['checkOut'] = checkOut;
    map['hrsSpent'] = hrsSpent;

    return map;
  }

  History.fromMap(Map<dynamic, dynamic> map) {
    this.userId = map['userId'];
    this.checkIn = map['checkIn'];
    this.checkOut = map['checkOut'];
    this.hrsSpent = map['hrsSpent'];
  }

  History.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}
