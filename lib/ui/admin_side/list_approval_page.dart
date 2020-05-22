import 'package:attendance/models/approval.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/services/firebase_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListApprovalPage extends StatefulWidget {
  @override
  _ListApprovalPageState createState() => _ListApprovalPageState();
}

class _ListApprovalPageState extends State<ListApprovalPage> {
  /// Build List of Approvals
  _buildList(List<DocumentSnapshot> snapshots) {
    return snapshots.map((snapshot) => _buildListItem(snapshot)).toList();
  }

  /// Build a List Item
  _buildListItem(DocumentSnapshot snapshot) {
    Approval approval = Approval.fromSnapshot(snapshot);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ImageApprovalPage(approval: approval))),
        leading: CircleAvatar(
          radius: 25,
          child: ClipOval(
            child: Center(
              child: Image.network(
                approval.imageId,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  );
                },
              ),
            ),
          ),
        ),
        title: Text(
          "${approval.empName}",
          textScaleFactor: 1.2,
        ),
        trailing: Icon(Icons.chevron_right, size: 40.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance.collection('approvals').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data == null) {
              return Center(
                child: Text(
                  "No Approvals Found!",
                  textScaleFactor: 1.3,
                  maxLines: 2,
                ),
              );
            }

            var _approvalList = _buildList(snapshot.data.documents);

            return ListView.builder(
              itemCount: _approvalList.length,
              itemBuilder: (context, index) => _approvalList[index],
            );
          }),
    );
  }
}

class ImageApprovalPage extends StatefulWidget {
  final Approval approval;

  ImageApprovalPage({@required this.approval});

  @override
  _ImageApprovalPageState createState() => _ImageApprovalPageState();
}

class _ImageApprovalPageState extends State<ImageApprovalPage> {
  bool _isWorking;

  /// Add Image to the user database when approved
  _onApprove() async {
    // Set working to true
    _toggleWorking();

    // add the [imageId] in the user database
    FirebaseService firebaseService = new FirebaseService();
    firebaseService.updateData(widget.approval.empId, 'employees',
        {'imageId': widget.approval.imageId});

    // remove this from the list of approvals
    await _deleteEntry();
  }

  /// Delete this entry and the image from the firebase storage
  _onDeny() async {
    _toggleWorking();

    //Remove image from firebase storage
    FirebaseStorageService firebaseStorageService =
        new FirebaseStorageService();
    await firebaseStorageService.deleteFile(widget.approval.imageId);

    //Remove this from the list of approvals
    await _deleteEntry();
  }

  /// Delete this entry from firebase
  _deleteEntry() async {
    FirebaseService firebaseService = new FirebaseService();

    // Delete Entry from list of approvals
    firebaseService.deleteData('approvals', widget.approval.empId);

    //toggle working state and pop back
    _toggleWorking();
    Navigator.of(context).pop();
  }

  /// Toggle Circular Progress Indicator
  _toggleWorking() {
    setState(() {
      _isWorking = !_isWorking;
    });
  }

  @override
  void initState() {
    super.initState();
    _isWorking = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approve Image"),
      ),
      body: _isWorking
          ? Center(
              child: ListView(
                children: <Widget>[
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 12.0),
                  Center(
                    child: Text(
                      "Processing...",
                      textScaleFactor: 1.3,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              children: <Widget>[
                Center(
                  child: Image.network(
                    widget.approval.imageId,
                    height: 120,
                    width: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                            : null,
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        padding: EdgeInsets.all(12.0),
                        onPressed: _onApprove,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(
                          "APPROVE",
                          textScaleFactor: 1.3,
                        ),
                      ),
                      MaterialButton(
                        padding: EdgeInsets.all(12.0),
                        onPressed: _onDeny,
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text(
                          "DENY",
                          textScaleFactor: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
