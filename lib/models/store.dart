import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  String storeId;
  String radius;
  String storeName;
  List location = new List();

  Store({this.radius, this.storeId, this.location, this.storeName});

  Store.map(dynamic obj) {
    this.storeId = obj['storeId'];
    this.location = obj['location'];
    this.radius = obj['radius'];
    this.storeName = obj['storeName'];
  }

  String get id => storeId;
  String get rad => radius;
  String get name => storeName;
  List get loc => location;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['storeId'] = storeId;
    map['location'] = location;
    map['radius'] = radius;
    map['storeName'] = storeName;

    return map;
  }

  Store.fromMap(Map<dynamic, dynamic> map) {
    this.storeId = map['storeId'];
    this.location = map['location'];
    this.radius = map['radius'];
    this.storeName = map['storeName'];
  }

  Store.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}
