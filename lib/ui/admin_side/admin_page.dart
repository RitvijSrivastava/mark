import 'dart:io';

import 'package:attendance/models/employee.dart';
import 'package:attendance/models/user.dart';
import 'package:attendance/services/authentication.dart';
import 'package:attendance/services/face_recognition.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/services/firebase_storage_service.dart';
import 'package:attendance/services/validate.dart';
import 'package:attendance/ui/admin_side/list_employee_page.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  List appBarText = [
    'Home',
    'Employees'
  ]; // Text appearing as the title of pages
  int _currentIndex = 0; // stores the current index of page
  PageController _pageController;

  bool _isUploading = false;
  bool _isUserForm = false;

  Validate validate = new Validate();

  File image;
  String firstName,
      lastName,
      emailId,
      password,
      experience,
      expertise,
      imageId,
      userId,
      mobile,
      aadhar,
      address,
      radius,
      latitude,
      longitude;

  String _msgLocation;
  String _msgImage;

  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Upload Data to Firebase Storage
  _uploadToFirebase() async {
    FirebaseService firebaseService = new FirebaseService();
    FaceRecognition faceRecognition = new FaceRecognition();

    // Create a user
    userId = await widget.auth.signUp(emailId, password);

    // Upload Image
    String imageId = await _uploadImage(image);

    // Upload the image to image recognition api
    await faceRecognition.enrollImage(image, userId);

    // Create a User and Map
    User user = new User(
      userId: userId,
      emailId: emailId,
    );
    Map<String, dynamic> userMap = user.toMap();

    // Create location list
    List location = new List();
    location.add(latitude);
    location.add(longitude);

    // Create an employee and its map
    Employee emp = new Employee(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      storeId: "123",
      imageId: imageId,
      emailId: emailId,
      phoneNumber: mobile,
      specialization: expertise,
      aadharNumber: aadhar,
      address: address,
      experience: experience,
      radius: radius,
      location: location,
    );

    //Create employee map
    Map<String, dynamic> empMap = emp.toMap();

    //Upload to firebase
    await firebaseService.addData("users", userMap);
    await firebaseService.addSpecificData("employees", userId, empMap);
  }

  /// Submit form after validating it
  _submitForm() async {
    if (_formKey.currentState.validate() &&
        latitude != null &&
        longitude != null &&
        validate.verifyImage(image) == null) {
      // Save form
      _formKey.currentState.save();

      //Set isUploading to true
      setState(() {
        _isUploading = true;
      });

      // upload files to firebase
      await _uploadToFirebase();

      //toggleForm
      _toggleForm();
    } else {
      _msgLocation = null;
      _msgImage = null;

      String msg1, msg2;

      if (latitude == null) msg1 = "Location Not Found";
      if (image == null) msg2 = "Image Not Found";
      setState(() {
        _autoValidate = true;
        _msgLocation = msg1;
        _msgImage = msg2;
      });
    }
  }

  /// Uploads an image to Firebase Storage
  _uploadImage(File image) async {
    return await new FirebaseStorageService().uploadFile(image);
  }

  /// Get Location using Geolocator
  Future _getLocation() async {
    await Geolocator().getCurrentPosition().then((position) {
      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });
    });
  }

  /// Use ImagePicker to pick an image from the camera
  Future _chooseImage() async {
    await ImagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    ).then((img) {
      setState(() {
        image = img;
      });
    });
  }

  /// Reset Form
  _resetForm() {
    // _formKey.currentState.reset();
    setState(() {
      _autoValidate = false;
      _isUploading = false;
    });
  }

  /// Toggle visibility of user form
  _toggleForm() {
    _resetForm();
    setState(() {
      _isUserForm = !_isUserForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText[_currentIndex]),
        actions: <Widget>[
          IconButton(
            onPressed: widget.logoutCallback,
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          _isUserForm
              ? formUI()
              : Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Image.asset('assets/logo.png'),),
                    SizedBox(height: 25.0,),
                  Center(
                      child: MaterialButton(
                        textColor: Colors.white,
                        color: Colors.lightBlue,
                        padding: EdgeInsets.all(16.0),
                        onPressed: _toggleForm,
                        child: Text(
                          "Add Employee",
                          textScaleFactor: 1.3,
                        ),
                      ),
                    ),
                ],
              ),
          ListEmployeePage(),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          _pageController.jumpToPage(index);
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.red,
            inactiveColor: Colors.black,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text("Employees"),
            activeColor: Colors.purpleAccent,
            inactiveColor: Colors.black,
          ),
        ],
      ),
    );
  }

  /// Adds a constant space between two widgets
  Widget _buildSpace({double height = 15.0}) {
    return SizedBox(
      height: height,
    );
  }

  ///Form UI
  Widget formUI() {
    return _isUploading
        ? Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              _buildSpace(),
              Text(
                "Uploading...",
                textScaleFactor: 1.5,
              ),
            ],
          ))
        : SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(15.0),
              child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: _toggleForm,
                          ),
                        ],
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (name) => validate.verifyName(name),
                        onSaved: (value) {
                          firstName = value;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "First Name",
                          hintText: "John",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (name) => validate.verifyName(name),
                        onSaved: (value) {
                          lastName = value;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Last Name",
                          hintText: "Doe",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (email) => validate.verifyEmail(email),
                        onSaved: (value) {
                          emailId = value;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email Name",
                          hintText: "you@example.com",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (password) =>
                            validate.verifyPassword(password),
                        onSaved: (value) {
                          password = value;
                        },
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Password",
                          hintText: "P@ssword!123",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (addr) => validate.verifyAddress(addr),
                        onSaved: (value) {
                          address = value;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Address",
                          hintText: "123/131/J, Nagar",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (mobile) => validate.verfiyMobile(mobile),
                        onSaved: (value) {
                          mobile = value;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Mobile Number",
                          hintText: "9450032010",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (add) => validate.verifyAadhar(add),
                        onSaved: (value) {
                          aadhar = value;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Aadhar Number",
                          hintText: "123456789376",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (exp) => validate.verifyExpertise(exp),
                        onSaved: (value) {
                          expertise = value;
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Expertise",
                          hintText: "Haircut",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (exp) => validate.verifyExperience(exp),
                        onSaved: (value) {
                          experience = value;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Experience (in  years)",
                          hintText: "2",
                        ),
                      ),
                      _buildSpace(),
                      TextFormField(
                        minLines: 1,
                        maxLines: 8,
                        validator: (rad) => validate.verifyRadius(rad),
                        onSaved: (value) {
                          radius = value;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Radius (in meters)",
                          hintText: "10",
                        ),
                      ),
                      _buildSpace(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          MaterialButton(
                            textColor: Colors.black,
                            padding: EdgeInsets.all(10.0),
                            color: Colors.pink[50],
                            onPressed: _chooseImage,
                            child: Column(
                              children: <Widget>[
                                Text("Choose Image", textScaleFactor: 1.2),
                                SizedBox(height: 5.0),
                                _msgImage == null
                                    ? Center()
                                    : Text(
                                        _msgImage,
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ],
                            ),
                          ),
                          MaterialButton(
                            textColor: Colors.black,
                            padding: EdgeInsets.all(10.0),
                            onPressed: _getLocation,
                            color: Colors.greenAccent,
                            child: Column(
                              children: <Widget>[
                                Text("Get Location", textScaleFactor: 1.2),
                                SizedBox(height: 5.0),
                                _msgLocation == null
                                    ? Center()
                                    : Text(
                                        _msgLocation,
                                        style: TextStyle(color: Colors.red),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildSpace(),
                      _buildSpace(height: 20.0),
                      Center(
                        child: MaterialButton(
                          padding: EdgeInsets.all(13.0),
                          onPressed: _submitForm,
                          textColor: Colors.white,
                          color: Colors.blue,
                          child: Text(
                            "  SUBMIT  ",
                            textScaleFactor: 1.3,
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          );
  }
}
