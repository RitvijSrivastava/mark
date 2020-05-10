class Store {
  String storeId;
  String radius;
  List location = new List();

  Store({this.radius, this.storeId, this.location});

  Store.map(dynamic obj) {
    this.storeId = obj['storeId'];
    this.location = obj['location'];
    this.radius = obj['radius'];
  }

  String get id => storeId;
  String get rad => radius;
  List get loc => location;


  Map<dynamic, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['storeId'] = storeId;
    map['location'] = location;
    map['radius'] = radius;

    return map;
  }

  Store.fromMap(Map<dynamic, dynamic> map) {
    this.storeId = map['storeId'];
    this.location = map['location'];
    this.radius = map['radius'];
  }

}