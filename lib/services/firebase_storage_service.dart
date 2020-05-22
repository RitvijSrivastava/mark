import 'dart:io';
import 'package:path/path.dart' as Path;

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  // Uploads a file to Firebase Storage and returns the path to its location
  Future<dynamic> uploadFile(File image) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/${Path.basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    print("FILE: " + url);
    return url;
  }

  deleteFile(String imageFileUrl) async {
    var fileUrl = Uri.decodeFull(Path.basename(imageFileUrl))
        .replaceAll(new RegExp(r'(\?alt).*'), '');

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileUrl);
    await firebaseStorageRef.delete();
  }
}
