import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/checkIn_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/checkIn_events.dart';
import 'package:xturbox/blocs/states/checkIn_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/main.dart';
import 'package:xturbox/ui/common/mapTracking.dart';
import 'package:xturbox/ui/courier/driverDashboard.dart';
import 'package:xturbox/ui/courier/fuelManagement.dart';
import 'package:xturbox/ui/courier/bulkPickupScreen.dart';
import 'package:xturbox/ui/courier/captainMyPickup.dart';
import 'package:xturbox/ui/courier/captainProfile.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/courier/deliveryOptionsScreen.dart';
import 'package:xturbox/ui/courier/fleetManagement_options.dart';
import 'package:xturbox/ui/courier/newCaptainDashboard.dart';
import 'package:xturbox/ui/courier/odo_meter.dart';
import 'package:xturbox/ui/courier/trips_management.dart';
import 'package:xturbox/ui/courier/violations_screen.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/location.dart';
import 'package:xturbox/utilities/push_nofitications.dart';

import '../courier/captainDashboard.dart';
import '../common/dashboard.dart';
import '../courier/captainMyReserves.dart';
import 'custom_loading.dart';

class DriverDrawer extends StatefulWidget {
  double? width;

  double? height;

  ResourcesData? resourcesData;

  DriverDrawer({this.width, this.height, this.resourcesData});

  @override
  _DriverDrawerState createState() => _DriverDrawerState();
}


