import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xturbox/ui/common/introSliderScreen.dart';

class SuccessRegistration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return Scaffold(
      body:  Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EasyLocalization.of(context)!.locale == Locale('en') ?
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Hero(
                  tag: 'appLogo',
                  child: Image.asset('assets/images/appstore.png',
                    width: screenWidth*0.55,
                    colorBlendMode: BlendMode.darken,
                    // fit: BoxFit.fitWidth,
                  ),
                ),
              ) :
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Hero(
                  tag: 'appLogo',
                  child: Image.asset('assets/images/logo-ar.png',
                    width: screenWidth*0.55,

                    colorBlendMode: BlendMode.darken,
                    // fit: BoxFit.fitWidth,
                  ),
                ),
              ) ,
              SizedBox(height: screenHeight*0.1,),
              SvgPicture.asset(
                "assets/images/success.svg",
                height: screenWidth*0.18,
              ),
              SizedBox(height: screenHeight*0.05,),
              Text('Congratulations'.tr(),
                style: TextStyle(fontSize: screenWidth*0.08),
              ),
              SizedBox(height: 5,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Your account has been created successfully'.tr(),
                    style: TextStyle(fontSize: screenWidth*0.05),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2,),
                  Text('We hope you enjoy our services'.tr(),
                    style: TextStyle(fontSize: screenWidth*0.05),
                  ),
                  SizedBox(height: screenHeight*0.08,),
                  FlatButton(
                      padding: EdgeInsets.all(0),
                      minWidth:screenWidth*0.6 ,
                      height: screenHeight*0.1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color:  Color(0xFF42B566),
                      child: Text('Start'.tr(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth*0.05

                        ),),
                      onPressed: (){
                        Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (BuildContext context) => IntroSliderScreen()),
                              (route) => false,);
                      }
                  ),
                ],
              ),




            ],
          ),
        ),
      )
    );
  }
}
