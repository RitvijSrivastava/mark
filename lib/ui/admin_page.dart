import 'dart:io';

import 'package:attendance/models/employee.dart';
import 'package:attendance/models/user.dart';
import 'package:attendance/services/authentication.dart';
import 'package:attendance/services/face_recognition.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback logoutCallback;

  AdminPage({this.auth, this.logoutCallback});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>(); // Form Key

  File _image; // Stores the image

  /// Callback to the form to process the information and upload it to the DB
  void formCallback(
      {String email,
      String password,
      String latitude,
      String longitude,
      File image,
      String firstName,
      String lastName,
      String radius}) async {
    FirebaseService firebaseService = new FirebaseService();
    FaceRecognition faceRecognition = new FaceRecognition();

    String userUID = ""; // Store the uid of the user created
    //Create a user first
    if (email != null && password != null) {
      userUID = await widget.auth.signUp(email, password);
    } else {
      return;
    }

    //upload the image to the database
    var imageURL = await uploadFile(image);

    //Enroll the image to the KAIROS database
    await faceRecognition.enrollImage(image, userUID);

    List location = new List();
    location.add(latitude);
    location.add(longitude);

    // Create its employee database
    Employee emp = new Employee(
      userId: userUID,
      storeId: "abc",
      imageId: imageURL.toString(),
      firstName: firstName,
      lastName: lastName,
      emailId: email,
      phoneNumber: "9653049126",
      specialization: "Haircut",
      aadharNumber: "12345678910",
      address: "Rail Nagaar",
      experience: "3",
      radius: radius,
      location: location,
    );

    //Create a map of employee
    Map<String, dynamic> map = emp.toMap();

    //Upload it to the firebase
    firebaseService.updateData(userUID, 'employees', map);

    User user = new User(emailId: email, userId: userUID);
    map = emp.toMap();

    firebaseService.updateData(userUID, 'users', map);

  }

  @override
  void initState() {
    super.initState();
    _image = null;
  }

  /// Uploads an image to Firebase Storage
  uploadFile(File image) async {
    return await new FirebaseStorageService().uploadFile(image);
  }

  /// Use ImagePicker to pick an image from the camera
  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _image = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[

          ],
        ),
      ),
    );
  }
}
