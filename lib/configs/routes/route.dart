
import 'package:flutter/material.dart';


import '../../dashboard/dashboard.dart';
import '../../proDashboard/proDashboard.dart';
import '../../sign_in/sign_in.dart';
import '../../test/test.dart';
import '../constants/constants.dart';


class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Object? model = settings.arguments;
    switch (settings.name) {
      case RoutesConstants.signInScreenRoute:
        return MaterialPageRoute(
          maintainState: false,

          builder: (_) => SignIn(),
        );

     case RoutesConstants.launchPadScreenRoute:
        return MaterialPageRoute(
          maintainState: false,
          builder: (_) => Dashboard(),
        );

      case RoutesConstants.proLaunchPadScreenRoute:
        return MaterialPageRoute(
          maintainState: false,

          builder: (_) => ProDashboard(),
        );

      default:
        return errorRoute();
    }
  }
}

Route<dynamic> errorRoute() {
  return MaterialPageRoute(builder: (_) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: const Center(
        child: Text('ERROR loading the Screen,\nplease try again later.'),
      ),
    );
  });
}
