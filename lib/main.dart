
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart'as Toast;
import 'package:overlay_support/overlay_support.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/controllers/resources_controller.dart';
import 'package:Fulgox/controllers/profile_controller.dart';
import 'package:Fulgox/ui/common/SignUp.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/common/splash.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/comFunctions.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp() ;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  UserRepository userRepository = UserRepository();
  String? validLocale = await userRepository.getLocale();
  if(validLocale != null){
    Constants.currentLocale = validLocale;
  }

  runApp(EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/locale',
      useOnlyLangCode: true,
      startLocale: Locale(Constants.currentLocale),
      // fallbackLocale: Locale(Constants.currentLocale ?? 'ar'),
      child: MyApp()));
}




class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
   super.initState();
  }


  @override
  Widget build(BuildContext context) {
    //only portrait mode prevent screen rotate
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OverlaySupport(
        child: GetMaterialApp(
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            primaryColor: Constants.blueColor,
            secondaryHeaderColor: Colors.green,
            // textSelectionColor: Colors.red,
            dividerColor: Colors.transparent,
            bottomSheetTheme: BottomSheetThemeData(
              // color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Constants.blueColor,
              selectionColor: Colors.grey.withOpacity(0.5),
              selectionHandleColor: Constants.blueColor,
            ),
            fontFamily:  EasyLocalization.of(context)!.locale == Locale('en') ?
            'Poppins' : 'Cairo',
          ),
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        ),
      );
  }
}
