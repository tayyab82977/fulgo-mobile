import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/ResponseViewModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/main.dart';
import 'package:lottie/lottie.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/ui/custom%20widgets/my_container.dart';
import 'package:Fulgox/ui/common/dashboard.dart';
import 'package:Fulgox/utilities/Constants.dart';

import '../../UserRepo.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AuthController _authController = Get.put(AuthController());
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    _controller!.forward().whenComplete(() {
       // Decisions are now reactive based on AuthController status
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenHeight = size.width;
    double screenWidth = size.width;
    return Obx(() {
        var status = _authController.status.value;
        
        if (status == AuthStatus.uninitialized || status == AuthStatus.loading) {
          return Scaffold(
              backgroundColor: Color(0xffFBFBFB),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EasyLocalization.of(context)!.locale == Locale('en')
                      ? Expanded(
                          child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFBFBFB),
                          ),
                          child: Lottie.asset('assets/images/en.json',
                              controller: _controller,
                              width: screenWidth,
                              height: screenHeight),
                        ))
                      : Expanded(
                          child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFBFBFB),
                          ),
                          child: Lottie.asset('assets/images/ar.json',
                              controller: _controller,
                              onLoaded: (composition) {},
                              width: screenWidth,
                              height: screenHeight),
                        ))
                ],
              ));
        } else if (status == AuthStatus.error) {
          return SafeArea(
            child: Scaffold(
              // drawer: Drawer(),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const ClientAppBar(),
                  SizedBox(
                    height: 150,
                  ),
                  Center(
                    child: Text(
                      'Please check your internet Connection and try again'
                          .tr(),
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _authController.checkAppStatus();
                    },
                    child: Text('Retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        } else if (status == AuthStatus.authenticated) {
          return ResourcesScreen();
        } else if (status == AuthStatus.unauthenticated) {
          return ChooseLanguageScreen();
        }
        
        return Container();
    });
  }
}
