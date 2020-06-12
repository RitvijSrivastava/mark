import 'package:attendance/services/validate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance/services/authentication.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback loginCallback;
  final BaseAuth auth;

  LoginPage({this.loginCallback, this.auth});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _phoneNumber;
  String _smsCode;
  String _verId;
  String _errorMessage;

  bool _isLoading;
  bool _isPhone;
  bool _codeSent = false;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _codeSent = false;
    _isPhone = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void toggleEmailAndPhone() {
    setState(() {
      _isPhone = !_isPhone;
    });
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_codeSent) {
          userId = await widget.auth.signInWithOTP(_smsCode, _verId);
          print("Signed in using $userId");
        } else {
          userId = await widget.auth.signInWithEmail(_email, _password);
          print("Signed in using $userId");
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      widget.auth.signIn(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this._verId = verId;
      setState(() {
        this._codeSent = true;
      });
      print("Verification Id: $_verId");
      resetForm(); // reset form after accepting phone number
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this._verId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91" + phoneNo,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verified,
      verificationFailed: verificationfailed,
      codeSent: smsSent,
      forceResendingToken: 60,
      codeAutoRetrievalTimeout: autoTimeout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _showForm(),
          _showCircularProgress(),
        ],
      ),
    );
  }

   Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              !_isPhone ? showEmailInput() : Container(),
              !_isPhone ? showPasswordInput() : Container(),
              _isPhone ? showPhoneInput() : Container(),
              SizedBox(
                height: 10.0,
              ),
              showErrorMessage(),
              showPrimaryButton(),
              SizedBox(
                height: 15.0,
              ),
              _codeSent ? Container() : showSecondaryButton(),
            ],
          ),
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPhoneInput() {
    return _codeSent
        ? showSmsCodeInput()
        : Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: TextFormField(
              maxLines: 1,
              obscureText: false,
              autofocus: false,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone Number",
                icon: Icon(
                  Icons.phone,
                  color: Colors.grey,
                ),
              ),
              validator: (value) => value.isEmpty
                  ? 'Number can\'t be empty'
                  : new Validate().verfiyMobile(value),
              onChanged: (value) => _phoneNumber = value.trim(),
              onSaved: (value) => _phoneNumber = value.trim(),
            ),
          );
  }

  Widget showSmsCodeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: false,
        autofocus: false,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "Enter OTP",
          icon: Icon(
            Icons.keyboard,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty
            ? 'Number can\'t be empty'
            : new Validate().verifyOTP(value),
        onSaved: (value) => _smsCode = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: new Text(
            _isPhone ? (_codeSent ? 'Login' : 'Verify Phone') : 'Login',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          onPressed: () => {
            _isPhone
                ? (_codeSent ? validateAndSubmit() : verifyPhone(_phoneNumber))
                : validateAndSubmit()
          },
        ),
      ),
    );
  }

  Widget showSecondaryButton() {
    return InkWell(
      onTap: toggleEmailAndPhone,
      child: Center(
        child: _isPhone
            ? Text(
                "Sign in with Email",
                textScaleFactor: 1.1,
              )
            : Text(
                "Sign in with Phone Number",
                textScaleFactor: 1.1,
              ),
      ),
    );
  }
}
