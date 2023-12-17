import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../configs/constants/constants.dart';



class CustomDialog{
  void customErrorDialog(String message, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              title: const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 60,
              ),
              content: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 7,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (message == "An error has occurred please try again later." || message == "Please check your internet connection and try again.") {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Text(
                    'Okay',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.blue),
                  ),
                ),
              ]);
        });
  }

  void customSuccessDialog(String message, BuildContext context, bool landing,   bool proLanding,) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              title: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              content: Text(

                message,
                maxLines: 7,
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      'Okay',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.blue),
                    ),
                    onPressed: () {

                      if (landing){

                          Navigator.of(context).pushNamedAndRemoveUntil(
                            RoutesConstants.launchPadScreenRoute,
                                (Route<dynamic> route) => false,
                          );

                      } else if (proLanding){

                          Navigator.of(context).pushNamedAndRemoveUntil(
                            RoutesConstants.proLaunchPadScreenRoute,
                                (Route<dynamic> route) => false,
                          );

                      } else {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          RoutesConstants.signInScreenRoute,
                              (Route<dynamic> route) => false,
                        );
                      }

                    }),
              ]);
        });
  }



}
