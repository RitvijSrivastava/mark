import 'package:attendance/models/approval.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovalPage extends StatefulWidget {
  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
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
        onTap: null,
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
    // TODO: Build Approval Page

    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance.collection('approval').snapshots(),
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
