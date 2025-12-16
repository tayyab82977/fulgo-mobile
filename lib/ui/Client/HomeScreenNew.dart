import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:version/version.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/getOrders_bloc.dart';
import 'package:xturbox/blocs/events/gerOrders_events.dart';
import 'package:xturbox/blocs/states/getOrders_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/Client/addOrder.dart';
import 'package:xturbox/ui/Client/addOrderB2c.dart';
import 'package:xturbox/ui/Client/clientPayments.dart';
import 'package:xturbox/ui/Client/ofd_orders_dialog.dart';
import 'package:xturbox/ui/Client/shipmentTracking.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/downloader.dart';
import 'package:xturbox/utilities/push_nofitications.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/home_button.dart';

class NewHomeScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  ProfileDataModel? dashboardDataModel;
  NewHomeScreen({this.resourcesData, this.dashboardDataModel});
  @override
  _NewHomeScreenState createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  PushNotificationManager _pushNotificationManager = PushNotificationManager();

  Version currentVersion = Version.parse(Constants.appVersion);
  late Version latestVersion;
  late Version savedVersion;
  bool newVersion = false;
  UserRepository userRepository = UserRepository();

  List<String> imageList = [
    "https://portal.xturbox.com/Tq8zYcZfaWVvMn2dseecigHqwQqwerT3/xturbo3.png",
    "https://portal.xturbox.com/Tq8zYcZfaWVvMn2dseecigHqwQqwerT1/xturbo1.png",
    "https://portal.xturbox.com/Tq8zYcZfaWVvMn2dseecigHqwQqwerT2/xturbo2.png",
  ];
  List<String> cachesKey = [
  ValueKey(new Random().nextInt(100)).toString(),
  ValueKey(new Random().nextInt(100)).toString(),
  ValueKey(new Random().nextInt(100)).toString(),

  ];

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

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          final Uri? deepLink = dynamicLink?.link;

          if (deepLink != null) {
            if (deepLink.path.contains("/tracking")) {
              String? id = deepLink.queryParameters['tracking_number'];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShipmentTracking(
                        resourcesData: widget.resourcesData,
                        dashboardDataModel: widget.dashboardDataModel,
                        trackingId: id,
                      )));
            }
            if (deepLink.path.contains("/newShipment")) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddOrder(
                        dashboardDataModelNew: widget.dashboardDataModel,
                        resourcesData: widget.resourcesData,
                        packagingType: "noPackaging",
                      )));
            }
            if (deepLink.path.contains("/myPayments")) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClientPaymentsScreen(
                        resourcesData: widget.resourcesData,
                      )));
            }
          }
        }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });

    final PendingDynamicLinkData? data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      if (deepLink.path.contains("/tracking")) {
        String? id = deepLink.queryParameters['tracking_number'];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShipmentTracking(
                  resourcesData: widget.resourcesData,
                  dashboardDataModel: widget.dashboardDataModel,
                  trackingId: id,
                )));
      }
      if (deepLink.path.contains("/newShipment")) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddOrder(
                  dashboardDataModelNew: widget.dashboardDataModel,
                  resourcesData: widget.resourcesData,
                )));
      }
      if (deepLink.path.contains("/myPayments")) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClientPaymentsScreen(
                  resourcesData: widget.resourcesData,
                )));
      }
    }
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

  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  double screenHeight = 0 ;
  double screenWidth  = 0 ;

  @override
  void initState() {
    try{
      versionCheck();
      FlutterDownloader.registerCallback(Downloader.downloadCallback);
      if (newVersion) {
        _showDialog();
      }

    }catch(e){}

    this.initDynamicLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.width;
    screenWidth = size.width;
    return Scaffold(
      backgroundColor: Constants.blueColor,
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: LayoutBuilder(builder: (context , constrains){
              print(constrains.maxWidth);
              print(constrains.maxHeight);
              if(constrains.maxHeight > 572){
                return _bigScreen();
              }else {
                return _smallScreen();
              }
            }),
          ),
          Expanded(child: HomeButton(isHome: true,)),
        ],
      ),
    );
  }

  _deliveryBtnElement(String text , String image , VoidCallback function){
    return Expanded(
      child: GestureDetector(
        onTap: function,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
                color: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(image , height: screenHeight*0.2,fit: BoxFit.fitWidth,),
                  SizedBox(height: screenHeight*0.01,),
                  Container(
                    width: screenWidth*0.2,
                    child: AutoSizeText(text ,
                      maxFontSize: 14,
                      minFontSize: 11,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black , fontSize: 11 ) ,maxLines: 1,),
                  )


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  _smallScreen(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //SizedBox(height:screenHeight*0.1 ,),
        Hero(
            tag: "headerImage",
            child: Image.asset("assets/images/WELCOME SCREEN TOP.png",fit: BoxFit.fill, height: screenHeight*0.5,width: screenWidth, )) ,
        // Spacer(flex: 1,),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: screenHeight*0.005,),
                Text("Our Services".tr() , style: TextStyle(color: Colors.white , fontSize: 15 , fontWeight: FontWeight.bold),),
                SizedBox(height: screenHeight*0.01,),
                Container(
                  // height: screenHeight*0.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _deliveryBtnElement("PackageDelivery".tr(), "assets/images/CARTON.png" ,
                              (){
                            if(SavedData.profileDataModel.permission == "1"){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrder(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew:  SavedData.profileDataModel,
                                        packagingType: "noPackaging",
                                        fromHomeScreen: true,
                                      )));
                            }else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrderB2C(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "noPackaging",
                                        fromHomeScreen: true,
                                      )));
                            }
                          }
                      ),
                      _deliveryBtnElement("Honey and oil oliveTransport".tr(), "assets/images/OIL.png" ,
                              (){
                            if(SavedData.profileDataModel.permission == "1"){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrder(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "liquid",
                                        fromHomeScreen: true,
                                      )));
                            }else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrderB2C(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "liquid",
                                        fromHomeScreen: true,

                                      )));
                            }
                          }
                      ),
                      _deliveryBtnElement("RefrigeratedTransport".tr(), "assets/images/refrigerated.png",
                              (){
                            if(SavedData.profileDataModel.permission == "1"){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrder(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "frozen",
                                        fromHomeScreen: true,

                                      )));
                            }else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrderB2C(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "frozen",
                                        fromHomeScreen: true,

                                      )));
                            }
                          }
                      )
                    ],
                  ),
                ),
                // SizedBox(height: screenHeight*0.1,),
                Text("Ads Offers".tr() , style: TextStyle(color: Colors.white , fontSize: 20 , fontWeight: FontWeight.bold),),
                SizedBox(height: screenHeight*0.01,),
                Expanded(
                  child: Center(
                    child: Swiper(
                      itemCount: imageList.length,
                      autoplay: true,
                      itemBuilder: (context , i ){
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CachedNetworkImage(
                            cacheKey: cachesKey[i],
                            key: ValueKey(imageList[i]),
                            // key: ValueKey(new Random().nextInt(100)),
                            imageUrl: imageList[i],
                            width: screenWidth,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                Center(child: CustomLoading()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        );
                      },

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
  _bigScreen(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height:screenHeight*0.1 ,),
        Stack(
          children: [
            Hero(
                tag: "headerImage",
                child: Image.asset("assets/images/WELCOME SCREEN TOP.png",fit: BoxFit.fill, height: screenHeight*0.6,width: screenWidth, )),
            Positioned(
                left: screenWidth *0.05,
                top: screenHeight *0.1,
                child: Image.asset('assets/images/XTURBO WHITE N RED.png',
                  width: 120,
                  colorBlendMode: BlendMode.darken,))
          ],
        ) ,
        // Spacer(flex: 1,),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: screenHeight*0.03,),
                Text("Our Services".tr() , style: TextStyle(color: Colors.white , fontSize: 15 , fontWeight: FontWeight.bold),),
                // SizedBox(height: screenHeight*0.01,),
                Container(
                  // height: screenHeight*0.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _deliveryBtnElement("PackageDelivery".tr(), "assets/images/CARTON.png" ,
                              (){
                            if(SavedData.profileDataModel.permission == "1"){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrder(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "noPackaging",
                                        fromHomeScreen: true,
                                      )));
                            }else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrderB2C(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "noPackaging",
                                        fromHomeScreen: true,
                                      )));
                            }
                          }
                      ),
                      _deliveryBtnElement("Honey and oil oliveTransport".tr(), "assets/images/OIL.png" ,
                              (){
                            if(SavedData.profileDataModel.permission == "1"){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrder(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "liquid",
                                        fromHomeScreen: true,

                                      )));
                            }else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrderB2C(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "liquid",
                                        fromHomeScreen: true,

                                      )));
                            }
                          }
                      ),
                      _deliveryBtnElement("RefrigeratedTransport".tr(), "assets/images/refrigerated.png",
                              (){
                            if(SavedData.profileDataModel.permission == "1"){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrder(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "frozen",
                                        fromHomeScreen: true,
                                      )));
                            }else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddOrderB2C(
                                        resourcesData: SavedData.resourcesData,
                                        dashboardDataModelNew: SavedData.profileDataModel,
                                        packagingType: "frozen",
                                        fromHomeScreen: true,
                                      )));
                            }
                          }
                      )
                    ],
                  ),
                ),
                SizedBox(height: screenHeight*0.04,),
                Text("Special Offers".tr() , style: TextStyle(color: Colors.white , fontSize: 15 , fontWeight: FontWeight.bold),),
                Expanded(
                  child: Center(
                    child: Swiper(
                      itemCount: imageList.length,
                      autoplay: true,
                      itemBuilder: (context , i ){
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CachedNetworkImage(
                            cacheKey: cachesKey[i],
                            key: ValueKey(imageList[i]),
                            // key: ValueKey(new Random().nextInt(100)),
                            imageUrl: imageList[i],
                            width: screenWidth,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder: (context, url, downloadProgress) =>
                                Center(child: CustomLoading()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        );
                      },

                    ),
                  ),
                ),
                // Expanded(
                //   child: Center(
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(25),
                //       child: CachedNetworkImage(
                //         imageUrl: "https://portal.xturbox.com/Tq8zYcZfaWVvMn2dseecigHqwQqwerT/xturbo.png",
                //         // height: screenHeight*0.4,
                //         width: screenWidth,
                //         fit: BoxFit.fill,
                //         progressIndicatorBuilder: (context, url, downloadProgress) =>
                //             Center(child: CustomLoading()),
                //         errorWidget: (context, url, error) => Icon(Icons.error),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}
