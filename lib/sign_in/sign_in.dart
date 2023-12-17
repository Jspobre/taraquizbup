import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:taraquizbup/sign_in/model/sign_in_model.dart';
import 'package:taraquizbup/sign_in/register.dart';
import 'package:taraquizbup/widgets/custom_dialog.dart';

import 'package:url_launcher/url_launcher.dart';

import '../configs/constants/constants.dart';
import '../mixins/mixins.dart';
import 'forgot_password.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);
  final TextEditingController controllerPassword = TextEditingController();
  final TextEditingController controllerUserCred = TextEditingController();
  final TextEditingController controllerOTP = TextEditingController();
  final FocusNode focusNodeOTP = FocusNode();

  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodeEMail = FocusNode();
  final SignInModel signInModel = SignInModel();
  final Snippet snippet = Snippet();
  final CustomDialog customDialog = CustomDialog();
  final path = './';
  @override
  Widget build(BuildContext context) {
    bool viewPass = false;
    hiveDBAdd(SignInModel sign) async {
      FirebaseFirestore.instance
          .collection('StudentsDetails')
          .doc(sign.uid)
          .get()
          .then((value) async {
        if (value.exists) {
          viewPass = true;
        }
        var box = await Hive.openBox('taraQuizAppData');
        box.putAll({
          'dName': sign.dName,
          'uid': sign.uid,
          'eMail': sign.eMailId,
          'mobile': sign.mobileNumber,
          'rToken': sign.rToken,
          'eMailIdVerified': sign.eMailIdVerified,
          'isSignedIn': sign.isSignedIn,
          'signedInMethod': sign.signInMethod,
          'photoURL': sign.profilePhotoURL,
        }).then((_) {
          viewPass
              ? customDialog.customSuccessDialog(
                  "Success", context, true, false)
              : customDialog.customSuccessDialog(
                  "Success", context, false, true);
        });
      });
    }

    String otp = '';

    onPressedSignIn() async {
      await Connectivity().checkConnectivity().then((value) {
        if (value == ConnectivityResult.mobile ||
            value == ConnectivityResult.wifi) {
          if (RegExp(r"^(\+91)(\d{10})$").hasMatch(controllerUserCred.text) ||
              RegExp(r"^(09|\+639)\d{9}$").hasMatch(controllerUserCred.text)) {
            FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: controllerUserCred.text,
              timeout: const Duration(seconds: 5),
              verificationCompleted: (credential) async {
                await FirebaseAuth.instance
                    .signInWithCredential(credential)
                    .then((value) {
                  signInModel.dName = value.user!.displayName ??
                      AppConstants.defaultStringConstant;
                  signInModel.eMailId =
                      value.user!.email ?? AppConstants.defaultStringConstant;
                  signInModel.eMailIdVerified = value.user!.emailVerified;
                  signInModel.uid = value.user!.uid;
                  signInModel.rToken = value.user!.refreshToken ??
                      AppConstants.defaultStringConstant;
                  signInModel.isSignedIn = true;
                  signInModel.profilePhotoURL = value.user!.photoURL ??
                      AppConstants.defaultStringConstant;
                }).whenComplete(() {
                  Navigator.of(context, rootNavigator: true).pop();
                  hiveDBAdd(
                    signInModel,
                  );
                });
              },
              verificationFailed: (_) {},
              codeSent: (verificationId, [forceResendingToken]) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          title: const Text(
                            "OTP",
                            textAlign: TextAlign.center,
                          ),
                          content: Padding(
                            padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              right: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              bottom:
                                  ((MediaQuery.of(context).size.height * 2) /
                                      100),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return TextField(
                                  autofocus: false,
                                  showCursor: true,
                                  autocorrect: false,
                                  focusNode: focusNodeOTP,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  controller: controllerOTP,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Enter OTP: \*',
                                  ),
                                  obscureText: true,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.blue),
                                  onChanged: (e) {
                                    setState(() {
                                      otp = e;
                                    });
                                  },
                                  onTap: () {
                                    focusNodeEMail.unfocus();
                                    focusNodePassword.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(focusNodeOTP);
                                    controllerOTP.text = '';
                                    signInModel.otp = '';
                                  },
                                );
                              },
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                                child: Text(
                                  'Submit',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.blue),
                                ),
                                onPressed: () async {
                                  final PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: otp,
                                  );
                                  await FirebaseAuth.instance
                                      .signInWithCredential(credential)
                                      .then((value) {
                                    signInModel.dName =
                                        value.user!.displayName ??
                                            AppConstants.defaultStringConstant;
                                    signInModel.eMailId = value.user!.email ??
                                        AppConstants.defaultStringConstant;
                                    signInModel.eMailIdVerified =
                                        value.user!.emailVerified;
                                    signInModel.uid = value.user!.uid;
                                    signInModel.mobileNumber =
                                        value.user!.phoneNumber ??
                                            AppConstants.defaultStringConstant;
                                    signInModel.rToken =
                                        value.user!.refreshToken ??
                                            AppConstants.defaultStringConstant;
                                    signInModel.isSignedIn = true;
                                    signInModel.profilePhotoURL =
                                        value.user!.photoURL ??
                                            AppConstants.defaultStringConstant;
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    hiveDBAdd(
                                      signInModel,
                                    );
                                  }).onError((error, stackTrace) {
                                    customDialog.customErrorDialog(
                                      'An error has occurred please try again later. internal code 01',
                                      context,
                                    );
                                  });
                                }),
                          ]);
                    });

                // get the SMS code from the user somehow (probably using a text field)
              },
              codeAutoRetrievalTimeout: (String verificationId) {},
            );
          } else {
            try {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: signInModel.eMailId,
                      password: signInModel.password)
                  .then((value) async {
                signInModel.dName = value.user!.displayName ??
                    AppConstants.defaultStringConstant;
                signInModel.eMailId =
                    value.user!.email ?? AppConstants.defaultStringConstant;
                signInModel.mobileNumber = value.user!.phoneNumber ??
                    AppConstants.defaultStringConstant;
                signInModel.eMailIdVerified = value.user!.emailVerified;
                signInModel.uid = value.user!.uid;
                signInModel.rToken = value.user!.refreshToken ??
                    AppConstants.defaultStringConstant;
                signInModel.isSignedIn = true;
                print(value.user!.photoURL);
                signInModel.profilePhotoURL =
                    value.user!.photoURL ?? AppConstants.defaultStringConstant;

                hiveDBAdd(
                  signInModel,
                );
              }).onError((error, stackTrace) {
                print(error);
                if (error.toString() ==
                    '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.') {
                  customDialog.customErrorDialog(
                    'There is no user record corresponding to this identifier. The user may have been deleted.',
                    context,
                  );
                } else if (error.toString() ==
                    '[firebase_auth/invalid-email] wrong-password') {
                  customDialog.customErrorDialog(
                    'Wrong password provided for that user.',
                    context,
                  );
                } else if (error.toString() ==
                    '[firebase_auth/invalid-email] The email address is badly formatted.') {
                  customDialog.customErrorDialog(
                    'The email address is badly formatted.',
                    context,
                  );
                } else {
                  customDialog.customErrorDialog(
                    'An error has occurred please try again later. internal code 01',
                    context,
                  );
                }
              }).onError((error, stackTrace) {
                customDialog.customErrorDialog(
                  error.toString(),
                  context,
                );
              });
            } catch (e) {
              customDialog.customErrorDialog(
                'An error has occurred please try again later. internal code 02',
                context,
              );
            }
          }
        } else {
          customDialog.customErrorDialog(
            'Please check your internet connectivity.',
            context,
          );
        }
      });
    }

    onPressedRegister() {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => Register(
                  isChangePassword: false,
                ),
            maintainState: true,
            fullscreenDialog: false),
      );
    }

    onPressedResetPassword() {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ResetPassword(), fullscreenDialog: false),
      );
    }

    onPressedChangePassword() {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => Register(
                  isChangePassword: true,
                ),
            maintainState: true,
            fullscreenDialog: false),
      );
    }

    Future<void> launchInWebView(Uri url) async {
      if (!await launchUrl(
        url,
        webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true, enableDomStorage: true),
        mode: LaunchMode.inAppWebView,
      )) {
        throw 'Could not launch $url';
      }
    }

    onPressedTermsOfServices() {
      launchInWebView(snippet.uriChoice('Terms of Service'));
    }

    onPressedPrivacyPolicy() async {
      launchInWebView(snippet.uriChoice('Privacy Policy'));
    }

    bool onChangedCheckBox(bool? value) {
      value = true;
      return value;
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.linearToSrgbGamma(),
            alignment: Alignment.center,
            scale: 1,
            opacity: 1,
            fit: BoxFit.fill,
            image: AssetImage(FileConstants.assetBackground),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              top: ((MediaQuery.of(context).size.height * 7) / 100),
              bottom: ((MediaQuery.of(context).size.height * 7) / 100),
              left: ((MediaQuery.of(context).size.width * 4) / 100),
              right: ((MediaQuery.of(context).size.width * 4) / 100),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: ((MediaQuery.of(context).size.height * 4) / 100),
                      bottom: ((MediaQuery.of(context).size.height * 4) / 100),
                    ),
                    child: Text(
                      PageTitleConstants.signInScreenTitle,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.blue),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    height: 175,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 10 / 100,
                          right: MediaQuery.of(context).size.width * 10 / 100),
                      child: Image(
                        image: AssetImage(FileConstants.logo),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: ((MediaQuery.of(context).size.width * 8) / 100),
                        right: ((MediaQuery.of(context).size.width * 8) / 100),
                        bottom:
                            ((MediaQuery.of(context).size.height * 4) / 100),
                        top: ((MediaQuery.of(context).size.height * 4) / 100)),
                    child: TextField(
                      controller: controllerUserCred,
                      focusNode: focusNodeEMail,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.blue),
                      onChanged: (e) {
                        signInModel.eMailId = e;
                      },
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context).requestFocus(focusNodeEMail);
                        controllerUserCred.text = '';
                        signInModel.password = '';
                      },
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context).requestFocus(focusNodePassword);
                        controllerPassword.text = '';
                        signInModel.password = '';
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter your email / mobile: \*',
                      ),
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: ((MediaQuery.of(context).size.width * 8) / 100),
                      right: ((MediaQuery.of(context).size.width * 8) / 100),
                      bottom: ((MediaQuery.of(context).size.height * 2) / 100),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return TextField(
                          controller: controllerPassword,
                          focusNode: focusNodePassword,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.blue),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    viewPass = !viewPass;
                                  });
                                },
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: viewPass ? Colors.blue : Colors.black,
                                )),
                            border: const UnderlineInputBorder(),
                            labelText: 'Enter your password: \*',
                          ),
                          onChanged: (e) {
                            signInModel.password = e;
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context)
                                .requestFocus(focusNodePassword);
                            controllerPassword.text = '';
                            signInModel.password = '';
                          },
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            onPressedSignIn();
                          },
                          autocorrect: false,
                          obscureText: viewPass ? false : true,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                        );
                      },
                    ),
                  ),
                  Wrap(
                    children: [
                      TextButton(
                          onPressed: onPressedResetPassword,
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.blue),
                          )),
                      TextButton(
                          onPressed: onPressedRegister,
                          child: Text(
                            'Register',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.blue),
                          )),
                      TextButton(
                          onPressed: onPressedChangePassword,
                          child: Text(
                            'Change Password?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.blue),
                          )),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ((MediaQuery.of(context).size.height * 4) / 100),
                      bottom: ((MediaQuery.of(context).size.height * 4) / 100),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      onPressed: onPressedSignIn,
                      child: const Text('Sign In'),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(value: true, onChanged: onChangedCheckBox),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width * 70) / 100,
                        child: Text(
                          'By signing in, you agree to the following policies:',
                          maxLines: 3,
                          style: Theme.of(context).textTheme.labelLarge,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: onPressedTermsOfServices,
                          child: const Text('Terms of Service')),
                      Text(
                        '&',
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                      ),
                      TextButton(
                          onPressed: onPressedPrivacyPolicy,
                          child: const Text('Privacy Policy')),
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
