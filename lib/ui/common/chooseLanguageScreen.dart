import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/common/Login.dart';
import 'package:xturbox/ui/common/SignUp.dart';
import 'package:xturbox/ui/common/newTrackingScreen.dart';
import 'package:xturbox/utilities/Constants.dart';

import 'introSliderScreen.dart';





class ChooseLanguageScreen extends StatefulWidget {
  ResourcesData? resourcesData ;


  ChooseLanguageScreen({this.resourcesData});
  @override
  _ChooseLanguageScreenState createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {

  UserRepository userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();
  }
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          final Uri? deepLink = dynamicLink?.link;

          if (deepLink != null) {

            if(deepLink.path.contains("/tracking")){
              String? id = deepLink.queryParameters['tracking_number'];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewTrackingScreen(shipmentId: id,)));
            }
            if(deepLink.path.contains("/register")){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpScreen()));
            }

          }
        },
        onError: (OnLinkErrorException e) async {
        }
    );

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {

      if(deepLink.path.contains("/tracking")){
        String? id = deepLink.queryParameters['tracking_number'];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewTrackingScreen(shipmentId: id,)));
      }
      if(deepLink.path.contains("/register")){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignUpScreen()));
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return Scaffold(
      backgroundColor: Constants.blueColor,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/LangBackground.png'),
                fit: BoxFit.cover
            )
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: EasyLocalization.of(context)?.currentLocale == Locale("en") ? MainAxisAlignment.start :  MainAxisAlignment.end,
                  children: [
                    Hero(
                      tag:'appLogo',
                      child: Image.asset('assets/images/XTURBO WHITE N RED.png',
                        width: 120,
                        colorBlendMode: BlendMode.darken,
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                // Spacer(),
                // Text('أفضل تطبيق لوجستي', style: TextStyle(
                //     fontWeight: FontWeight.w900,
                //     fontSize: 35,
                //     color: Colors.white,
                //     fontFamily: 'Cairo'
                // ),),
                SizedBox(height: screenHeight*0.5,),
                Padding(
                  padding:EdgeInsets.only(bottom: 10 , right: 20 , left: 20),
                  child: Text('اختر اللغة',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 24
                    ),),
                ),
                Padding(
                  padding:EdgeInsets.all(10),
                  child: Container(
                    width: screenWidth*0.5,
                    height: screenHeight*0.1,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.02),
                          spreadRadius: 10,
                          blurRadius: 15,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(20))),
                      color: Colors.white,
                      child: Text('العربية' , style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 19
                      ),),
                      onPressed: (){
                        EasyLocalization.of(context)!.setLocale(Locale('ar')) ;
                        userRepository.persistLocale(locale: "ar");
                        Constants.currentLocale = 'ar';
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>LoginScreen(resourcesData: widget.resourcesData,)));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding:EdgeInsets.all(5),
                  child: Container(
                    width: screenWidth*0.5,
                    height: screenHeight*0.1,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.02),
                          spreadRadius: 10,
                          blurRadius: 15,
                          offset: Offset(0, 3),// changes position of shadow
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      key: const ValueKey('englishButton'),
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(20))),
                      color: Colors.white,
                      child: Text('English',
                        style: TextStyle(
                            fontFamily: 'Poppins'
                        ),
                      ),
                      onPressed: (){
                        EasyLocalization.of(context)!.setLocale(Locale('en')) ;
                        userRepository.persistLocale(locale: "en");

                        Constants.currentLocale = 'en';

                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>LoginScreen(resourcesData: widget.resourcesData,)));

                      },
                    ),

                  ),
                ),
                Spacer(flex: 2,),
                // FlatButton(
                //     padding: EdgeInsets.all(0),
                //     minWidth:screenWidth*0.6 ,
                //     height: screenHeight*0.1,
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                //     color:  Color(0xFF42B566),
                //     child: Text('Start'.tr(),
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontSize: screenWidth*0.05
                //
                //       ),),
                //     onPressed: (){
                //       Navigator.pushAndRemoveUntil(context,
                //         MaterialPageRoute(builder: (BuildContext context) => IntroSliderScreen()),
                //             (route) => false,);
                //     }
                // ),
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/images/LangBackground.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,),
          Positioned(
            top:  20,
            left: -20,
            height: 45,
            child: Hero(
              tag:'appLogo',
              child: Image.asset('assets/images/xturbo_white_icon.png',
                width: screenWidth*0.55,
                colorBlendMode: BlendMode.darken,
                // fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Positioned(
              top: screenHeight * 0.6,
              right: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('أفضل تطبيق لوجستي', style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 35,
                      color: Colors.white,
                      fontFamily: 'Cairo'
                  ),)

                ],
              )),
          Center(
            // top: 300,
            // left: screenWidth*0.5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 350,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:EdgeInsets.only(bottom: 10 , right: 20 , left: 20),
                      child: Text('اختر اللغة',
                        style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: Colors.white,
                            fontSize: 20
                        ),),
                    ),
                    Padding(
                      padding:EdgeInsets.all(10),
                      child: Container(
                        width: screenWidth*0.5,
                        height: screenHeight*0.1,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.02),
                              spreadRadius: 10,
                              blurRadius: 15,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(20))),
                          color: Colors.white,
                          child: Text('العربية' , style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 19
                          ),),
                          onPressed: (){
                            EasyLocalization.of(context)!.setLocale(Locale('ar')) ;
                            userRepository.persistLocale(locale: "ar");
                            Constants.currentLocale = 'ar';
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>LoginScreen(resourcesData: widget.resourcesData,)));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:EdgeInsets.all(5),
                      child: Container(
                        width: screenWidth*0.5,
                        height: screenHeight*0.1,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.02),
                              spreadRadius: 10,
                              blurRadius: 15,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: MaterialButton(
                          key: const ValueKey('englishButton'),
                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(20))),
                          color: Colors.white,
                          child: Text('English',
                            style: TextStyle(
                                fontFamily: 'Poppins'
                            ),
                          ),
                          onPressed: (){
                            EasyLocalization.of(context)!.setLocale(Locale('en')) ;
                            userRepository.persistLocale(locale: "en");

                            Constants.currentLocale = 'en';

                            Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>LoginScreen(resourcesData: widget.resourcesData,)));

                          },
                        ),

                      ),
                    ),
                    // FlatButton(
                    //     padding: EdgeInsets.all(0),
                    //     minWidth:screenWidth*0.6 ,
                    //     height: screenHeight*0.1,
                    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    //     color:  Color(0xFF42B566),
                    //     child: Text('Start'.tr(),
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: screenWidth*0.05
                    //
                    //       ),),
                    //     onPressed: (){
                    //       Navigator.pushAndRemoveUntil(context,
                    //         MaterialPageRoute(builder: (BuildContext context) => IntroSliderScreen()),
                    //             (route) => false,);
                    //     }
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
