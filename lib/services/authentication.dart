import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(AuthCredential authCredential);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<String> signInWithOTP(String smsCode, String verificationId);

  Future<String> signInWithEmail(String email, String password);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(AuthCredential authCredential) async {
    AuthResult result =
        await _firebaseAuth.signInWithCredential(authCredential);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;

    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<String> signInWithOTP(String smsCode, String verificationId) async {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);
    return await signIn(authCreds);
  }

  Future<String> signInWithEmail(String email, String password) async {
    AuthCredential authCreds =
        EmailAuthProvider.getCredential(email: email, password: password);
    return await signIn(authCreds);
  }
}
