import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/main.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/utilities/Constants.dart';

class ClientAppBar extends StatelessWidget {
  const ClientAppBar();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return Padding(
      padding: EdgeInsets.only(right: screenWidth*0.03, left: screenWidth*0.03,top: 40),

      child: Stack(
        children: [

          EasyLocalization.of(context)!.locale == Locale('en') ?

          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ResourcesScreen(
                    ),
                  ),
                      (route) => false,
                );
              },
              child: Hero(
                tag: 'appLogo',
                child: Image.asset('assets/images/appstore.png',
                  width: screenWidth*0.22,
                  height: screenHeight*0.15,
                  colorBlendMode: BlendMode.darken,
                  // fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ) :
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ResourcesScreen(
                    ),
                  ),
                      (route) => false,
                );
              },
              child: Hero(
                tag: 'appLogo',
                child: Image.asset('assets/images/logo-ar.png',
                  width: screenWidth*0.22,
                  height: screenHeight*0.15,
                  colorBlendMode: BlendMode.darken,
                  // fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),

          // Align(
          //   alignment: Alignment.center,
          //   child: GestureDetector(
          //     onTap: (){
          //       Navigator.pushAndRemoveUntil(
          //         context,
          //         MaterialPageRoute(
          //           builder: (BuildContext context) => ResourcesScreen(
          //           ),
          //         ),
          //             (route) => false,
          //       );
          //     },
          //     child: Hero(
          //       tag: 'appLogo',
          //       child: Image.asset('assets/images/X original.png',
          //         // width: screenWidth*0.2,
          //         height: screenHeight*0.1,
          //         colorBlendMode: BlendMode.darken,
          //         // fit: BoxFit.fitWidth,
          //       ),
          //     ),
          //   ),
          // ),


          EasyLocalization.of(context)!.currentLocale == Locale('en') ?

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: GestureDetector(
                  onTap: (){
                      EasyLocalization.of(context)!.setLocale(Locale('ar'));
                      Constants.currentLocale = 'ar';
                      userRepository.persistLocale(locale: 'ar');
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (BuildContext context) => ResourcesScreen()),
                            (route) => false,);
                      // RestartWidget.restartApp(context);
                  },
                  // color: Colors.white,
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child:Container(
                      // decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     border: Border.all(color: Constants.blueColor),
                      //     borderRadius: BorderRadius.circular(8)
                      // ),
                      child: Text("Ar" ,  style: TextStyle(color: Constants.blueColor , decoration: TextDecoration.underline)))),
            ),
          ):
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: GestureDetector(
                  onTap: (){

                      EasyLocalization.of(context)!.setLocale(Locale('en'));
                      userRepository.persistLocale(locale: 'en');
                      Constants.currentLocale = 'en';
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (BuildContext context) => ResourcesScreen()),
                            (route) => false,);
                      // RestartWidget.restartApp(context);
                  },
                  // color: Colors.white,
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child:Container(
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   border: Border.all(color: Constants.blueColor),
                      //   borderRadius: BorderRadius.circular(8)
                      // ),
                      child: Text("En" , style: TextStyle(color: Constants.blueColor , decoration: TextDecoration.underline),))),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                top: 15
              ),child: GestureDetector(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios , size: 16, color: Constants.blueColor,),
                  Text("Back".tr() , style: TextStyle(color: Constants.blueColor , fontSize: 16 ),)
                ],
              ),
            ),
            ),
          )

        ],
      ),
    );
  }
}





class ClientAppBarNoAction extends StatefulWidget {
  @override
  _ClientAppBarNoActionState createState() => _ClientAppBarNoActionState();
}

