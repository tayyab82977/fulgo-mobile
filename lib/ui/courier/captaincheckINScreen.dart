import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/checkIn_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/checkIn_events.dart';
import 'package:xturbox/blocs/states/checkIn_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/ui/courier/newCaptainDashboard.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/location.dart';

import '../../main.dart';
import 'captainDashboard.dart';
import '../custom widgets/custom_loading.dart';

class CheckInScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  ProfileDataModel? dashboardDataModel ;
  CheckInScreen({this.resourcesData,this.dashboardDataModel});


  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  AuthenticationBloc authenticationBloc = AuthenticationBloc();
  ProfileDataModel dashboardDataModel = ProfileDataModel();

  Future<Null> getUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences = await SharedPreferences.getInstance();
    Map<String, dynamic>? userMap;
    final String? userStr = preferences.getString('userData');
    if (userStr != null) {
      userMap = jsonDecode(userStr) as Map<String, dynamic>?;
    }
    if (userMap != null) {

      final ProfileDataModel userData = ProfileDataModel.fromJson(userMap);
      setState(() {
        dashboardDataModel = userData ;

      });
    }
  }

  Timer? timer ;
  CheckInBloc checkInBloc = CheckInBloc();

  double? screenWidth ;
  late double  screenHeight;
  @override
  void dispose() {
    checkInBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    try{
      getUserData();

    }
    catch(e){
      checkInBloc.add(CheckInEventsGenerateError());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
      screenHeight = size.height;
    return SafeArea(
      child: BlocConsumer<CheckInBloc , CheckInStates>(
        bloc: checkInBloc,
        builder: (context, state) {
          if (state is CheckInInitial) {

            return OutWorkScreen();
          }

          else if (state is CheckInActiveSuccess) {
            return  NewCaptainDashboard(
              resourcesData: widget.resourcesData,
            );
          }
          else if (state is CheckInLoading){
            return Scaffold(
              body: Column(
                children: [
                  CaptainAppBar(),
                  Expanded(
                    child: Center(
                      child: CustomLoading(),
                    ),
                  ),
                ],
              ) ,
            );
          }
        else if (state is CheckInNotActiveSuccess) {

            return OutWorkScreen();
          }
          return OutWorkScreen();



        },




        listener: (context , state){
          if(state is CheckInFailure){
           if (state.error == 'needUpdate'){
             GeneralHandler.handleNeedUpdateState(context);
          }
           else if(state.error == "invalidToken"){
             GeneralHandler.handleInvalidToken(context);
           }
           else if (state.error == "general"){
             GeneralHandler.handleGeneralError(context);
           }
          }
          else if (state is CheckInActiveSuccess){
          }
          else if (state is CheckInNotActiveSuccess){

            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DashboardScreen(
                    resourcesData: widget.resourcesData,
                  ),
                ),
                    (route) => false,
              );
            });
          }
        },
      ),
    );
  }

  Widget OutWorkScreen (){
    return  Scaffold(
      backgroundColor: Colors.white,
      body:ListView(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          EasyLocalization.of(context)!.locale == Locale('en') ?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
              tag: 'appLogo',
              child: Image.asset('assets/images/appstore.png',
                width: 140,
                height:screenHeight*0.08 ,
                colorBlendMode: BlendMode.darken,
                // fit: BoxFit.fitWidth,
              ),
            ),
          ) :
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
              tag: 'appLogo',
              child: Image.asset('assets/images/logo-ar.png',
                width: 140,
                height:screenHeight*0.08 ,
                colorBlendMode: BlendMode.darken,
                // fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(height: screenHeight*0.02,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/newProfile.png', height: 40,),
              ),
              Center(
                child: Text(dashboardDataModel.name ?? '',style: TextStyle(
                    fontSize: 20
                ),),
              ),
            ],
          ),
          SizedBox(height: screenHeight*0.04,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Constants.greyColor,
                    borderRadius: BorderRadius.all(Radius.circular(25),)
                ),
                child: Column(
                  children: [
                    Text(widget.dashboardDataModel!.orders??'0',
                      style: TextStyle(
                          color: Constants.redColor,
                          fontSize: screenWidth!*0.05,
                          fontWeight: FontWeight.w900
                      ),
                    ),
                    Text('Waiting orders'.tr(),
                      style: TextStyle(
                          color: Constants.redColor,
                          fontSize: screenWidth!*0.05,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   width: 2,
              //   height: screenHeight*0.07,
              //   color: Colors.grey.shade50,
              // ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Constants.greyColor,
                    borderRadius: BorderRadius.all(Radius.circular(25),)
                ),
                child: Column(
                  children: [
                    Text(widget.dashboardDataModel!.done??'0',
                      style: TextStyle(
                          color: Constants.blueColor,
                          fontSize: screenWidth!*0.05,
                          fontWeight: FontWeight.w900
                      ),
                    ),
                    Text('Finished orders'.tr(),
                      style: TextStyle(
                          color: Constants.blueColor,
                          fontSize: screenWidth!*0.05,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight*0.04,),

          Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment:Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Constants.greyColor,
                        borderRadius: BorderRadius.only(topLeft:Radius.circular(30), topRight: Radius.circular(30))
                    ),
                    height: screenHeight*0.4,
                    width: screenWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height:screenHeight*0.5 ,
                  child: Column(
                    children: [
                      Padding(
                        padding:EdgeInsets.all(8.0),
                        child: Container(
                          width: screenWidth!*0.32,
                          height: screenWidth!*0.32,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle
                          ),
                          child: GestureDetector(
                            onTap: (){
                              checkInBloc.add(IamActive());
                            },
                            child: Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Constants.blueColor,
                                  shape: BoxShape.circle
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:EdgeInsets.only(left: 10),
                                      child: SvgPicture.asset(
                                        "assets/images/triangle.svg",
                                        placeholderBuilder: (context) => CustomLoading(),
                                        height: 40.0,
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Text('Start shift'.tr(), style: TextStyle(color: Colors.white, fontSize: screenWidth!*0.035),)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3,),
                      Icon( Icons.arrow_upward , size: screenHeight*0.03 ),
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text('Click on the button above'.tr(),

                                style: TextStyle( fontSize: screenWidth!*0.04),),
                              Text('to start working'.tr(),
                                style: TextStyle(fontSize: screenWidth!*0.04),),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5 , horizontal: 90),
                        child: FlatButton(
                          height: screenHeight*0.05,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          onPressed: (){
                            authenticationBloc.add(LoggedOut());
                            Future.delayed(const Duration(milliseconds: 400), () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => ChooseLanguageScreen(),
                                ),
                                    (route) => false,
                              );
                            });
                          },
                          color: Constants.redColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text('Logout'.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth!*0.035
                                  ),

                                ),
                              ),

                              Icon(
                                Icons.logout , color: Colors.white, size: 20,),

                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),


        ],
      ) ,
    );
  }
}
