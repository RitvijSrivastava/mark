import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  /// Add a map to a firestore collection
  Future<DocumentReference> addData(
      collectionName, Map<dynamic, dynamic> map) async {
    return await Firestore.instance
        .collection(collectionName)
        .add(map)
        .catchError((e) {
      print(e);
    });
  }

  /// Store data with user specified document ID
  Future<void> addSpecificData(
      collectionName, docId, Map<dynamic, dynamic> map) async {
    return await Firestore.instance
        .collection(collectionName)
        .document(docId)
        .setData(map)
        .catchError((e) => print(e));
  }

  /// Read from a collection
  getData(collectionName) async {
    return await Firestore.instance.collection(collectionName).getDocuments();
  }

  /// Read from a specific document
  getSpecificData(collectionName, docName) async {
    return await Firestore.instance
        .collection(collectionName)
        .document(docName)
        .get();
  }

  /// Update a document in firebase
  updateData(selectedDoc, collectionName, Map<String, dynamic> newMap) async {
    return await Firestore.instance
        .collection(collectionName)
        .document(selectedDoc)
        .updateData(newMap);
  }

  /// Delete a document from firebase
  deleteData(collectionName, selectedDoc) async {
    return await Firestore.instance
        .collection(collectionName)
        .document(selectedDoc)
        .delete();
  }
}
