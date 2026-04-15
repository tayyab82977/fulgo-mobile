import 'dart:convert';
import 'package:version/version.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/invoicesScreen.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/tickets_add.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/tickets_screen.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/push_nofitications.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/drawer_client_controller.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/addressScreen.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/bankScreen.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/clientPayments.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/shipmentTracking.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/custom%20widgets/NetworkErrorView.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/Client/editProfile.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

import '../Client/MyOrders.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import '../common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import '../common/dashboard.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'custom_loading.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

class ClientDrawerWidget extends StatefulWidget {
  double? width;

  double? height;

  ResourcesData? resourcesData;

  ClientDrawerWidget({this.width, this.resourcesData, this.height});

  @override
  _ClientDrawerWidgetState createState() => _ClientDrawerWidgetState();
}

class _ClientDrawerWidgetState extends State<ClientDrawerWidget> {
  UserRepository userRepository = UserRepository();
  final AuthController _authController = Get.find<AuthController>();
  final DrawerClientController _drawerClientController = Get.put(DrawerClientController());
  ProfileDataModel dashboardDataModel = ProfileDataModel();
  Version currentVersion = Version.parse(Constants.appVersion);
  late Version latestVersion;

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
        dashboardDataModel = userData;
        try {
          showNoteBank = dashboardDataModel.bankHolder == null ||
                  dashboardDataModel.bankHolder == ''
              ? true
              : false;
          showNoteAddress =
              (dashboardDataModel.addresses?.length ?? 0) > 0 ? false : true;
        } catch (e) {}
      });
    }
  }

  double width = 0, height = 0;
  String? appVersion;
  bool? showNoteAddress;
  bool? showNoteBank;
  bool newVersion = false;

  versionCheck() {
    latestVersion = Version.parse(widget.resourcesData?.appVersion ?? "3.3.3");

    if (latestVersion > currentVersion) {
      newVersion = true;
    } else {
      newVersion = false;
    }
  }

  final _reasonController = TextEditingController();

  @override
  void initState() {
    getUserData();
    try {
      versionCheck();
    } catch (e) {}
    appVersion = Constants.appVersion;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    List<Widget> drawerItemsList = [
      DrawerCard(
        keyValue: ValueKey('home'),
        icon: SvgPicture.asset(
          "assets/images/home.svg",
          color: Colors.black87,
          placeholderBuilder: (context) => CustomLoading(),
          height: 20.0,
        ),
        onTapped: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (BuildContext context) => DashboardScreenBlocs(
          //       resourcesData: widget.resourcesData,
          //     ),
          //   ),
          //       (route) => false,
          // );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                        resourcesData: widget.resourcesData,
                      )));
        },
        text: 'HomeHome'.tr(),
        color: Color(0xffF1F1F1),
        showNote: false,
      ),
      // DrawerCard(
      //   keyValue: ValueKey('profile'),
      //
      //   icon:SvgPicture.asset(
      //     "assets/images/profile.svg",
      //     placeholderBuilder: (context) =>
      //         CustomLoading(),
      //     height: 20.0,
      //
      //   ),
      //   onTapped: () {
      //     // Navigator.pushAndRemoveUntil(
      //     //   context,
      //     //   MaterialPageRoute(
      //     //     builder: (BuildContext context) => EditProfile(
      //     //       resourcesData: widget.resourcesData,
      //     //       dashboardDataModel: dashboardDataModel,
      //     //     )
      //     //   ),
      //     //       (route) => false,
      //     // );
      //
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => EditProfile(
      //                   resourcesData: widget.resourcesData,
      //               dashboardDataModel: dashboardDataModel,
      //                 )));
      //   },
      //   text: 'My Account'.tr(),
      //   color: Color(0xffF1F1F1),
      //   showNote: false,
      // ),
      DrawerCard(
        keyValue: ValueKey('payments'),
        icon: SvgPicture.asset(
          "assets/images/wallet.svg",
          placeholderBuilder: (context) => CustomLoading(),
          height: 20.0,
        ),
        onTapped: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => ClientPaymentsScreen(
          //         resourcesData: widget.resourcesData,
          //         dashboardDataModel: dashboardDataModel,
          //       )
          //   ),
          //       (route) => false,
          // );

          //
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientPaymentsScreen(
                        resourcesData: widget.resourcesData,
                      )));
        },
        text: 'My Payments'.tr(),
        color: Color(0xffF1F1F1),
        showNote: false,
      ),
      DrawerCard(
        keyValue: ValueKey('myOrders'),
        icon: SvgPicture.asset(
          "assets/images/myShipmetns.svg",
          placeholderBuilder: (context) => CustomLoading(),
          height: 22.0,
        ),
        onTapped: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => MyOrdersScreen(
          //         dashboardDataModel: dashboardDataModel,
          //         resourcesData: widget.resourcesData,
          //       )
          //   ),
          //       (route) => false,
          // );
          //
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyOrdersScreen(
                        dashboardDataModel: dashboardDataModel,
                        resourcesData: widget.resourcesData,
                      )));
        },
        text: 'My Shipments'.tr(),
        color: Color(0xffF1F1F1),
        showNote: false,
      ),
      DrawerCard(
        keyValue: ValueKey('myAddress'),
        icon: SvgPicture.asset(
          "assets/images/myAddresses.svg",
          placeholderBuilder: (context) => CustomLoading(),
          height: 20.0,
        ),
        onTapped: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => AddressScreen(
          //         resourcesData: widget.resourcesData,
          //       )
          //   ),
          //       (route) => false,
          // );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddressScreen(
                        resourcesData: widget.resourcesData,
                      )));
        },
        text: 'My Addresses'.tr(),
        color: Color(0xffF1F1F1),
        showNote: showNoteAddress ?? false,
      ),
      DrawerCard(
        keyValue: ValueKey('myBank'),
        icon: SvgPicture.asset(
          "assets/images/myBank.svg",
          placeholderBuilder: (context) => CustomLoading(),
          height: 20.0,
        ),
        onTapped: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => BankScreen(
          //         resourcesData: widget.resourcesData,
          //         dashboardDataModelNew: dashboardDataModel,
          //       )
          //   ),
          //       (route) => false,
          // );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BankScreen(
                        resourcesData: widget.resourcesData,
                        dashboardDataModelNew: dashboardDataModel,
                      )));
        },
        text: 'Bank Account'.tr(),
        color: Color(0xffF1F1F1),
        showNote: showNoteBank ?? false,
      ),
      DrawerCard(
        icon: SvgPicture.asset(
          "assets/images/invoice.svg",
          color: Colors.black87,
          placeholderBuilder: (context) => CustomLoading(),
          height: 20.0,
        ),
        onTapped: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => BankScreen(
          //         resourcesData: widget.resourcesData,
          //         dashboardDataModelNew: dashboardDataModel,
          //       )
          //   ),
          //       (route) => false,
          // );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TicketsScreen(
                        resourcesData: widget.resourcesData!,
                      )));
        },
        text: 'My Invoices'.tr(),
        color: Color(0xffF1F1F1),
        showNote: false,
      ),
      DrawerCard(
        keyValue: ValueKey('route'),
        icon: SvgPicture.asset(
          "assets/images/route.svg",
          color: Colors.black54,
          placeholderBuilder: (context) => CustomLoading(),
          height: 20.0,
        ),
        onTapped: () {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //       builder: (BuildContext context) => BankScreen(
          //         resourcesData: widget.resourcesData,
          //         dashboardDataModelNew: dashboardDataModel,
          //       )
          //   ),
          //       (route) => false,
          // );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShipmentTracking(
                        resourcesData: widget.resourcesData,
                        dashboardDataModel: dashboardDataModel,
                      )));
        },
        text: 'Tracking'.tr(),
        color: Color(0xffF1F1F1),
        showNote: false,
      ),
      // DrawerCard(
      //   icon:Icon(Icons.send),
      //   onTapped: () {
      //     Navigator.push(context,
      //         MaterialPageRoute(builder: (context)=>IntroSliderScreen(
      //
      //         )));
      //   },
      //   text: 'Intro'.tr(),
      //   color: Color(0xffF1F1F1),
      //   showNote: false,
      // ),
      SizedBox(
        height: 10,
      ),
      GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState2) {
                    return AlertDialog(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Call customer support'.tr(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  ComFunctions.launcPhone2(Constants.csPhone);
                                },
                                icon: Icon(
                                  Icons.phone,
                                  size: width * 0.09,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  ComFunctions.launcWhatsapp(
                                      Constants.csWhatsApp);
                                },
                                icon: Icon(
                                  MdiIcons.whatsapp,
                                  size: width * 0.09,
                                  color: Colors.green,
                                ),
                              ),
                              // Text(Constants.csPhone,
                              //   style: TextStyle(
                              //       color: Colors.blueAccent,
                              //       decoration: TextDecoration.underline,
                              //     fontSize: 11
                              //   ),
                              // )
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     IconButton(
                          //       padding: EdgeInsets.all(0),
                          //       onPressed: (){
                          //         ComFunctions.launcWhatsapp(Constants.csWhatsApp);
                          //       },
                          //       icon: Icon(MdiIcons.whatsapp , size: width*0.06),
                          //     ),
                          //     Text(Constants.csWhatsApp,
                          //       style: TextStyle(
                          //           color: Colors.blueAccent,
                          //           decoration: TextDecoration.underline,
                          //         fontSize: 11
                          //       ),
                          //     )
                          //   ],
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Send a communication request'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      content: TextFormField(
                        decoration: kTextFieldDecoration.copyWith(
                            hintText: 'request reason'.tr()),
                        maxLines: 4,
                        controller: _reasonController,
                      ),
                      actions: [
                        CustomButton(
                          child: Text('Send'.tr()),
                          onPressed: () {
                            _drawerClientController.callCstSupport(_reasonController.text);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Customer support'.tr(),
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              MdiIcons.phoneDial,
              size: 15,
            ),
          ],
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ver :'.tr()),
              SizedBox(
                width: 5,
              ),
              Text(Constants.appVersion),
            ],
          ),
        ),
      ),
      // IconButton(icon: Icon(Icons.delete_sweep_outlined),
      // onPressed: ()async{
      //   String token = await userRepository.getAuthToken();
      // http.Response response = await  http.delete(EventsAPIs.url+'tokens',
      //   headers: {
      //     "Content-Type": "application/json",
      //     HttpHeaders.authorizationHeader : '$token'
      //     ,"compatibility":EventsAPIs.compatibility
      //   }
      //   );
      //   print(response.statusCode);
      // },
      // ),
      // IconButton(
      //     key: const ValueKey('popMenu'),
      //     icon: Icon(Icons.ac_unit , color: Colors.white,), onPressed: (){
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => ConfirmationScreen(
      //             resourcesData: widget.resourcesData,
      //           )));
      // }),
      // Constants.appVersion  != widget.resourcesData.appVersion ?
      newVersion
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    ComFunctions.launchStore();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: width * 0.5,
                        child: AutoSizeText(
                          'A new version with better services is released'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      Container(
                        width: width * 0.5,
                        child: AutoSizeText(
                          'Try it now!'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container()
    ];

    return Obx(() {
      if (_drawerClientController.success.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _drawerClientController.success.value = false;
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState2) {
                      return AlertDialog(
                        title: Column(
                          children: [
                            Text(
                              'Request sent successfully!'.tr(),
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        actions: [
                          CustomButton(
                            child: Text('OK'.tr()),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                });
          });
      }

      if (_drawerClientController.errorMessage.value != '') {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
              String error = _drawerClientController.errorMessage.value;
              _drawerClientController.errorMessage.value = '';
              ComFunctions.showToast(text: error.tr());
          });
      }

      return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white.withOpacity(0.8),
        ),
        child: Drawer(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 5, right: 5, top: height * 0.1),
                            child: GestureDetector(
                              key: const ValueKey("profile"),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile(
                                              dashboardDataModel:
                                                  dashboardDataModel,
                                              resourcesData:
                                                  widget.resourcesData,
                                            )));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/user.svg",
                                    color: Colors.black54,
                                    placeholderBuilder: (context) =>
                                        CustomLoading(),
                                    height: 22.0,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Flexible(
                                    child: AutoSizeText(
                                      SavedData.profileDataModel!.name ?? '',
                                      maxLines: 2,
                                      wrapWords: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 19,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SavedData.profileDataModel!.member_pin != null
                              ? EasyLocalization.of(context)!.currentLocale ==
                                      Locale("en")
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "PIN : ",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  Colors.grey.withOpacity(0.8)),
                                        ),
                                        Text(
                                          "${SavedData.profileDataModel!.member_pin}",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  Colors.grey.withOpacity(0.8)),
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${SavedData.profileDataModel!.member_pin}",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey
                                                    .withOpacity(0.8)),
                                          ),
                                          Text(
                                            " : PIN",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey
                                                    .withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                    )
                              : Container(),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                print("logout");

                                try {
                                  await PushNotificationManager
                                      .firebaseMessaging
                                      .setAutoInitEnabled(false);
                                  await PushNotificationManager
                                      .firebaseMessaging
                                      .deleteToken();
                                } catch (e) {
                                  print(e);
                                }
                                print("logout");
                                _authController.logout();
                              },
                              icon: Icon(
                                Icons.logout,
                                size: 18,
                                color: Colors.red,
                              ),
                              label: Text('Log Out'.tr(),
                                  style: TextStyle(
                                    color: Colors.red,
                                  )),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: drawerItemsList.length,
                              itemBuilder: (context, i) {
                                return drawerItemsList[i];
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_drawerClientController.isLoading.value)
                 Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: Center(child: CustomLoading()),
                    ),
                 )
            ],
          ),
        ),
      );
    });
  }
}

class DrawerCard extends StatefulWidget {
  Function? onTapped;
  Widget? icon;
  bool? showNote;
  Color? color;
  Key? keyValue;
  String? text;

  DrawerCard(
      {this.icon,
      this.onTapped,
      this.color,
      this.text,
      this.showNote,
      this.keyValue});

  @override
  _DrawerCardState createState() => _DrawerCardState();
}

class _DrawerCardState extends State<DrawerCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
      child: InkWell(
        key: widget.keyValue,
        onTap: widget.onTapped as void Function()?,
        child: Container(
          width: 110,
          height: 40,
          decoration: BoxDecoration(
              color: widget.color, borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        widget.icon!,
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.text!,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ]
                      // () as List<Widget>,
                      ),
                ),
              ),
              widget.showNote ?? false
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
