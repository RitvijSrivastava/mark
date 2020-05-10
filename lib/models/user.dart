class User {
  String userId;
  String emailId;

  User({this.userId, this.emailId});

  User.map(dynamic obj) {
    userId = obj['userId'];
    emailId = obj['emailId'];
  }

  String get id => userId;
  String get email => emailId;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String , dynamic>();

    map['userId'] = userId;
    map['emailId'] = emailId;

    return map;

  }

  User.fromMap(Map<dynamic,dynamic> map) {
    this.userId = map['userId'];
    this.emailId = map['emailId'];
  }

}