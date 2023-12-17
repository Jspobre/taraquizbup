import 'dart:io';

import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive/hive.dart';

import '../configs/constants/constants.dart';
import '../sign_in/model/sign_in_model.dart';

mixin AudioPlay {
  audioPlay(String path) {
    Audio.load(path)
      ..play()
      ..dispose();
  }
}

mixin URI {
  Uri uriChoice(String choice) {
    Uri privacyPolicyURL =
        Uri(scheme: 'https', host: 'bicol-u.edu.ph', path: 'privacy-policy');
    Uri termsOfServiceURL = Uri(
        scheme: 'https', host: 'bicol-u.edu.ph', path: 'privacy-policy');
    if (choice == 'Terms of Service') {
      return termsOfServiceURL;
    } else {
      return privacyPolicyURL;
    }
  }
}

mixin ConnectivityCheck {
 connectivityCheck()  async {
  bool check = false;
  await  Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.mobile ||
          value == ConnectivityResult.wifi) {
        check = true;
      }
    });
    return check;
  }
}

mixin Auth {
  // Check auth
  bool check() {
    bool isSignedIn = true;
    if(FirebaseAuth.instance.currentUser == null) {
        isSignedIn = false;
      }
     return isSignedIn;
  }
  //Delete user
  deleteUser() async {
    String message = AppConstants.defaultStringConstant;
    try {
      FirebaseAuth.instance.currentUser?.delete().then((value) async {
        var path = Directory.current.path;
        await Hive.deleteBoxFromDisk('userCredential', path: path)
            .then((value) {
          message = "Success";
          return message;
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        message ='The user must reauthenticate before this operation can be executed.';
      }
      return message;
    } catch (e) {
      message = e.toString();
      return message;
    }
  }

  //Sign Out
  signOut() async {
    String message = AppConstants.defaultStringConstant;
    SignInModel signInModel = SignInModel();
    try {
      await FirebaseAuth.instance.signOut().then((value) async {
        var path = Directory.current.path;
        Hive.init(path);
        var box = await Hive.openBox('userCredential');
        box.put('currentUser', signInModel);
        message = "Success";
        return message;
      });
    } on FirebaseAuthException catch (e) {
      message = e.toString();
      return message;
    } catch (e) {
      message = e.toString();
      return message;
    }
  }
}




mixin EmailAndPasswordAuth {

  //Update Display Name
  updateDisplayName(String displayName) {
    String message = AppConstants.defaultStringConstant;

    try {
      FirebaseAuth.instance.currentUser
          ?.updateDisplayName(displayName)
          .then((value) async {
        SignInModel signInModel = SignInModel();
        signInModel.dName = displayName;
        signInModel.save();
        message = "Success";
        return message;
      });
    } on FirebaseAuthException catch (e) {
      message = e.code.toString();

      return message;
    } catch (e) {
      message = e.toString();
      return message;
    }
  }

  //Update eMailId
  updateMobileNumber(String emailId) {
    String message = AppConstants.defaultStringConstant;

    try {
      FirebaseAuth.instance.currentUser?.updateEmail(emailId).then((value) {
        SignInModel signInModel = SignInModel();
        signInModel.eMailId = emailId;
        signInModel.save();
        message = "Success";
        return message;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        'Invalid-email. Please check the email entered.';
      } else {
        message = e.code.toString();
      }
      return message;
    } catch (e) {
      message = e.toString();
      return message;
    }
  }

  //Update Password
  updatePassword(String newPassword) async {
    String message = AppConstants.defaultStringConstant;
    try {
      FirebaseAuth.instance.currentUser
          ?.updatePassword(newPassword)
          .then((value) {
        message = "Success";
        return message;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else {
        message = e.code.toString();
      }
      return message;
    } catch (e) {
      message = e.toString();
      return message;
    }
  }




}

class Snippet with AudioPlay, ConnectivityCheck, URI, EmailAndPasswordAuth, Auth  {}
