import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class FaceRecognition {
  Dio dio = Dio();

  Response response;

  String rapidAPIKey = "bd14e23e9amsh1c0a5c8cbab1c0dp13e60cjsnd901e70f5344";
  String kairosURL = "kairosapi-karios-v1.p.rapidapi.com";

  FaceRecognition() {
    dio.options.headers = {
      "x-rapidapi-host": kairosURL,
      "x-rapidapi-key": rapidAPIKey,
      "content-type": "application/json",
    };
  }

  //Enroll Image in the database
  Future<Response> enrollImage(File file, String subjectId) async {
    // TODO: Add the gallery name according to the name of the store

    dio.options.headers = {
      "x-rapidapi-host": kairosURL,
      "x-rapidapi-key": rapidAPIKey,
      "content-type": "application/json",
    };

    try {
      String base64Image = base64Encode(file.readAsBytesSync());

      response = await dio.post(
        "https://kairosapi-karios-v1.p.rapidapi.com/enroll",
        data: {
          "image": base64Image,
          "gallery_name": "TestPOC",
          "subject_id": subjectId,
        },
      );

      // print("INSISE TRY: ");
      // print("RESPOSNSE: " + response.toString());
      print("YO; ${response.data.toString()}");
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(e.request);
        print(e.message);
      }
    }

    return response;
  }

  //Recognize Image
  Future<Response> recogImage(File file) async {
    // TODO: Receive the store name also

    dio.options.headers = {
      "x-rapidapi-host": kairosURL,
      "x-rapidapi-key": rapidAPIKey,
      "content-type": "application/json",
    };

    try {
      String base64Image = base64Encode(file.readAsBytesSync());

      response = await dio.post(
        "https://kairosapi-karios-v1.p.rapidapi.com/recognize",
        data: {
          "image": base64Image,
          "gallery_name": "TestPOC",
        },
      );
      // print("RESPOSNSE: " + response.toString());

    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        print(e.request);
        print(e.message);
      }
    }

    return response;
  }
}