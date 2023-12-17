/*
import 'package:flutter/material.dart';
import 'package:taraquiz/dashboard/model/commonPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new CommonPage(title: 'Flutter Demo Home Page'),
    );
  }
}*/

import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taraquizbup/dashboard/selectSubject.dart';
import 'package:taraquizbup/proDashboard/proDashboard.dart';
import 'package:taraquizbup/sign_in/model/sign_in_model.dart';
import 'package:taraquizbup/sign_in/register.dart';
import 'package:taraquizbup/test/multi.dart';

import 'configs/constants/constants.dart';
import 'configs/routes/route.dart';
import 'configs/themes/style.dart';
import 'mixins/mixins.dart';





Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();

  await Future.delayed(const Duration(seconds: 3)).then((value) async {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
      kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    ).whenComplete(() async {
      Snippet snippet = Snippet();
      final checkConnection = snippet.connectivityCheck();
      bool checkAuth = false;
      bool error = false;
      if (await checkConnection) {
        checkAuth = snippet.check();
      } else {
        error = true;
      }
      await getApplicationDocumentsDirectory().then((value) { Hive.init(value.path);

      Hive.registerAdapter(SignInModelAdapter());
      runApp(MyApp(checkAuth: checkAuth, loadError: error));
      });
    });
    });}

class MyApp extends StatelessWidget {
  final bool checkAuth;
  final bool loadError;
  const MyApp({Key? key, required this.checkAuth,required this.loadError }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Style theme = Style();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme.customTheme(context),
     //home: SelectSubject(),

    onGenerateRoute: Routes.generateRoute,

      onGenerateInitialRoutes: (String initialRouteName) {
        return [
          Routes.generateRoute(
            const RouteSettings(

                name: RoutesConstants.signInScreenRoute,
               arguments: null),

          ),
        ];
      },
    );
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}