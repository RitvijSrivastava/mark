import 'dart:io';

import 'package:attendance/models/history.dart';
import 'package:attendance/services/face_recognition.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

// TODO: Mapbox in location

class MarkAttendancePage extends StatefulWidget {
  final String userId;

  MarkAttendancePage({this.userId});

  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  File _image; // Store the image

  String msgFace; // [Verify Face], [Success], [Retry]
  bool _statusFace;

  String msgLocation; // [Verify Face], [Success], [Retry]
  bool _statusLocation;

  DateTime checkInTime; // Store the check In Time
  DateTime checkOutTime; // Store the check out Time

  int _currentStep; // Store the index of current step

  @override
  void initState() {
    super.initState();
    _image = null;
    _statusFace = false;
    _statusLocation = false;
    _currentStep = 0;
    msgFace = "Verify Face";
    msgLocation = "Verify Location";
  }

  // Pick Image from the camera
  Future getImage() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.front,
    );
    setState(() {
      _image = image;
    });
  }

  /// Recognize face and return wether it matches or not
  Future<void> verifyFace() async {
    FaceRecognition faceRecognition = new FaceRecognition();
    await getImage();
    if(_image == null) return;
    var statusFace = await faceRecognition.recogImage(_image, widget.userId);
    setState(() {
      _statusFace = statusFace;
      msgFace = statusFace ? "Verified" : "Face not verified. Retry!";
    });
  }

  /// Verify Location
  Future<void> verifyLocation() async {
    // First Retrieve [location] and [radius] from firebase
    FirebaseService firebaseService = new FirebaseService();
    var documentSnapshot =
        await firebaseService.getSpecificData('employees', widget.userId);
    List _storeLocation = documentSnapshot.data['location'].toList();
    double storeLat = double.parse(_storeLocation[0]);
    double storeLong = double.parse(_storeLocation[1]);
    double storeRadius =
        double.parse(documentSnapshot.data['radius'].toString());

    // Get the user's current location
    LocationService locationService = new LocationService();
    var position = await Geolocator().getCurrentPosition();
    if (position == null) return;

    bool statusLocation = locationService.getDistance(position.latitude,
        position.longitude, storeLat, storeLong, storeRadius);
    setState(() {
      _statusLocation = statusLocation;
      msgLocation =
          statusLocation ? "Verified" : "Location not Verified. Retry!";
    });

    if (_statusFace && _statusLocation) {
      checkIn();
    }
  }

  // Check In
  checkIn() {
    DateTime _checkInTime = DateTime.now();
    setState(() {
      checkInTime = _checkInTime;
    });
  }

  // Check Out
  checkOut() async {
    DateTime _checkOutTime = DateTime.now();
    setState(() {
      checkOutTime = _checkOutTime;
    });

    Duration diff = checkOutTime.difference(checkInTime);
    int hrsSpent = diff.inHours;

    History history = new History(
      userId: widget.userId,
      checkIn: checkInTime.toString(),
      checkOut: checkOutTime.toString(),
      hrsSpent: hrsSpent.toString(),
    );

    Map<String, dynamic> map = history.toMap();

    FirebaseService firebaseService = new FirebaseService();
    await firebaseService.addData('history', map);

    //Set status as false
    setState(() {
      _statusFace = false;
      _statusLocation = false;
      _currentStep = 0;
      msgFace = "Verify Face";
      msgLocation = "VerifyLocation";
    });
  }

  /// Define what will happen on clicking on continue
  next() {
    if (_currentStep == 0 && _statusFace) {
      setState(() {
        _currentStep += 1;
      });
    }
    if (_currentStep == 1 && _statusLocation && _statusFace) {
      checkIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _statusFace && _statusLocation
          ? Center(
              child: MaterialButton(
                onPressed: checkOut,
                child: Text(
                  "Check Out",
                  textScaleFactor: 1.2,
                ),
                color: Colors.red,
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(10.0,30.0,10.0,10.0),
              child: ListView(
                // margin: EdgeInsets.only(top: 10.0),
                children: [
                  Stepper(
                    onStepContinue: next,
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    steps: <Step>[
                      Step(
                        title: Text(
                          "Face Verification",
                          textScaleFactor: 1.3,
                        ),
                        content: MaterialButton(
                          
                          padding: EdgeInsets.all(13.0),
                          onPressed: verifyFace,
                          textColor: Colors.white,
                          child: Text(
                            msgFace,
                            textScaleFactor: 1.1,
                            
                          ),
                          color: msgFace == "Verified" ? Colors.green : Colors.orange,
                        ),
                        isActive: (_currentStep == 0),
                      ),
                      Step(
                        title: Text(
                          "Location Verification",
                          textScaleFactor: 1.3,
                        ),
                        content: MaterialButton(
                          padding: EdgeInsets.all(13.0),
                          onPressed: verifyLocation,
                          textColor: Colors.white,
                          child: Text(
                            msgLocation,
                            textScaleFactor: 1.1,
                          ),
                          color: msgLocation == "Verified" ? Colors.green : Colors.orange,
                        ),
                        isActive: (_currentStep == 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