class _ClientAppBarNoActionState extends State<ClientAppBarNoAction> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(right: screenWidth*0.03, left: screenWidth*0.03, top: screenHeight*0.01 ),

        child: Row(
          textBaseline: TextBaseline.ideographic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            EasyLocalization.of(context)!.locale == Locale('en') ?

            Hero(
              tag: 'appLogo',
              child: Image.asset('assets/images/appstore.png',
                width: screenWidth*0.22,
                height: screenHeight*0.15,
                colorBlendMode: BlendMode.darken,
                // fit: BoxFit.fitWidth,
              ),
            ) :
            Hero(
              tag: 'appLogo',
              child: Image.asset('assets/images/logo-ar.png',
                width: screenWidth*0.22,
                height: screenHeight*0.15,
                colorBlendMode: BlendMode.darken,
                // fit: BoxFit.fitWidth,
              ),
            ),


            EasyLocalization.of(context)!.currentLocale == Locale('en') ?

            MaterialButton(
                onPressed: (){
                  setState(() {
                    EasyLocalization.of(context)!.setLocale(Locale('ar'));
                    Constants.currentLocale = 'ar';
                    userRepository.persistLocale(locale: 'ar');
                    // Navigator.pushAndRemoveUntil(context,
                    //   MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()),
                    //       (route) => false,);
                    // RestartWidget.restartApp(context);

                  });
                },
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Text('العربية' ,
                  style: TextStyle(
                      fontFamily: 'Tajawal'
                  ),
                )) :
            MaterialButton(
                onPressed: (){

                  setState(() {
                    EasyLocalization.of(context)!.setLocale(Locale('en'));
                    userRepository.persistLocale(locale: 'en');
                    Constants.currentLocale = 'en';
                    // Navigator.pushAndRemoveUntil(context,
                    //   MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()),
                    //       (route) => false,);
                    // RestartWidget.restartApp(context);

                  });
                },
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Text('English',
                  style: TextStyle(
                      fontFamily: 'Poppins'
                  ),

                ))

          ],
        ),
      ),
    );
  }
}






class MenuButton extends StatelessWidget {
  GlobalKey<ScaffoldState>? drawerKey ;
  MenuButton({this.drawerKey});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return Row(
      children: [
        Container(
          width: 81,
          height: 40,
          child: FlatButton(
            key: const ValueKey('menu'),
            minWidth: 0,
            padding: EdgeInsets.all(6),

            onPressed:(){
              drawerKey!.currentState!.openDrawer();
            },
            color:Color(0xFFF1F1F1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.more_vert , size: 15,),
                Text(
                  "Menu".tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CaptainAppBar extends StatelessWidget {
  GlobalKey<ScaffoldState>? drawerKey ;
  CaptainAppBar({this.drawerKey});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MenuButton(
              drawerKey:drawerKey ,
            ),
            EasyLocalization.of(context)!.locale == Locale('en') ?

            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Hero(
                tag: 'appLogo',
                child: Image.asset('assets/images/appstore.png',
                  width: 110,
                  height:70 ,
                  colorBlendMode: BlendMode.darken,
                  // fit: BoxFit.fitWidth,
                ),
              ),
            ) :
            Hero(
              tag: 'appLogo',
              child: Image.asset('assets/images/logo-ar.png',
                width: 110,
                height:70 ,
                colorBlendMode: BlendMode.darken,
                // fit: BoxFit.fitWidth,
              ),
            ),



          ],
        ),
      ),
    );
  }
}



class CaptainAppBarGradient extends StatelessWidget {
  GlobalKey<ScaffoldState>? drawerKey ;
  CaptainAppBarGradient({this.drawerKey});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return Container(
      height: screenHeight*0.4,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffE0DAE8), Color(0xffE6C7D0)])
        ),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MenuButton(
                  drawerKey:drawerKey ,
                ),
                EasyLocalization.of(context)!.locale == Locale('en') ?

                Hero(
                  tag: 'appLogo',
                  child: Image.asset('assets/images/appstore.png',
                    width: 110,
                    height:70 ,
                    colorBlendMode: BlendMode.darken,
                    // fit: BoxFit.fitWidth,
                  ),
                ) :
                Hero(
                  tag: 'appLogo',
                  child: Image.asset('assets/images/logo-ar.png',
                    width: 110,
                    height:70 ,
                    colorBlendMode: BlendMode.darken,
                    // fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


