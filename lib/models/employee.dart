class Employee {
  String userId;
  String storeId;
  String imageId;
  String firstName;
  String lastName;
  String emailId;
  String phoneNumber;
  String specialization;
  String aadharNumber;
  String address;
  String experience;
  String radius;
  List location = new List();

  Employee(
      {this.userId,
      this.firstName,
      this.lastName,
      this.emailId,
      this.location,
      this.phoneNumber,
      this.specialization,
      this.storeId,
      this.imageId,
      this.aadharNumber,
      this.address,
      this.experience,
      this.radius});

  Employee.map(dynamic obj) {
    this.userId = obj['userId'];
    this.firstName = obj['firstName'];
    this.lastName = obj['lastName'];
    this.emailId = obj['emailId'];
    this.phoneNumber = obj['phoneNumber'];
    this.specialization = obj['specialization'];
    this.location = obj['location'];
    this.storeId = obj['storeId'];
    this.imageId = obj['imageId'];
    this.aadharNumber = obj['aadharNumber'];
    this.address = obj['address'];
    this.radius = obj['radius'];
    this.experience = obj['experience'];
  }

  String get id => userId;
  String get first => firstName;
  String get last => lastName;
  String get phone => phoneNumber;
  String get email => emailId;
  String get expertise => specialization;
  String get storeID => storeId;
  String get image => imageId;
  String get aadhar => aadharNumber;
  String get addr => address;
  String get exp => experience;
  String get rad => radius;
  List get loc => location;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['userId'] = userId;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['emailId'] = emailId;
    map['phoneNumber'] = phoneNumber;
    map['specialization'] = specialization;
    map['location'] = location;
    map['storeId'] = storeId;
    map['imageId'] = imageId;
    map['aadharNumber'] = aadharNumber;
    map['address'] = address;
    map['experience'] = experience;
    map['radius'] = radius;

    return map;
  }

  Employee.fromMap(Map<dynamic, dynamic> map) {
    this.userId = map['userId'];
    this.firstName = map['firstName'];
    this.lastName = map['lastName'];
    this.emailId = map['emailId'];
    this.phoneNumber = map['phoneNumber'];
    this.specialization = map['specialization'];
    this.location = map['location'];
    this.storeId = map['storeId'];
    this.imageId = map['imageId'];
    this.aadharNumber = map['aadharNumber'];
    this.address = map['address'];
    this.experience = map['experience'];
    this.radius = map['radius'];
  }
}
