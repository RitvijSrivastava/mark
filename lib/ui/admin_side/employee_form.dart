import 'package:attendance/models/employee.dart';
import 'package:attendance/models/store.dart';
import 'package:attendance/models/user.dart';
import 'package:attendance/services/authentication.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/services/validate.dart';
import 'package:flutter/material.dart';

class EmployeeForm extends StatefulWidget {
  final BaseAuth auth;
  final List<Store> stores;

  EmployeeForm({@required this.auth, @required this.stores});

  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>(); // Form Key

  Store _dropdownValue; // Current dropdown value

  List<DropdownMenuItem<Store>> _items; // Store all the drop down menu items

  Validate validate; // Class handling validation of form fields

  bool _isUploading = false;

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

  bool _autoValidate;

  @override
  void initState() {
    super.initState();
    _autoValidate = false;
    validate = new Validate();
    _items = _buildDropdownMenuItem();
    _dropdownValue = widget.stores[0];
    _formKey.currentState?.reset();
  }

  /// Build Drop Down Menu Item
  List<DropdownMenuItem<Store>> _buildDropdownMenuItem() {
    var tempList = [];
    tempList = widget.stores.map((Store store) {
      return DropdownMenuItem<Store>(value: store, child: Text(store.name));
    }).toList();
    return tempList;
  }

  /// Upload Data to Firebase Storage
  _uploadToFirebase() async {
    FirebaseService firebaseService = new FirebaseService();

    // Create a user
    userId = await widget.auth.signUp(emailId, password);

    // Create a User and Map
    User user = new User(
      userId: userId,
      emailId: emailId,
    );
    Map<String, dynamic> userMap = user.toMap();

    // Create location list
    List location = new List();
    location.add(_dropdownValue.location[0].toString());
    location.add(_dropdownValue.location[1].toString());

    // Create an employee and its map
    Employee emp = new Employee(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      storeId: "123",
      imageId: null,
      emailId: emailId,
      phoneNumber: mobile,
      specialization: expertise,
      aadharNumber: aadhar,
      address: address,
      experience: experience,
      radius: _dropdownValue.radius,
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
    if (_formKey.currentState.validate()) {
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
      setState(() {
        _autoValidate = true;
      });
    }
  }

  /// Reset Form
  _resetForm() {
    _formKey.currentState.reset();
    setState(() {
      _autoValidate = false;
      _isUploading = false;
    });
  }

  /// Toggle visibility of user form
  _toggleForm() {
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Employee Form"),
      ),
      body: _isUploading
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
                        Container(
                          height: MediaQuery.of(context).size.height * 0.08,
                          padding: EdgeInsets.only(left: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Store:     ",
                                textScaleFactor: 1.4,
                              ),
                              DropdownButton<dynamic>(
                                  value: _dropdownValue,
                                  icon: Icon(Icons.arrow_downward),
                                  iconSize: 26,
                                  elevation: 16,
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 23.0,
                                  ),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  items: _items,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _dropdownValue = newValue;
                                    });
                                  }),
                            ],
                          ),
                        ),
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
            ),
    );
  }

  /// Adds a constant space between two widgets
  Widget _buildSpace({double height = 15.0}) {
    return SizedBox(
      height: height,
    );
  }
}
