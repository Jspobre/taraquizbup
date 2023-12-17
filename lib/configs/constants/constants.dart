
import 'package:flutter/material.dart';

class PageTitleConstants {
  static const String appTitle = 'Tara Quiz';
  static const String solutionScreenTitle = 'Tests Solutions';
  static const String signInScreenTitle = 'Sign In';
  static const String registerScreenTitle = 'Register';
  static const String dashboardScreenTitle = 'TARA Quiz';
  static const String resetPasswordScreenTitle = 'Forgot Password';
}

class PopUpMenuConstant {
  static const String contactUs = 'Contact Us';
  static const String changePassword = 'Change Password';
  static const String rateUs = 'Rate Us';
  static const String signOut = 'Sign Out';
  static const String exit = 'Exit';
  static const List<String> choices = <String>[
    changePassword,
    contactUs,
    rateUs,
    signOut,
    exit
  ];
}

class RoutesConstants {
  static const String launchPadScreenRoute = '/';
  static const String proLaunchPadScreenRoute = '/Pro';
  static const String signInScreenRoute = '/signIn';
  static const String cropImageRoute = '/cropImage';
  static const String essayTestRoute = '/essay';
  static const String testRoute = '/test';
  static const String registerScreenRoute = '/register';
  static const String resetPasswordScreenRoute = '/forgotPassword';
  static const String commonScreenRoute = '/common';
  static const String solutionScreenRoute = '/solution';
}

class FileConstants {
  static const String assetError = 'assets/images/Error.png';
  static const String defaultUser = 'assets/images/defaultUser.jpg';
  static const String logo = 'assets/images/logo.png';
  static const String assetSuccess = 'assets/images/Success.jpg';
  static const String assetBackground = 'assets/images/appBackground.jpg';
  static const String assetGoogle = 'assets/images/GoogleGLogo.png';
  static const String assetBuzzerAudio = 'assets/audio/buzzer.mp3';
}

class AppButtonsConstants {
  static const okayButton = 'Okay';
  static const practiceTestButton = 'Ready, All the Best!';



  static const drawerButtonsColors = <Color>[
    Colors.blue,

    Colors.red,
    Colors.purple,
    Colors.amber,
    Colors.brown,

  ];
  static const drawerButtonsName = <String>[
    "My Profile",

    "Contact us",
    "Support",
    "Logout",
    "Exit",


  ];
  static const drawerButtonsIcons = <IconData>[
    Icons.person,

    Icons.contact_page,
    Icons.support_agent,
    Icons.logout,
    Icons.exit_to_app,

  ];
  static const drawerProButtonsColors = <Color>[
    Colors.blue,
    Colors.green,

    Colors.amber,
    Colors.brown,

  ];
  static const drawerProButtonsName = <String>[
    "My Profile",

    "Support",
    "Logout",
    "Exit",


  ];
  static const drawerProButtonsIcons = <IconData>[
    Icons.person,

    Icons.support_agent,
    Icons.logout,
    Icons.exit_to_app,

  ];
}

class AppConstants {
  static const divider1 = "<--@@&@@-->";
  static const divider2 = "<--@&@-->";
  static const divider3 = "<--&-->";
  static const divider4 = "<---->";
  static const divider5 = "<->";
  static const defaultStringConstant = 'default_str';
  static const defaultBoolConstant = false;
  static const defaultMapConstant = <String,dynamic>{    "default" : "default",};
  static const defaultURLConstant = "https://source.unsplash.com/dLij9K4ObYY" ;

}



