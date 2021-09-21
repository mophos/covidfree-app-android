
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(CovidFreeApp());
}

class CovidFreeApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('th', 'TH'),
      supportedLocales: [
        const Locale('th', 'TH'), // Thai
      ],
      title: 'Covid free',
      theme: ThemeData(
          fontFamily: 'Kanit',
          appBarTheme: AppBarTheme(backgroundColor: Color(0xff1a237e), foregroundColor: Colors.white),
          primaryColor: Color(0xff1a237e),),
      home: LoginPage(),
    );
  }
}