class _DriverDrawerState extends State<DriverDrawer> {
  UserRepository userRepository = UserRepository();
  AuthenticationBloc authenticationBloc = AuthenticationBloc();
  ProfileDataModel dashboardDataModel = ProfileDataModel();
  String? orders ;
  String? done ;
  Color blueColor = Color(0xFF2f3a92);
  Color greyColor = Color(0xFFf4f4f4);
  Color redColor = Color(0xFFBE2C33);
  Color lightRedColor = Color(0xfff8efef);
  Color lightBlueColor = Color(0xffeaebf4);//c0c3de
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
        orders = dashboardDataModel.orders ;
        done = dashboardDataModel.done ;

      });
    }
  }

  CheckInBloc checkInBloc = CheckInBloc();
  Version currentVersion = Version.parse(Constants.appVersion);
  late Version latestVersion ;

  bool newVersion = false ;
  versionCheck(){
    latestVersion= Version.parse(widget.resourcesData?.appVersion ?? "3.3.3");

    if (latestVersion > currentVersion) {
      newVersion = true ;
    }else {
      newVersion = false ;
    }

  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    try{
      getUserData();
      versionCheck();
    }
    catch(e){
      checkInBloc.add(CheckInEventsGenerateError());
    }
    getUserData();
    checkInBloc.add(GetCaptainProfileForDrawer());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return Padding(
      padding: EasyLocalization.of(context)!.locale == Locale('en') ? EdgeInsets.only(right: 15 , top: 10) : EdgeInsets.only(left: 15 , top: 10) ,
      child: Material(
        color: Colors.white,
        borderRadius: EasyLocalization.of(context)!.locale == Locale('en') ?
        BorderRadius.only(topRight: Radius.circular(15)) :
        BorderRadius.only(topLeft: Radius.circular(15)),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonTheme(
                      minWidth: 0,
                      height: 0,
                      child: FlatButton(
                        padding: EdgeInsets.all(0) ,
                        shape:EasyLocalization.of(context)!.locale == Locale('en') ?
                        RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15))):
                        RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15))),
                        minWidth: 0,
                        height: 0,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: greyColor,
                            borderRadius:
                            EasyLocalization.of(context)!.locale == Locale('en') ?
                            BorderRadius.only(topRight:Radius.circular(10) , bottomLeft:Radius.circular(10)  ) :
                            BorderRadius.only(topLeft:Radius.circular(10) , bottomRight:Radius.circular(10)  ),
                          ),
                          child: Icon(Icons.close , size: 20,),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CaptainProfile(
                        dashboardDataModelNew: dashboardDataModel,
                        resourcesData: widget.resourcesData,
                      )));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, ),
                      decoration: BoxDecoration(
                        // color: greyColor,
                          borderRadius: BorderRadius.circular(25)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            "assets/images/newProfile.png",
                            height: 35,
                          ),
                          SizedBox(width: 8,),
                          ConstrainedBox(
                            constraints: BoxConstraints(minWidth:50 , maxWidth: MediaQuery.of(context).size.width*0.3),
                            child: AutoSizeText(
                              SavedData.profileDataModel.name ??'',
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Colors.black, fontSize: 22,
                              ),
                            ),
                          ),


                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20 ,bottom: 20 , top: 10),
                  child: Stack(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: lightBlueColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: EasyLocalization.of(context)!.locale == Locale('en') ? Alignment.centerRight :Alignment.centerLeft ,
                          child: Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 15 , vertical: 1),
                            child: MaterialButton(
                              padding: EdgeInsets.all(0),
                              minWidth: screenWidth*0.3,
                              height: 42,
                              onPressed: (){
                                checkInBloc.add(IamNotActive());
                              },
                              color: blueColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/turnOff.svg",
                                    color: Colors.white,
                                    placeholderBuilder: (context) => CustomLoading(),
                                    height: 15.0,
                                  ),
                                  SizedBox(width:8,),
                                  Text('End shift'.tr(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.04
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding:EdgeInsets.symmetric(horizontal: 15),
                          child: Align(
                            alignment: EasyLocalization.of(context)!.locale == Locale('en') ? Alignment.centerLeft :Alignment.centerRight ,
                            child: Text('Need to take a break ?'.tr(),
                              style: TextStyle(
                                  color: blueColor,
                                  fontSize: screenWidth*0.04
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CaptainDrawerCard(
                text: 'HomeHome'.tr(),
                icon: Image.asset(
                  "assets/images/newHome.png",

                  height: 50.0,
                ),
                navigation: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DriverDashboard(
                            resourcesData: widget.resourcesData,
                          )));
                },
              ),
            ),




            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CaptainDrawerCard(
                text: 'Trips Management'.tr(),
                icon: Image.asset(
                  "assets/images/odometer.png",
                  height: 50,
                ),
                navigation: (){

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TripsManagementScreen(
                            resourcesData: widget.resourcesData,
                          )));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CaptainDrawerCard(
                text: 'Fleet Management'.tr(),
                icon: Image.asset(
                  "assets/images/car.png",
                  height: 50,
                ),
                navigation: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FleetManagementOptionsScreen(
                            resourcesData: widget.resourcesData,
                          )));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CaptainDrawerCard(
                text: 'Violations'.tr(),
                icon: Image.asset(
                  "assets/images/violations-icon.png",
                  height: 50,
                ),
                navigation: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViolationsScreen(
                            resourcesData: widget.resourcesData,
                          )));
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: CaptainLogOutCard(
                text: 'Logout'.tr(),
                icon:Image.asset(
                  "assets/images/newExit.png",
                  height: 40,
                ),
                navigation: ()async{
                  authenticationBloc.add(LoggedOut());
                  await PushNotificationManager.firebaseMessaging.setAutoInitEnabled(false);
                  await PushNotificationManager.firebaseMessaging.deleteToken();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => ChooseLanguageScreen(),
                      ),
                          (route) => false,
                    );
                  });
                  // RestartWidget.restartApp(context);
                },
              ),
            ),
            SizedBox(height: 2.5,),
            EasyLocalization.of(context)!.currentLocale == Locale('en') ?

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                decoration: BoxDecoration(
                    color: greyColor,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: GestureDetector(
                    onTap: (){
                      setState(() {
                        EasyLocalization.of(context)!.setLocale(Locale('ar'));
                        Constants.currentLocale = 'ar';
                        userRepository.persistLocale(locale: 'ar');
                        Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (BuildContext context) => ResourcesScreen()),
                              (route) => false,);
                        // RestartWidget.restartApp(context);
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/newLanguage.png",
                          height: 40,
                        ),
                        Expanded(
                          child: Center(
                            child: Text('العربية' ,
                              style: TextStyle(
                                  fontFamily: 'Tajawal', fontSize: 18
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ) :
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                decoration: BoxDecoration(
                    color: greyColor,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: GestureDetector(
                    onTap: (){
                      setState(() {
                        EasyLocalization.of(context)!.setLocale(Locale('en'));
                        userRepository.persistLocale(locale: 'en');
                        Constants.currentLocale = 'en';
                        Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (BuildContext context) => ResourcesScreen()),
                              (route) => false,);
                        // RestartWidget.restartApp(context);
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/newLanguage.png",
                          height: 40,
                        ),
                        Expanded(
                          child: Center(
                            child: Text('English',
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 17
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ver :'.tr()),
                    SizedBox(width: 5,),
                    Text(Constants.appVersion),
                  ],
                ),
              ),
            ),
            newVersion ?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    ComFunctions.launchStore();
                  },
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth*0.5,
                        child: AutoSizeText('A new version with better services is released'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth*0.5,
                        child: AutoSizeText('Try it now!'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ) : Container()
          ],
        ),
      ),
    );
  }
}






class CaptainDrawerCard extends StatelessWidget {
  Color blueColor = Color(0xFF2f3a92);
  Color greyColor = Color(0xFFf4f4f4);
  Color redColor = Color(0xFFBE2C33);
  Widget? icon ;
  String? text ;
  Function? navigation ;
  CaptainDrawerCard({this.text,this.icon , this.navigation});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10 ,bottom: 10),
      child: GestureDetector(
        onTap: navigation as void Function()?,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: greyColor,
          ),
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon!,
                Expanded(
                  child: Center(
                    child: Text(text!,
                      style: TextStyle(color: Colors.black,fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class CaptainLogOutCard extends StatelessWidget {
  Color greyColor = Color(0xFFf4f4f4);
  Widget? icon ;
  String? text ;
  Function? navigation ;
  CaptainLogOutCard({this.text,this.icon , this.navigation});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10 ,bottom: 10),
      child: GestureDetector(
        onTap: navigation as void Function()?,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: greyColor
          ),

          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 5, right: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon!,
                Expanded(
                  child: Center(
                    child: Text(text!,
                      style: TextStyle(color: Constants.capRed,fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}