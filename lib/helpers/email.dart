
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailjet/mailjet.dart';


String apiKey = "a54e3b17cdbc69a7f5c716f1b8f9b7dc";
String secretKey = "91323d677798204bd82336d28777c7d2";
//An email registered to your mailjet account
String myContactEmail = "taraapp446@gmail.com";
String mySupportReceiverEmail = "taraapp446@gmail.com";
String myContactReceiverEmail = "taraapp446@gmail.com";




class Mail {
  Mail();
  Future<void> sendEmail(context, String title, String name, String emailID,
       String sub, String query) async {
    try {
      String message = '''  Hi from $name <br />     Details:\n Subject - $sub \n email id- $emailID \n<br /><br /><br />    $query Thank You & Regards,<br />     Tara Quiz Team''';
      String subject = "Tara Quiz: $title $sub";

      MailJet mailJet = MailJet(
        apiKey: apiKey,
        secretKey: secretKey,
      );
      await mailJet.sendEmail(
        subject: subject,
        sender: Sender(
          email: myContactEmail,
          name: "Tara Quiz",
        ),
        reciepients: [
          Recipient(
            email: title == "Support"
                ? mySupportReceiverEmail
                : myContactReceiverEmail,
            name: "Tara Quiz",
          ),
        ],
        htmlEmail: message,
      ).whenComplete(() {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(30)),
                  title: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  content: const Text(
                    "Success",
                    maxLines: 7,
                    textAlign: TextAlign.center,
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text(
                          'Okay',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                              color: Colors.blue),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ]);
            });
      }).onError((error, stackTrace) =>
          new ErrorLogger().log(error!, stackTrace));
    } catch (e) {
      new ErrorLogger().log1(e);
    }
  }
}
class ErrorLogger {
  FutureOr<String> log1(Object data) async {
    // print(data);
    // print(stackTrace);
    return await _sendToServer1(data.toString());
  }


  FutureOr<String> log(Object data, StackTrace stackTrace) async {
    // print(data);
    // print(stackTrace);
    return await _sendToServer(data.toString(), stackTrace.toString());
  }

  FutureOr<String> _sendToServer(String a, String b) async {
    // Implementation here
    return "error";
  }
  FutureOr<String> _sendToServer1(String a) async {
    // Implementation here
    return "error";
  }
}