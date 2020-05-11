import 'dart:io';
import 'package:string_validator/string_validator.dart';

class Validate {
  /// Name Verification
  verifyName(String name) {
    bool isValid = isAlpha(name);
    if (isValid)
      return null;
    else
      return "Invalid Name";
  }

  /// Email Verification
  verifyEmail(String email) {
    bool isValid = isEmail(email);
    if (!isValid) return "Invalid Email Address";
    return null;
  }

  /// Password Verification
  verifyPassword(String password) {
    if (password.length < 8 || password.length > 20) {
      return "Password length should be greater than 8 and less than 20";
    }
    return null;
  }

  /// Phone Number verification
  verfiyMobile(String mobile) {
    if (mobile.length != 10) {
      return "Enter a valid phone number";
    }
    bool isValid = isNumeric(mobile);
    if (isValid)
      return null;
    else
      return "Invalid phone number";
  }

  /// Aadhar Number verification
  verifyAadhar(String aadhar) {
    if (aadhar.length != 12) {
      return "Aadhar number must be 12 digits long";
    }
    bool isValid = isNumeric(aadhar);
    if (isValid)
      return null;
    else
      return "Enter a valid Aadhar number";
  }

  /// Image Verification
  verifyImage(File file) {
    if (file == null) {
      return "Image cannot be empty";
    }
    return null;
  }

  /// Expertise Verification
  verifyExpertise(String expertise) {
    bool isValid = isAlpha(expertise);
    if (isValid)
      return null;
    else
      return "Enter valid expertise";
  }

  /// Experience Verification
  verifyExperience(String exp) {
    if (exp.length > 2) {
      return "Invalid experience year";
    }
    bool isValid = isNumeric(exp);
    if (isValid)
      return null;
    else
      return "Invalid Experience";
  }

  /// Address Verification
  verifyAddress(String addr) {
    if (addr == null || addr == " " || addr == "") {
      return "Address cannot be null";
    }
   return null;
  }

  /// Radius Verification
  verifyRadius(String radius) {
    bool isValid = isNumeric(radius);
    if(isValid) return null;
    else return "Enter a valid number";
  }
}
