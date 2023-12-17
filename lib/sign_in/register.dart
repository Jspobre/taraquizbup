import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taraquizbup/widgets/custom_dialog.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../configs/constants/constants.dart';
import '../mixins/mixins.dart';
import 'model/sign_in_model.dart';

class Register extends StatefulWidget {
final bool isChangePassword;

Register({Key? key, required this.isChangePassword}) : super(key: key);
@override
_RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isImageSelected = false;
  late File file;

  final formKey = GlobalKey<FormState>();
  String selectedStudentProfessorValue = 'Please select';
  List<DropdownMenuItem<String>> get dropdownStudentOrProfessor{
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Please select", child: Text("Please select")),
      const DropdownMenuItem(value: "Student", child: Text("I am a Student.")),
      const DropdownMenuItem(value: "Professor", child: Text("I am a Professor")),
    ];
    return menuItems;
  }

  Future<void> _uploadImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }
  Future<void> _uploadCamera() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }
  void _clear() {
    setState(() {
      isImageSelected = false;
      _pickedFile = null;
      _croppedFile = null;
    });
  }
  Widget _uploaderCard() {
    return Column(
      children: [Padding(
        padding: EdgeInsets.only(
          top: ((MediaQuery.of(context).size.height * 5) / 100),
          left: ((MediaQuery.of(context).size.width * 5) / 100),
          right: ((MediaQuery.of(context).size.width * 2) / 100),
          bottom:
          ((MediaQuery.of(context).size.height * 2) / 100),
        ),
        child: Center(
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SizedBox(
              width: kIsWeb ? 380.0 : 320.0,
              height: 300.0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: SizedBox(height: 55,child: Image.asset(FileConstants.defaultUser)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Upload your photo',
                        style: kIsWeb
                            ? Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                            color: Theme.of(context).highlightColor)
                            : Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                            color:
                            Theme.of(context).highlightColor),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _uploadImage();
                      },
                      child: const Text('Gallery'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 12.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _uploadCamera();
                      },
                      child: const Text('Camera'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      ],
    );
  }

  final TextEditingController controllerFirstName = TextEditingController();
  final TextEditingController controllerLastName = TextEditingController();
  final TextEditingController controllerEMailID = TextEditingController();
  final TextEditingController controllerMobileNumber = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final TextEditingController controllerConfirmPassword =
      TextEditingController();
  final TextEditingController controllerOTP = TextEditingController();

  final FocusNode focusNodeFirstName = FocusNode();
  final FocusNode focusNodeLastName = FocusNode();
  final FocusNode focusNodeEMailId = FocusNode();
  final FocusNode focusNodeMobileNumber = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodeConfirmPassword = FocusNode();
  final FocusNode focusNodeOTP = FocusNode();
  XFile? _pickedFile;

  final TextEditingController controllerNewPassword = TextEditingController();
  final FocusNode focusNodeNewPassword = FocusNode();
  CroppedFile? _croppedFile;

  final SignInModel signInModel = SignInModel();
  final Snippet snippet = Snippet();
  final CustomDialog customDialog = CustomDialog();
  String fileName = "";
  String newPassword = '';
  String otp = '';
  bool isSelected = false;
  bool isProfessor = true;

  @override
  Widget build(BuildContext context) {

    bool viewPass = false;
    void create(eMailId, password, fName, lName, mobileNo, file, studentOrProfessor) {
      try {
        String displayName = "$fName $lName";
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: eMailId,
          password: password,
        )
            .then((value) {
          value.user?.sendEmailVerification();
          value.user?.updateDisplayName(displayName);
          final storageRef = FirebaseStorage.instance.ref();

          // Create a reference to "mountains.jpg"
          final mountainsRef = storageRef.child( "${value.user?.uid}" +".jpg");
          mountainsRef.putFile(file).then((p0) async {

            mountainsRef.getDownloadURL().then((valueImg) async {

              value.user?.updatePhotoURL(valueImg);
              value.user?.reload();
              Map tempMap = {"Name" : displayName,"photoURL":valueImg};
              if(studentOrProfessor!= "Student") {
                final databaseReference = FirebaseDatabase.instance.ref();
                await databaseReference
                    .child("forStudents/profrssorsList")
                    .update({"${value.user?.uid}": tempMap});
              }

              FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: signInModel.mobileNumber,
                timeout: const Duration(seconds: 5),
                verificationCompleted: (credential) async {
                  await FirebaseAuth.instance.currentUser!
                      .updatePhoneNumber(credential);

                  customDialog.customSuccessDialog(
                      "Success", context, false,  false);
                },

                verificationFailed: (_) {

                  customDialog.customErrorDialog(
                  "OTP verification failed. Try again.",
                  context,
                  );

                },
                codeSent: (verificationId, [forceResendingToken])  {

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
                                left:
                                ((MediaQuery.of(context).size.width * 8) / 100),
                                right:
                                ((MediaQuery.of(context).size.width * 8) / 100),
                                bottom: ((MediaQuery.of(context).size.height * 2) /
                                    100),
                              ),
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return TextField(
                                    autofocus: true,
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
                                      FocusScope.of(context).unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(focusNodePassword);
                                      controllerPassword.text = '';
                                      signInModel.password = '';
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
                                  onPressed: () {
                                    final PhoneAuthCredential credential =
                                    PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: otp,
                                    );
                                    FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential).then((value1) {                                value.user?.reload();
                                    Navigator.of(context, rootNavigator: true).pop();
                                    customDialog.customSuccessDialog(
                                        "Success", context, false,  false);
                                    });

                                  }),
                            ]);
                      });

                  // get the SMS code from the user somehow (probably using a text field)
                },
                codeAutoRetrievalTimeout: (String verificationId) {},
              ).onError((error, stackTrace) {
                customDialog.customErrorDialog(
                  "Authentication error.",
                  context,
                );
              }).then((po) => selectedStudentProfessorValue == "Student" ? FirebaseFirestore.instance
                  .collection('StudentsDetails')
                  .doc(value.user?.uid)
                  .set({
                'name' :  displayName,
                'email id' : eMailId,
                'mobile' : mobileNo,
                'studentOrProfessor' :  selectedStudentProfessorValue,
                'photoUrl' : valueImg,
              }).onError((error, stackTrace) {
                customDialog.customErrorDialog(
                "error uploading details",
                context,
                );

              }): FirebaseFirestore.instance
                  .collection('ProfessorsDetails')
                  .doc(value.user?.uid)
                  .set({
                'name' :  displayName,
                'email id' : eMailId,
                'mobile' : mobileNo,
                'studentOrProfessor' :  selectedStudentProfessorValue,
                'photoUrl' : valueImg,
              }).onError((error, stackTrace) {
                customDialog.customErrorDialog(
                  "error uploading details",
                  context,
                );}));

            }).onError((error, stackTrace) {
              customDialog.customErrorDialog(
                "error uploading details",
                context,
              );
            });}).onError((error, stackTrace) {
            customDialog.customErrorDialog(
              "error uploading photo",
              context,
            );
          });
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          customDialog.customErrorDialog(
            'The password provided is too weak.',
            context,
          );
        } else if (e.code == 'email-already-in-use') {
          customDialog.customErrorDialog(
            'The account already exists for that email.',
            context,
          );
        } else {
          customDialog.customErrorDialog(
            'An error has occurred please try again later. internal code 01',
            context,
          );
        }
      } catch (e) {
        customDialog.customErrorDialog(
          'An error has occurred please try again later. internal code 02',
          context,
        );
      }
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

    onPressedRegister() async {
      if (formKey.currentState!.validate() && isSelected && isImageSelected) {
        await Connectivity().checkConnectivity().then((value) {
          if (value == ConnectivityResult.mobile ||
              value == ConnectivityResult.wifi) {
            create(signInModel.eMailId, signInModel.password, signInModel.fName,
                signInModel.lName, signInModel.mobileNumber, file, selectedStudentProfessorValue);
          } else {
            customDialog.customErrorDialog(
              'Please check your internet connectivity.',
              context,
            );
          }
        });
      } else if(!isSelected && isImageSelected){
        customDialog.customErrorDialog(
          'Please select whether you are a Student or Professor.',
          context,
        );
      } else if (!isImageSelected && !isSelected){
        customDialog.customErrorDialog(
          'Please upload photo and select whether you are a Student or Professor.',
          context,
        );
      } else if (!isImageSelected && isSelected){
        customDialog.customErrorDialog(
          'Please upload photo.',
          context,
        );
      }
    }

    bool onChangedCheckBox(bool? value) {
      value = true;
      return true;
    }

    onPressedChange() async {
      if (formKey.currentState!.validate()) {
        await Connectivity().checkConnectivity().then((value) async {
          if (value == ConnectivityResult.mobile ||
              value == ConnectivityResult.wifi) {
            try {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: signInModel.eMailId,
                      password: signInModel.password)
                  .then((value) {
                value.user
                    ?.updatePassword(controllerConfirmPassword.text)
                    .whenComplete(() => customDialog.customSuccessDialog(
                        "Success", context, false, false));
              }).onError((error, stackTrace) {
                customDialog.customErrorDialog(
                  'Authentication failed due to wrong Username or Password.\n\n Please use forgot password to reset password',
                  context,
                );
              });
            } catch (e) {
              customDialog.customErrorDialog(
                'An error has occurred please try again later. internal code 02',
                context,
              );
            }
          } else {
            customDialog.customErrorDialog(
              'Please check your internet connectivity.',
              context,
            );
          }
        });
      }
    }


    _body() {
      return widget.isChangePassword
          ?
          //Change Password
          Container(
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
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Padding(
                        padding: EdgeInsets.only(
                          top: ((MediaQuery.of(context).size.height * 5) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 4) / 100),
                        ),
                        child: Text(
                          'Please enter e-mail id below.',
                          maxLines: 2,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: ((MediaQuery.of(context).size.width * 8) / 100),
                          right:
                              ((MediaQuery.of(context).size.width * 8) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 2) / 100),
                        ),
                        child: TextFormField(
                          showCursor: true,
                          textDirection: TextDirection.ltr,
                          autocorrect: false,
                          focusNode: focusNodeEMailId,
                          obscureText: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          controller: controllerEMailID,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'e-mail Id: \*',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.blue),
                          onChanged: (e) {
                            signInModel.eMailId = e;
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context)
                                .requestFocus(focusNodeEMailId);
                            controllerEMailID.text = '';
                            signInModel.eMailId = '';
                          },
                          onFieldSubmitted: (e) {
                            signInModel.eMailId = e;
                            controllerEMailID.text = e;
                            controllerPassword.text = "";
                            signInModel.password = "";
                          },
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context)
                                .requestFocus(focusNodePassword);
                          },
                          validator: (value) {
                            // Genuine email regexp
                            if (RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value!)) {
                              return null;
                            } else {
                              return "Enter a valid e-mail Address.";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: ((MediaQuery.of(context).size.width * 8) / 100),
                          right:
                              ((MediaQuery.of(context).size.width * 8) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 2) / 100),
                        ),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return TextFormField(
                              showCursor: true,
                              autocorrect: false,
                              focusNode: focusNodePassword,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              controller: controllerPassword,
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'Enter Old Password: \*',
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        viewPass = !viewPass;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color:
                                          viewPass ? Colors.blue : Colors.black,
                                    )),
                              ),
                              obscureText: viewPass ? false : true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.blue),
                              validator: (value) {
                                int? i = 0;
                                i = value?.length;
                                if (i! >= 6) {
                                  return null;
                                } else {
                                  return "Enter a valid Password.";
                                }
                              },
                              onChanged: (e) {
                                signInModel.password = e;
                              },
                              onFieldSubmitted: (e) {
                                signInModel.password = e;
                                controllerPassword.text = e;
                                controllerNewPassword.text = "";
                                signInModel.nPassword = "";
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodeNewPassword);
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
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: ((MediaQuery.of(context).size.width * 8) / 100),
                          right:
                              ((MediaQuery.of(context).size.width * 8) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 2) / 100),
                        ),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return TextFormField(
                              showCursor: true,
                              autocorrect: false,
                              focusNode: focusNodeNewPassword,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              controller: controllerNewPassword,
                              decoration: InputDecoration(
                                border: const UnderlineInputBorder(),
                                labelText: 'Enter New Password: \*',
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        viewPass = !viewPass;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color:
                                          viewPass ? Colors.blue : Colors.black,
                                    )),
                              ),
                              obscureText: viewPass ? false : true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.blue),
                              validator: (value) {
                                int? i = 0;
                                i = value?.length;
                                if (i! >= 6) {
                                  return null;
                                } else {
                                  return "Enter a valid Password.";
                                }
                              },
                              onChanged: (e) {
                                signInModel.nPassword = e;
                              },
                              onFieldSubmitted: (e) {
                                signInModel.nPassword = e;
                                controllerNewPassword.text = e;
                                controllerConfirmPassword.text = "";
                                signInModel.cPassword = "";
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodeConfirmPassword);
                              },
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodeNewPassword);
                                controllerNewPassword.text = '';
                                signInModel.nPassword = '';
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: ((MediaQuery.of(context).size.width * 8) / 100),
                          right:
                              ((MediaQuery.of(context).size.width * 8) / 100),
                          bottom:
                              ((MediaQuery.of(context).size.height * 2) / 100),
                        ),
                        child: TextFormField(
                          autocorrect: false,
                          focusNode: focusNodeConfirmPassword,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          controller: controllerConfirmPassword,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Confirm Password\*',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.blue),
                          onChanged: (e) {
                            signInModel.cPassword = e;
                          },
                          onFieldSubmitted: (e) {
                            signInModel.cPassword = e;
                            controllerConfirmPassword.text = e;
                          },
                          onEditingComplete: () {
                            onPressedChange;
                            FocusScope.of(context).unfocus();
                          },
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            FocusScope.of(context)
                                .requestFocus(focusNodeConfirmPassword);
                            controllerConfirmPassword.text = '';
                            signInModel.cPassword = '';
                          },
                          validator: (value) {
                            if (signInModel.nPassword == value!) {
                              return null;
                            } else {
                              return "Password Mismatch.";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: ((MediaQuery.of(context).size.height * 4) /
                                100),
                            bottom: ((MediaQuery.of(context).size.height * 4) /
                                100)),
                        child: ElevatedButton(
                          onPressed: onPressedChange,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
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
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: ((MediaQuery.of(context).size.height * 7) / 100),
                      left: ((MediaQuery.of(context).size.width * 7) / 100),
                      right: ((MediaQuery.of(context).size.width * 7) / 100),
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              top: ((MediaQuery.of(context).size.height * 5) /
                                  100),
                              bottom:
                                  ((MediaQuery.of(context).size.height * 2) /
                                      100),
                            ),
                            child: Text(
                              'Please fill the form below.',
                              maxLines: 2,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          _croppedFile != null || _pickedFile != null ?  _imageCard() : _uploaderCard(),

                          Padding(
                            padding: EdgeInsets.only(
                              top: ((MediaQuery.of(context).size.height * 2) / 100),
                              left: ((MediaQuery.of(context).size.width * 8) / 100),
                              right: ((MediaQuery.of(context).size.width * 8) / 100),
                              bottom:
                              ((MediaQuery.of(context).size.height * 2) / 100),
                            ),
                            child: DropdownButton<String>(
                              value: selectedStudentProfessorValue,
                              items: dropdownStudentOrProfessor,

                              onChanged: (value) {
                                setState(() {
                                  if (value == "Student") {
                                    setState(() {
                                      isProfessor = false;
                                      isSelected = true;
                                    });
                                  } else  if (value == "Professor"){
                                    setState(() {
                                      isProfessor = true;
                                      isSelected = true;

                                    });
                                  }   else {
                                    setState(() {
                                      isSelected = false;
                                      isProfessor = false;

                                    });
                                  }
                                  selectedStudentProfessorValue = value!;
                                  signInModel.studentOrProfessor = value;
                                });

                              },
                            ),
                          ),

                          Wrap(
                              spacing:
                                  ((MediaQuery.of(context).size.width * 5) /
                                      100), // gap between adjacent chips
                              runSpacing:
                                  ((MediaQuery.of(context).size.height * 2) /
                                      100), // gap between lines
                              children: <Widget>[
                                SizedBox(
                                  width: ((MediaQuery.of(context).size.width *
                                          35) /
                                      100),
                                  child: TextFormField(
                                    autocorrect: false,
                                    focusNode: focusNodeFirstName,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    controller: controllerFirstName,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'First Name: \*',
                                    ),
                                    onChanged: (e) {
                                      signInModel.fName = e;
                                    },
                                    onFieldSubmitted: (e) {
                                      signInModel.fName = e;
                                      controllerFirstName.text = e;
                                    },
                                    onEditingComplete: () {
                                      FocusScope.of(context).unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(focusNodeLastName);
                                      signInModel.lName = "";
                                      controllerLastName.text = "";
                                    },
                                    onTapOutside: (event) =>
                                        FocusScope.of(context).unfocus(),
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(focusNodeFirstName);
                                      controllerFirstName.text = '';
                                      signInModel.fName = '';
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.blue),
                                    validator: (value) {
                                      int? i = 0;
                                      i = value?.length;
                                      if (i! >= 3) {
                                        return null;
                                      } else {
                                        return "Enter a valid First Name.";
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: ((MediaQuery.of(context).size.width *
                                          35) /
                                      100),
                                  child: TextFormField(
                                    autocorrect: false,
                                    focusNode: focusNodeLastName,
                                    obscureText: false,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    controller: controllerLastName,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Last Name: \*',
                                    ),
                                    onFieldSubmitted: (e) {
                                      signInModel.lName = e;
                                      controllerLastName.text = e;
                                    },
                                    onEditingComplete: () {
                                      FocusScope.of(context).unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(focusNodeEMailId);
                                      signInModel.eMailId = "";
                                      controllerEMailID.text = "";
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.blue),
                                    onChanged: (e) {
                                      signInModel.lName = e;
                                    },
                                    onTapOutside: (event) =>
                                        FocusScope.of(context).unfocus(),
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusScope.of(context)
                                          .requestFocus(focusNodeLastName);
                                      controllerLastName.text = '';
                                      signInModel.lName = '';
                                    },
                                    validator: (value) {
                                      int? i = 0;
                                      i = value?.length;
                                      if (i! >= 1) {
                                        return null;
                                      } else {
                                        return "Enter a valid Last Name.";
                                      }
                                    },
                                  ),
                                ),
                              ]),
                          Padding(
                            padding: EdgeInsets.only(
                              top: ((MediaQuery.of(context).size.height * 2) /
                                  100),
                              left: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              right: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              bottom:
                                  ((MediaQuery.of(context).size.height * 2) /
                                      100),
                            ),
                            child: TextFormField(
                              showCursor: true,
                              textDirection: TextDirection.ltr,
                              autocorrect: false,
                              focusNode: focusNodeEMailId,
                              obscureText: false,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              controller: controllerEMailID,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'e-mail Id: \*',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.blue),
                              onChanged: (e) {
                                signInModel.eMailId = e;
                              },
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodeEMailId);
                                controllerEMailID.text = '';
                                signInModel.eMailId = '';
                              },
                              onFieldSubmitted: (e) {
                                signInModel.eMailId = e;
                                controllerEMailID.text = e;
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodeMobileNumber);
                                signInModel.mobileNumber = "";
                                controllerMobileNumber.text = "";
                              },
                              validator: (value) {
                                // Genuine email regexp
                                if (RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)) {
                                  return null;
                                } else {
                                  return "Enter a valid email id.";
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: ((MediaQuery.of(context).size.height * 2) /
                                  100),
                              left: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              right: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              bottom:
                                  ((MediaQuery.of(context).size.height * 2) /
                                      100),
                            ),
                            child: TextFormField(
                              showCursor: true,
                              textDirection: TextDirection.ltr,
                              autocorrect: false,
                              focusNode: focusNodeMobileNumber,
                              obscureText: false,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              controller: controllerMobileNumber,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Mobile Number: \*',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.blue),
                              onChanged: (e) {
                                signInModel.mobileNumber = e;
                              },
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodeMobileNumber);

                                controllerMobileNumber.text = '';
                                signInModel.mobileNumber = '';
                              },
                              onFieldSubmitted: (e) {
                                signInModel.mobileNumber = e;
                                controllerMobileNumber.text = e;
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodePassword);
                                signInModel.password = "";
                                controllerPassword.text = "";
                              },
                              validator: (value) {

                                if (RegExp(r"^(\+91)(\d{10})$")
                                    .hasMatch(value!) || RegExp(r"^(\+639)\d{9}$")
                                    .hasMatch(value) ) {
                                return null;
                                } else {
                                return "Enter a valid Mobile Number.";
                                }

                              },
                            ),
                          ),
                          Padding(
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
                                return TextFormField(
                                  showCursor: true,
                                  autocorrect: false,
                                  focusNode: focusNodePassword,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  controller: controllerPassword,
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    labelText: 'Password: \*',
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            viewPass = !viewPass;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          color: viewPass
                                              ? Colors.blue
                                              : Colors.black,
                                        )),
                                  ),
                                  obscureText: viewPass ? false : true,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.blue),
                                  validator: (value) {
                                    int? i = 0;
                                    i = value?.length;
                                    if (i! >= 6) {
                                      return null;
                                    } else {
                                      return "Enter a valid Password.";
                                    }
                                  },
                                  onChanged: (e) {
                                    signInModel.password = e;
                                  },
                                  onFieldSubmitted: (e) {
                                    signInModel.password = e;
                                    controllerPassword.text = e;
                                  },
                                  onEditingComplete: () {
                                    FocusScope.of(context).unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(focusNodeConfirmPassword);
                                    signInModel.cPassword = "";
                                    controllerConfirmPassword.text = "";
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
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              right: ((MediaQuery.of(context).size.width * 8) /
                                  100),
                              bottom:
                                  ((MediaQuery.of(context).size.height * 2) /
                                      100),
                            ),
                            child: TextFormField(
                              autocorrect: false,
                              focusNode: focusNodeConfirmPassword,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              controller: controllerConfirmPassword,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Confirm Password\*',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.blue),
                              onChanged: (e) {
                                signInModel.cPassword = e;
                              },
                              onFieldSubmitted: (e) {
                                signInModel.cPassword = e;
                                controllerConfirmPassword.text = e;
                              },
                              onEditingComplete: () {
                                onPressedRegister;
                                FocusScope.of(context).unfocus();
                              },
                              onTapOutside: (event) =>
                                  FocusScope.of(context).unfocus(),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusScope.of(context)
                                    .requestFocus(focusNodeConfirmPassword);
                                controllerConfirmPassword.text = '';
                                signInModel.cPassword = '';
                              },
                              validator: (value) {
                                if (signInModel.password == value!) {
                                  return null;
                                } else {
                                  return "Password Mismatch.";
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: ((MediaQuery.of(context).size.height * 4) /
                                    100),
                                bottom:
                                    ((MediaQuery.of(context).size.height * 4) /
                                        100)),
                            child: ElevatedButton(
                              onPressed: onPressedRegister,
                              child: const Text(
                                'Register',
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                  value: true, onChanged: onChangedCheckBox),
                              SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width * 70) /
                                        100,
                                child: Text(
                                  'By Registering, you agree to these following policies:',
                                  maxLines: 4,
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

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.isChangePassword
            ? "Change Password"
            : PageTitleConstants.registerScreenTitle),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      body: _body(),
    );
  }

  Widget _imageCard() {
    return Padding(
      padding: EdgeInsets.only(
        top: ((MediaQuery.of(context).size.height * 5) / 100),
        left: ((MediaQuery.of(context).size.width * 5) / 100),
        right: ((MediaQuery.of(context).size.width * 2) / 100),
        bottom:
        ((MediaQuery.of(context).size.height * 2) / 100),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal:  16.0),
              child: Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all( 16.0),
                  child: _image(),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            _menu(),

          ],
        ),
      ),
    );
  }
  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      isImageSelected = true;

      var path1 = _croppedFile!.path;
      file = File(path1);
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(File(path1)),
      );
    } else if (_pickedFile != null) {
      isImageSelected = true;

      var path1 = _pickedFile!.path;
      file = File(path1);
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(File(path1)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        FloatingActionButton(
          onPressed: () {
            _clear();
          },
          backgroundColor: Colors.redAccent,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
        if (_croppedFile == null)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton(
              onPressed: () {
                _cropImage();
              },
              backgroundColor: const Color(0xFFBC764A),
              tooltip: 'Crop',
              child: const Icon(Icons.crop),
            ),
          )
      ],
    );
  }
}
