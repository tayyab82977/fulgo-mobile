import 'package:flutter/material.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/courier/fuelManagement.dart';
import 'package:Fulgox/ui/courier/car_services.dart';
import 'package:Fulgox/ui/custom%20widgets/drawerDriver.dart';

import '../custom widgets/CaptainAppBar.dart';
import '../custom widgets/drawerCaptain.dart';
import 'package:easy_localization/easy_localization.dart';
class FleetManagementOptionsScreen extends StatefulWidget {

  ResourcesData? resourcesData;

  FleetManagementOptionsScreen({this.resourcesData});

  @override
  _FleetManagementOptionsScreenState createState() => _FleetManagementOptionsScreenState();
}

class _FleetManagementOptionsScreenState extends State<FleetManagementOptionsScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Color blueColor = Color(0xFF2f3a92);
  Color greyColor = Color(0xFFf4f4f4);
  Color redColor = Color(0xFFBE2C33);
  @override
  Widget build(BuildContext context) {
    var mySize = MediaQuery.of(context).size;
    return Scaffold(
      key: _drawerKey,
      drawer:
      SavedData.profileDataModel.permission.toString() == "4" ?
      CaptainDrawer(
        resourcesData: widget.resourcesData,
      ) : DriverDrawer(
        resourcesData: widget.resourcesData,
      ),
      body: SafeArea(
        child: Stack(

          children: [
            Positioned.fill(child: Align(
                alignment: Alignment.topCenter,
                child: CaptainAppBar(drawerKey: _drawerKey,screenName: 'Fleet Management'.tr()))),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: mySize.height / 100 * 4,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FuelManagementScreen(resourcesData: SavedData.resourcesData))
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(38)),
                          color: Color(0xFFf4f4f4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15, top: 40, bottom: 40),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(38)),
                                  color: Color(0xFFf4f4f4),
                                ),
                                width: mySize.width / 100 * 20,
                                margin: EdgeInsets.all(10),
                                child: Image.asset('assets/images/gas-pump.png',height: mySize.width / 100 * 15,),
                              ),
                              Expanded(
                                child: Text('Fuel management'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),),
                    ),
                    SizedBox(height: 30,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CarServicesScreen(
                                      resourcesData: SavedData.resourcesData,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(38)),
                          color: Color(0xFFf4f4f4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15, top: 40, bottom: 40),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(38)),
                                  color: Color(0xFFf4f4f4),
                                ),
                                width: mySize.width / 100 * 20,
                                margin: EdgeInsets.all(10),
                                child: Image.asset('assets/images/car-maintenance.png', height: mySize.width / 100 * 15,),
                              ),
                              Expanded(
                                child: Text('Maintenance'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
