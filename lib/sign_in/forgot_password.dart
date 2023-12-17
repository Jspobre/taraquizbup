
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taraquizbup/widgets/custom_dialog.dart';

import '../configs/constants/constants.dart';
import 'model/sign_in_model.dart';




class ResetPassword extends StatelessWidget {

  ResetPassword({ Key? key}) : super(key: key);
  final TextEditingController controllerEMailID = TextEditingController();
  final FocusNode focusNodeEMailId = FocusNode();

  final SignInModel signInModel = SignInModel();
  final CustomDialog customDialog = CustomDialog();

  @override
  Widget build(BuildContext context) {
    onPressedReset()  {
      Connectivity().checkConnectivity().then((value) {
        if (value == ConnectivityResult.mobile ||
            value == ConnectivityResult.wifi) {
          try {
            FirebaseAuth.instance
                .sendPasswordResetEmail(email: signInModel.eMailId)
                .then((value) {
              customDialog.customSuccessDialog("Success", context, false, false);
            });
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              customDialog.customErrorDialog(
                'No user exists with this email.',
                context,
              );

            } else if (e.code == 'invalid-email') {
              customDialog.customErrorDialog(
                'Invalid-email. Please check the email entered.',
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
        } else {
          customDialog.customErrorDialog(
            'Please check your internet connectivity.',
            context,
          );
        }
      });}

    body() {
      return      //Forgot password
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    top: ((MediaQuery
                        .of(context)
                        .size
                        .height * 5) / 100),
                    bottom: ((MediaQuery
                        .of(context)
                        .size
                        .height * 4) / 100),
                  ),
                  child: Text(
                    'Please enter e-mail id below.',
                    maxLines: 2,
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineSmall
                    ,
                  ),
                ),


                Padding(
                  padding: EdgeInsets.only(
                    left: ((MediaQuery
                        .of(context)
                        .size
                        .width * 8) / 100),
                    right: ((MediaQuery
                        .of(context)
                        .size
                        .width * 8) / 100),
                    bottom: ((MediaQuery
                        .of(context)
                        .size
                        .height * 2) / 100),
                  ),
                  child: TextField(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your email id',
                    ),
                    onChanged: (e) {
                      signInModel.eMailId = e;
                    },
                    onTap: () {
                      controllerEMailID.text = '';
                    },
                    autocorrect: false,
                    focusNode: focusNodeEMailId,
                    obscureText: false,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    controller: controllerEMailID,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: ((MediaQuery
                          .of(context)
                          .size
                          .height * 4) / 100),
                      bottom: ((MediaQuery
                          .of(context)
                          .size
                          .height * 4) / 100)),
                  child: ElevatedButton(
                    onPressed: onPressedReset,
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1.0),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title:  const Text(PageTitleConstants.resetPasswordScreenTitle),
      ),
      body: body(),
    );
  }

}
