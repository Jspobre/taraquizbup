import 'package:flutter/material.dart';

class Style {
  Style();

  ThemeData customTheme(BuildContext context) {
    return ThemeData(
      bottomAppBarTheme: const BottomAppBarTheme(color: Colors.black54),
      colorSchemeSeed: const Color(0xff6750a4),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 7.3,
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white70,
          titleTextStyle: TextStyle(
              fontSize: 22.041984,
              fontFamily: 'SFPro',
              overflow: TextOverflow.ellipsis,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal)),
      scaffoldBackgroundColor: const Color.fromRGBO(240, 240, 240, 1.0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return Colors.white;
            },
          ),
          textStyle: MaterialStateProperty.resolveWith<TextStyle>(
            (Set<MaterialState> states) {
              return const TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                  letterSpacing: 1.4);
            },
          ),
          fixedSize: MaterialStateProperty.resolveWith<Size>(
            (Set<MaterialState> states) {
              return const Size(220, 50);
            },
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              return 4.0;
            },
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return Colors.black45;
            },
          ),
          shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
            (Set<MaterialState> states) {
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(width: 0.1, style: BorderStyle.solid),
              );
            },
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.redAccent,
            fontFamily: 'SFPro',
            fontSize: 18,
            fontWeight: FontWeight.w700),
      ),
      dividerTheme: const DividerThemeData(color: Colors.transparent),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.blue,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700),
        displayMedium: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.blue,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w700),
        displaySmall: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.blue,
            fontFamily: 'DejaVuSans',
            fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.black87,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.black87,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold),
        bodySmall: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.black87,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.deepOrange,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.deepOrange,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.deepOrange,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.green,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.green,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700),
        titleSmall: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.green,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w700),
        labelLarge: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.black54,
            fontFamily: 'DejaVuSans',
            fontWeight: FontWeight.bold),
        labelMedium: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.black54,
            fontFamily: 'DejaVuSans',
            fontWeight: FontWeight.w700),
        labelSmall: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: Colors.black54,
            fontFamily: 'DejaVuSans',
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
