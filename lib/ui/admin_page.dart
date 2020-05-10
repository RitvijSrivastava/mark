import 'dart:io';

import 'package:attendance/services/authentication.dart';
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

  File _image;

  uploadFile() {
    chooseFile().then((_) {
      print("PRIGINAL: " + _image.path);
      new FirebaseStorageService().uploadFile(_image);
    });
  }

  Future chooseFile() async {    
   await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {    
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
      body: Center(
        child: MaterialButton(
          child: Text("Pick Image"),
          onPressed: uploadFile,
        )
      ),
    );
  }
}