import 'package:attendance/models/employee.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final VoidCallback logoutCallback;

  ProfilePage({this.userId, this.logoutCallback});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseService history = new FirebaseService();
  String userId;

  @override
  void initState() {
    super.initState();
  }

  /// Adds a constant space between two widgets
  Widget _buildSpace({double height = 15.0}) {
    return SizedBox(
      height: height,
    );
  }

  ///Widget to build columns inside Rows
  Widget _buildColumn(
      {String label,
      String content,
      double height = 100.0,
      double width: 140.0}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: height,
          width: width,
          child: TextFormField(
            maxLines: height > 100 ? 3 : 1,
            initialValue: content,
            style: TextStyle(
              fontSize: 17.0,
            ),
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
          ),
        )
      ],
    );
  }

  /// Widget to build Rows
  Widget _buildRow(
      {String label1, String label2, String content1, String content2}) {
    return Form(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildColumn(label: label1, content: content1),
          _buildColumn(label: label2, content: content2),
        ],
      ),
    );
  }

  /// Builds Address widget (expanded height)
  Widget _buildAddressRow(
      {String label1, String label2, String content1, String content2}) {
    return Form(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildColumn(label: label1, content: content1, height: 150.0),
        _buildColumn(label: label2, content: content2),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('employees')
            .where("userId", isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Employee emp = Employee.fromMap(snapshot.data.documents[0].data);
          // print("IMGE ID: " + emp.imageId);

          return ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        child: ClipOval(
                          child: Center(
                            child: Image.network(
                              emp.image,
                              width: 700,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                );
                              },
                            ),
                          ),
                        ),
                        radius: 80.0,
                      ),
                    ],
                  ),
                  _buildSpace(),
                  _buildSpace(),
                  _buildRow(
                    label1: "First Name",
                    label2: "Last Name",
                    content1: emp.first,
                    content2: emp.last,
                  ),
                  _buildRow(
                    label1: "Email Id",
                    label2: "Mobile",
                    content1: emp.email,
                    content2: emp.phone,
                  ),
                  _buildRow(
                    label1: "Experience",
                    label2: "Expertise",
                    content1:
                        emp.exp == "1" ? emp.exp + " year" : emp.exp + " years",
                    content2: emp.specialization,
                  ),
                  _buildAddressRow(
                      label1: "Address",
                      label2: "Aadhar No.",
                      content1: emp.addr,
                      content2: emp.aadhar),
                  Center(
                    child: MaterialButton(
                      padding: EdgeInsets.all(12.0),
                      textColor: Colors.white,
                      onPressed: widget.logoutCallback,
                      child: Text(
                        "Sign Out",
                        textScaleFactor: 1.2,
                      ),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
