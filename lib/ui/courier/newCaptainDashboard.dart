import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:version/version.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/dashboard_bloc.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/courier/bulkPickupScreen.dart';
import 'package:xturbox/ui/courier/captainDashboard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import '../custom widgets/CaptainAppBar.dart';
import '../custom widgets/drawerCaptain.dart';
import 'deliveryOptionsScreen.dart';
import 'odo_meter.dart';

class GDPData {
  GDPData(this.continent, this.gdp);
  final String continent;
  final int gdp;
}

class ChartApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class NewCaptainDashboard extends StatefulWidget  {
  ResourcesData? resourcesData ;
  NewCaptainDashboard({this.resourcesData});

  @override
  _NewCaptainDashboardState createState() => _NewCaptainDashboardState();
}

class _NewCaptainDashboardState extends State<NewCaptainDashboard> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  Color blueColor = Color(0xFF2f3a92);
  Color greyColor = Color(0xFFf4f4f4);
  Color redColor = Color(0xFFBE2C33);
  late List<GDPData> _chartData;
  bool newVersion = false;
  late Version latestVersion;
  late Version savedVersion;
  UserRepository userRepository = UserRepository();

  versionCheck() {
    latestVersion = Version.parse(widget.resourcesData?.appVersion ?? "1.3.3");
    savedVersion = Version.parse(Constants.appVersion );

    if (latestVersion > savedVersion) {
      newVersion = true;
    } else {
      newVersion = false;
    }
  }

  Future<bool> _onBackPressed()async {
    return false ;
  }
  _showDialog() async {
    await Future.delayed(Duration(milliseconds: 200));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: _onBackPressed,
            child: AlertDialog(
              backgroundColor: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              title: Text('New update available'.tr()),
              content: Text(
                'A new version with better services is released'.tr(),
                maxLines: 2,
              ),
              actions: [
                TextButton(
                  child: Text('Try it now!'.tr()),
                  onPressed: () async {
                    ComFunctions.launchStore();
                    await userRepository.persistSavedVersion(
                        savedVersion:
                        widget.resourcesData?.appVersion.toString()?? "4.4.4") ;
                    Constants.savedVersion = widget.resourcesData?.appVersion;
                    // Navigator.pop(context);
                  },
                ),
                // TextButton(
                //   child: Text(
                //     'Later'.tr(),
                //     style: TextStyle(color: Colors.red),
                //   ),
                //   onPressed: () async {
                //     await userRepository.persistSavedVersion(
                //         savedVersion:
                //             widget.resourcesData!.appVersion.toString());
                //     Constants.savedVersion = widget.resourcesData!.appVersion;
                //     Navigator.pop(context);
                //   },
                // ),
              ],
            ),
          );
        });
  }
  @override
  void initState() {
    _chartData = getChartData();
    if(SavedData.profileDataModel.meter == null){
      ComFunctions.showMeterDialog(context);

    }
    try{
      versionCheck();
      if (newVersion) {
        _showDialog();
      }

    }catch(e){}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mySize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        key: _drawerKey,
        drawer: CaptainDrawer(
          resourcesData: widget.resourcesData,
        ),
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CaptainAppBar(drawerKey: _drawerKey, screenName: '',),

            SizedBox(height: mySize.height / 100 * 4,),
            Container(
                padding: EdgeInsets.only(right: mySize.width / 100 * 4, left: mySize.width / 100 * 4),
                child: Text('Select Move Type'.tr(),
                    style: TextStyle(color: Colors.black, fontSize: 20,),textAlign: TextAlign.left)),
            SizedBox(height: mySize.height /100*2,),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mySize.width / 100 * 3.5),
                child: ListView(
                  children: [
                    DashboardCard(text: "Pickup".tr(), dIcon: 'assets/images/dashboardPickup.png',navigationFun: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CaptainDashboard(resourcesData: SavedData.resourcesData))
                      );
                    }, description: 'Fresh shipments from the client for reservation & pickup'.tr(),),
                    DashboardCard(text: "Delivery".tr(),dIcon: 'assets/images/dashboardDelivery.png',
                    navigationFun: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DeliveryOptionsScreen(resourcesData: SavedData.resourcesData))
                      );
                    }, description: 'Collecting dispatched shipments from warehouse & delivering to customers'.tr()),
                    DashboardCard(text: "Return".tr(),dIcon: 'assets/images/dashboardReturn.png',
                    navigationFun: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BulkPickUpScreen(resourcesData: SavedData.resourcesData,returnToClient: true,))
                      );
                    }, description: 'Cancelled shipments from warehouse & return to the clients back'.tr(),),
                  ],
                ),
              ),
            ),
            SizedBox(height: mySize.height / 100 * 1,),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: mySize.width / 100 * 7, left: mySize.width / 100 * 7),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          color: greyColor,
                          // color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              // color: Color.fromRGBO(120, 135, 198, .3),
                              color: Color(0xFFdbdbdb),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            )
                          ]),
                      child: Row(
                        children: [
                          Expanded(child: ChartApp()),

                        ],
                      )
                  ),
                )),
            SizedBox(height: mySize.height / 100 * 2,)
          ],
        ),
      ),
    );
  }
  List<GDPData> getChartData() {
    final List<GDPData> chartData = [
      GDPData('Pickup', 100),
      GDPData('Dispatched', 50),
    ];
    return chartData;
  }
}
class DashboardCard extends StatelessWidget {

  String text ;
  String dIcon;
  String description;
  VoidCallback navigationFun ;
  DashboardCard({required this.text, required this.dIcon , required this.navigationFun, required this.description});
  Color blueColor = Color(0xFF2f3a92);
  Color redColor = Color(0xFFbe2633);
  Color greyColor = Color(0xFFf4f4f4);
  @override
  Widget build(BuildContext context) {
    var mySize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: mySize.height / 100 * 15,
            width: mySize.width /100* 33,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(38)
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 5,
                  left: 5,
                  child: GestureDetector(
                    onTap:navigationFun,
                    child: Container(
                      height: mySize.height / 100 * 13,
                      width: mySize.width /100* 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          color: greyColor,
                          // color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              // color: Color.fromRGBO(120, 135, 198, .3),
                              color: Color(0xFFdbdbdb),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            )
                          ]),
                      child: Center(
                        child: Image.asset(dIcon, height: mySize.height / 100 * 11,),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(120, 135, 198, .3),
                              // color: Color(0xFFdbdbdb),
                              blurRadius: 5,
                              offset: Offset(0, 5),
                            )
                          ],
                          color: blueColor,
                          borderRadius: BorderRadius.circular(14)
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
        SizedBox(width: 10,),
        Expanded(
          // padding: EdgeInsets.all(10),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(25),
          //   // color: greyColor,
          //
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                style: TextStyle( fontSize: 20,),
                textAlign: EasyLocalization.of(context)?.currentLocale == Locale("en") ? TextAlign.left : TextAlign.right,),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 1,
                  // maxWidth: 200,
                  minHeight: 30.0,
                  maxHeight: 300,
                ),
                child: Container(
                  // color: Color(0xfff7f7f7),
                  color: Colors.white,
                  child: AutoSizeText(description,
                    maxLines: 3,
                    maxFontSize: 12,
                    minFontSize: 10,
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                    textAlign:  EasyLocalization.of(context)?.currentLocale == Locale("en") ? TextAlign.left : TextAlign.right,),
                ),
              )
              //AutoSizeText( widget.screenName,
              //                         maxLines: 1,
              //                         maxFontSize: 22,
              //                         minFontSize: 15,
              //                         textAlign: TextAlign.center,
            ],
          ),
        ),
      ],
    );
  }
}

