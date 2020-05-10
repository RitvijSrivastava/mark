import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  var _url = 'mailto:query@marks-retech.in';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Facing Issues?",
              textScaleFactor: 1.5,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            RichText(
              textScaleFactor: 1.2,
              text: TextSpan(children: [
                TextSpan(
                  text: "Send your queries at: ",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                    text: "query@marks-retech.in",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launch(_url);
                      }),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
