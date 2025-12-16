
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/custom%20widgets/drawerCaptain.dart';
// import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/custom%20widgets/drawerDriver.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';

import '../custom widgets/CaptainAppBar.dart';



class CaptainProfile extends StatefulWidget {
  ResourcesData? resourcesData ;
  ProfileDataModel? dashboardDataModelNew ;

  CaptainProfile({this.resourcesData , this.dashboardDataModelNew});
  @override
  _CaptainProfileState createState() => _CaptainProfileState();
}



class _CaptainProfileState extends State<CaptainProfile> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  double? screenWidth , screenHeight ;

  UserRepository userRepository = UserRepository();
  String? token ;



  _launcPhone(String? phone) async {
    launch("tel://0$phone") ;
  }


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    screenWidth = size.width;
    screenHeight = size.height;
    return SafeArea(
      child: Scaffold(
        key: _drawerKey,
        drawer:
        SavedData.profileDataModel.permission.toString() == "4" ?
        CaptainDrawer(
          resourcesData: widget.resourcesData,
        ) : DriverDrawer(
          resourcesData: widget.resourcesData,
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white])
          ),
          child: Column(
            children: [
              CaptainAppBar(
                drawerKey:_drawerKey, screenName: 'My Profile'.tr(),
              ),
              SizedBox(height: 20,),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: screenWidth,
                      // height: 200,
                      decoration:BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft:Radius.circular(25) ),
                          color: Colors.white
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Constants.greyColor,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(25),topLeft:Radius.circular(25)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset('assets/images/newProfile.png', height: 40,),
                                          ),

                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 30),
                                              // width:screenWidth!*0.5,
                                              child: Center(
                                                child: AutoSizeText('${widget.dashboardDataModelNew!.name}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700, fontSize: 20

                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                                          // Image.asset('assets/images/supervisor.png', height: 40,),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Supervisor'.tr(), style: TextStyle(fontSize: 16),),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Container(
                                          width: screenWidth,
                                          height: 50,
                                          decoration:BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              color: Colors.white
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,

                                              children: [

                                                Text(widget.dashboardDataModelNew!.supervisorName ?? '' , style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 30,),



                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [
                                      Row(
                                        children: [
                                          Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                                          // Image.asset('assets/images/supervisor_phone.png',height: 40,),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Supervisor phone'.tr(), style: TextStyle(fontSize: 16),),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Container(
                                          decoration:BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              color: Colors.white
                                          ),
                                          width: screenWidth,
                                          height: 50,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(widget.dashboardDataModelNew!.supervisorPhone ?? '' ,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.blueAccent,
                                                      decoration: TextDecoration.underline,
                                                    fontSize: 16

                                                  ),),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                  children: [
                                                    IconButton(
                                                      onPressed: (){
                                                        _launcPhone(widget.dashboardDataModelNew!.supervisorPhone);
                                                      },
                                                      icon: Icon(Icons.phone, color: Constants.redColor,),
                                                    ),
                                                    IconButton(
                                                      onPressed: (){
                                                        ComFunctions.launcWhatsapp(widget.dashboardDataModelNew!.supervisorPhone);
                                                        // _launcWhatsapp(widget.dashboardDataModelNew.supervisorPhone);
                                                      },
                                                      icon: Icon(MdiIcons.whatsapp, color: Colors.green,),
                                                    ),

                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),




                                    ],
                                  ),
                                ],
                              ),
                            ) ,
                          ) ,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
 }

