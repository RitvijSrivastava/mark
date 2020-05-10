import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  // Add a map to a firestore collection
  Future<void> addData(collectionName, Map<dynamic,dynamic> map) async {
    Firestore.instance.collection(collectionName).add(map).catchError((e) {
      print(e);
    });
  }

  // Read from a collection
  getData(collectionName) async {
    return await Firestore.instance.collection(collectionName).getDocuments();
  }

  // Read from a specific document
  getSpecificData(collectionName, docName) async {
    return await Firestore.instance.collection(collectionName).document(docName).get();
  }

  //Update a document in firebase
  updateData(selectedDoc, collectionName, Map<String,dynamic> newMap) {
    Firestore.instance.collection(collectionName).document(selectedDoc).updateData(newMap);
  }
}