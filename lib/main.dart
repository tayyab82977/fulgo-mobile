
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
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/addAcount_bloc.dart';
import 'package:xturbox/blocs/bloc/checkIn_bloc.dart';
import 'package:xturbox/blocs/bloc/internetBloc.dart';
import 'package:xturbox/blocs/bloc/invoices_bloc.dart';
import 'package:xturbox/blocs/bloc/nationalId_bloc.dart';
import 'package:xturbox/blocs/bloc/switchAccount_bloc.dart';
import 'package:xturbox/blocs/bloc/wallet_bloc.dart';
import 'package:xturbox/blocs/events/invoices_events.dart';
import 'package:xturbox/blocs/states/internet_state.dart';
import 'package:xturbox/ui/common/SignUp.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';

import 'package:xturbox/blocs/bloc/resources_bloc.dart';
import 'package:xturbox/blocs/events/resources_events.dart';
import 'package:xturbox/ui/common/splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';

import 'blocs/bloc/LoginBloc.dart';
import 'blocs/bloc/SignUp_Bloc.dart';
import 'blocs/bloc/addressBloc.dart';
import 'blocs/bloc/authentication_bloc.dart';
import 'blocs/bloc/clientPayments_bloc.dart';
import 'blocs/bloc/odoMeter_bloc.dart';
import 'blocs/events/address_events.dart';
import 'blocs/events/clientPayments_events.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp() ;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/locale',
      useOnlyLangCode: true,
      startLocale: Locale('ar') ,
      // fallbackLocale: Locale(Constants.currentLocale ?? 'ar'),
      child: MyApp()));
}




class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {

  FirebaseAnalytics analytics = FirebaseAnalytics();

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<ResourcesBloc>(
            create: (context)=>ResourcesBloc()
        ),
        BlocProvider<AuthenticationBloc>(
            create: (context)=>authenticationBloc=AuthenticationBloc()
        ),

        BlocProvider<CheckInBloc>(create: (context)=>CheckInBloc(),),
        BlocProvider<ODOMeterBloc>(create: (context)=>ODOMeterBloc()),
        BlocProvider<NationalIdBloc>(create: (context)=>NationalIdBloc()),
        BlocProvider<WalletBloc>(create: (context)=>WalletBloc()),
        BlocProvider<AddAccountBloc>(create: (context)=>AddAccountBloc()),
        BlocProvider<SwitchAccountBloc>(create: (context)=>SwitchAccountBloc())

    ],
      //show notification when the app is running
      child: OverlaySupport(
        child: MaterialApp(
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            primaryColor: Constants.blueColor,
            secondaryHeaderColor: Colors.green,
            textSelectionColor: Colors.red,
            dividerColor: Colors.transparent,
            bottomSheetTheme: BottomSheetThemeData(
              // backgroundColor: Colors.transparent,
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
      ),
    );
  }
}
