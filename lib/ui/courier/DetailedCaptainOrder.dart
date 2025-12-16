import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter_launch/flutter_launch.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
// import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/packageCard.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';

import '../../main.dart';
import '../Client/MyOrders.dart';
import '../custom widgets/CaptainAppBar.dart';
import '../custom widgets/drawerCaptain.dart';
import '../common/dashboard.dart';

class DetailedCapOrder extends StatefulWidget {
  OrdersDataModelMix? ordersDataModel;
  ResourcesData? resourcesData;
  bool? showDetails;
  DetailedCapOrder(
      {this.ordersDataModel, this.resourcesData, this.showDetails});

  @override
  _DetailedCapOrderState createState() => _DetailedCapOrderState();
}

class _DetailedCapOrderState extends State<DetailedCapOrder> {
  String? pickUpCity;
  String? deliverCity;
  DateTime pickUpTime = DateTime.now();
  DateTime deliverTime = DateTime.now();
  String? packaging;
  String? pickUpZone;
  String? deliverZone;

  String dateDays = "";
  String dateMonth = "";
  String dateYear = "";
  String timeM = "";
  String dateNow = DateTime.now().toString();

  int timeH = 0;

  String AMPM = "AM";

  idToNames() {
    pickUpCity = IdToName.idToName(
        'city',
        widget.ordersDataModel?.pickupCityId ??
            widget.ordersDataModel?.t_pickupCity.toString() ??
            "");

    pickUpZone = IdToName.idToName(
        'zone', widget.ordersDataModel?.pickupNeighborhood.toString() ?? "");

    deliverCity = IdToName.idToName(
        'city',
        widget.ordersDataModel?.deliverCityId ??
            widget.ordersDataModel?.t_deliverCity.toString() ??
            "");

    deliverZone = IdToName.idToName(
        'zone', widget.ordersDataModel?.deliverNeighborhood.toString() ?? "");

    // pickUpTime = IdToName.idToName(
    //     'times', widget.ordersDataModel!.pickupTime.toString());
    // pickUpTime = ComFunctions.convertIntToDate(int.tryParse(widget.ordersDataModel!.pickupTime.toString()));

    if (widget.ordersDataModel!.pickupTime.toString().length > 1) {
      pickUpTime = DateTime.tryParse(
              widget.ordersDataModel?.pickupTime.toString() ?? "") ??
          DateTime.now();
    }
    if (widget.ordersDataModel?.deliverTime != null &&
        (widget.ordersDataModel?.deliverTime.toString().length ?? 0) > 1) {
      deliverTime = DateTime.tryParse(
              widget.ordersDataModel?.deliverTime.toString() ?? "") ??
          DateTime.now();
    }

    packaging = IdToName.idToName(
        'packaging', widget.ordersDataModel?.packaging.toString() ?? "");
  }

  gettingDate() {
    dateDays =
        widget.ordersDataModel?.stamp.toString().substring(8, 10) ??"";
    dateMonth =
        widget.ordersDataModel?.stamp.toString().substring(5, 7) ?? "";
    dateYear =
        widget.ordersDataModel?.stamp.toString().substring(0, 4) ?? "";
    timeM =
        widget.ordersDataModel?.stamp.toString().substring(14, 16) ?? "";
    timeH = int.parse(
        widget.ordersDataModel?.stamp.toString().substring(11, 13)??"");

    if (timeH > 12) {
      timeH = timeH - 12;
      AMPM = "PM".tr();
    } else if (timeH == 12) {
      AMPM = "PM".tr();
    } else if (timeH == 0) {
      timeH = timeH + 12;
      AMPM = "AM".tr();
    } else {
      AMPM = 'AM'.tr();
    }
  }

  @override
  void initState() {
    try {
      idToNames();
      gettingDate();
    } catch (e) {}

    super.initState();
  }

  AuthenticationBloc authenticationBloc = AuthenticationBloc();
  double? screenWidth, screenHeight;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return SafeArea(
      child: Scaffold(
        key: _drawerKey,
        drawer: CaptainDrawer(
          resourcesData: widget.resourcesData,
          width: screenWidth,
          height: screenHeight,
        ),
        body: Container(
          color: Color(0xffDFDAE8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CaptainAppBar(
                drawerKey: _drawerKey, screenName: 'Shipment Details',
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: EasyLocalization.of(context)!.locale ==
                                          Locale('en')
                                      ? ButtonTheme(
                                          minWidth: 78,
                                          height: 40,
                                          child: FlatButton(
                                            padding: EdgeInsets.all(0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              width: 78,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.black)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.arrow_back,
                                                    size: 15,
                                                  ),
                                                  Text('Back'.tr()),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : ButtonTheme(
                                          minWidth: 78,
                                          height: 40,
                                          child: FlatButton(
                                            padding: EdgeInsets.all(0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              width: 78,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.black)),
                                              child:
                                                  EasyLocalization.of(context)!
                                                              .locale ==
                                                          Locale('en')
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Icon(
                                                              Icons.arrow_back,
                                                              size: 15,
                                                            ),
                                                            Text('Back'.tr()),
                                                          ],
                                                        )
                                                      : Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text('Back'.tr()),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              size: 15,
                                                            ),
                                                          ],
                                                        ),
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Shipment details'.tr(),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      '#${widget.ordersDataModel?.id}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      Text(
                                        ' $dateDays/$dateMonth/$dateYear ',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '$timeH:$timeM',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            AMPM.tr(),
                                            style: TextStyle(fontSize: 9),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Color(0xffF9F9F9),
                                  // color: Colors.red,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffF1F1F1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              Text('Sender information'.tr()),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Name:'.tr(),
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth! * 0.03),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                  width: screenWidth! * 0.7,
                                                  child: AutoSizeText(
                                                    widget.ordersDataModel
                                                            ?.senderName ??
                                                        '',
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontSize: screenWidth! *
                                                            0.035),
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          widget.showDetails == null
                                              ? Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Account owner phone:'
                                                                  .tr(),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      screenWidth! *
                                                                          0.03),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                ComFunctions.launcPhone(widget
                                                                    .ordersDataModel
                                                                    ?.memberPhone);
                                                              },
                                                              child: Container(
                                                                  width:
                                                                      screenWidth! *
                                                                          0.2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    widget.ordersDataModel
                                                                            ?.memberPhone ??
                                                                        '',
                                                                    maxLines: 1,
                                                                    minFontSize:
                                                                        9,
                                                                    maxFontSize:
                                                                        11,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blueAccent,
                                                                        decoration:
                                                                            TextDecoration.underline),
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0.0),
                                                              width:
                                                                  screenWidth! *
                                                                      0.05,
                                                              height:
                                                                  screenHeight! *
                                                                      0.02,
                                                              child: IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                onPressed: () {
                                                                  ComFunctions.launcPhone(widget.ordersDataModel?.memberPhone);
                                                                },
                                                                icon: Icon(
                                                                  Icons.phone,
                                                                  size:
                                                                      screenWidth! *
                                                                          0.06,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 15,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0.0),
                                                              width:
                                                                  screenWidth! *
                                                                      0.05,
                                                              height:
                                                                  screenHeight! *
                                                                      0.02,
                                                              child: IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                onPressed: () {
                                                                  ComFunctions.launcWhatsapp(widget.ordersDataModel?.memberPhone);
                                                                },
                                                                icon: Icon(
                                                                    MdiIcons
                                                                        .whatsapp,
                                                                    size: screenWidth! *
                                                                        0.06),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Sender phone:'.tr(),
                                                    style: TextStyle(
                                                        fontSize: screenWidth! *
                                                            0.03),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      ComFunctions.launcPhone(
                                                          widget.ordersDataModel?.senderPhone);
                                                    },
                                                    child: Container(
                                                        width:
                                                            screenWidth! * 0.21,
                                                        child: AutoSizeText(
                                                          widget.ordersDataModel?.senderPhone ?? '',
                                                          maxLines: 1,
                                                          minFontSize: 9,
                                                          maxFontSize: 11,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    width: screenWidth! * 0.05,
                                                    height:
                                                        screenHeight! * 0.02,
                                                    child: IconButton(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      onPressed: () {
                                                        ComFunctions.launcPhone(
                                                            widget.ordersDataModel?.senderPhone);
                                                      },
                                                      icon: Icon(Icons.phone,
                                                          size: screenWidth! *
                                                              0.06),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Container(
                                                    width: screenWidth! * 0.05,
                                                    height:
                                                        screenHeight! * 0.02,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: IconButton(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      onPressed: () {
                                                        ComFunctions
                                                            .launcWhatsapp(widget.ordersDataModel?.senderPhone);
                                                      },
                                                      icon: Icon(
                                                          MdiIcons.whatsapp,
                                                          size: screenWidth! *
                                                              0.06),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'City:'.tr(),
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth! * 0.03),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                  width: screenWidth! * 0.4,
                                                  child: AutoSizeText(
                                                    widget.ordersDataModel?.pickupCityName ?? '',
                                                    maxLines: 2,
                                                    minFontSize: 9,
                                                    maxFontSize: 11,
                                                    style: TextStyle(),
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Neighborhood:'.tr(),
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth! * 0.03),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                  width: screenWidth! * 0.4,
                                                  child: AutoSizeText(
                                                    pickUpZone ?? '',
                                                    maxLines: 2,
                                                    minFontSize: 9,
                                                    maxFontSize: 11,
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Pickup Time:'.tr(),
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth! * 0.03),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              (widget.ordersDataModel?.pickupTime.toString().length?? 2) > 12
                                                  ? Row(
                                                      children: [
                                                        Text(pickUpTime.day
                                                                .toString() +
                                                            "-" +
                                                            pickUpTime.month
                                                                .toString() +
                                                            "-" +
                                                            pickUpTime.year
                                                                .toString()),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(pickUpTime.hour
                                                                .toString() +
                                                            ":" +
                                                            pickUpTime.minute
                                                                .toString()),
                                                      ],
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          widget.ordersDataModel?.pickupAddress != null &&
                                          widget.ordersDataModel?.pickupAddress != ''
                                              ? Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          'Pickup address:'
                                                              .tr(),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  screenWidth! *
                                                                      0.03),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Container(
                                                            width:
                                                                screenWidth! *
                                                                    0.6,
                                                            child: AutoSizeText(
                                                              widget.ordersDataModel?.pickupAddress ?? "",
                                                              maxLines: 3,
                                                              maxFontSize: 13,
                                                              minFontSize: 9,
                                                            )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                          widget.ordersDataModel?.pickupMap != null &&
                                                  widget.ordersDataModel?.pickupMap != ''
                                              ? FlatButton(
                                                  onPressed: () {
                                                    ComFunctions.launchURL(
                                                        widget.ordersDataModel?.pickupMap??""
                                                    );
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  padding: EdgeInsets.all(2),
                                                  child: Container(
                                                    width: screenWidth,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffCE5C6B),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Center(
                                                        child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Position on google maps'
                                                            .tr(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                screenWidth! *
                                                                    0.03),
                                                      ),
                                                    )),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Color(0xffF9F9F9),
                                  // color: Colors.red,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffF1F1F1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Receiver information'.tr(),
                                            // style: TextStyle(
                                            //     fontSize: screenWidth*0.03
                                            // ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Name:'.tr(),
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth! * 0.03),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                  width: screenWidth! * 0.7,
                                                  child: AutoSizeText(
                                                    widget.ordersDataModel?.receiverName ?? '',
                                                    maxLines: 2,
                                                    minFontSize: 9,
                                                    maxFontSize: 11,
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Receiver phone:'.tr(),
                                                    style: TextStyle(
                                                        fontSize: screenWidth! *
                                                            0.03),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      ComFunctions.launcPhone(
                                                          widget.ordersDataModel?.receiverPhone);
                                                    },
                                                    child: Container(
                                                        width:
                                                            screenWidth! * 0.2,
                                                        child: AutoSizeText(
                                                          widget.ordersDataModel?.receiverPhone ?? '',
                                                          maxLines: 1,
                                                          minFontSize: 9,
                                                          maxFontSize: 11,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    width: screenWidth! * 0.05,
                                                    height:
                                                        screenHeight! * 0.02,
                                                    child: IconButton(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      onPressed: () {
                                                        ComFunctions.launcPhone(
                                                            widget.ordersDataModel?.receiverPhone);
                                                      },
                                                      icon: Icon(Icons.phone,
                                                          size: screenWidth! *
                                                              0.06),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    width: screenWidth! * 0.05,
                                                    height:
                                                        screenHeight! * 0.02,
                                                    child: IconButton(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      onPressed: () {
                                                        ComFunctions
                                                            .launcWhatsapp(widget.ordersDataModel?.receiverPhone);
                                                      },
                                                      icon: Icon(
                                                          MdiIcons.whatsapp,
                                                          size: screenWidth! *
                                                              0.06),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'City:'.tr(),
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth! * 0.03),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                  width: screenWidth! * 0.4,
                                                  child: AutoSizeText(
                                                    widget.ordersDataModel?.deliverCityName ?? '',
                                                    maxLines: 2,
                                                    minFontSize: 9,
                                                    maxFontSize: 11,
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Neighborhood:'.tr(),
                                                style: TextStyle(
                                                    fontSize:
                                                        screenWidth! * 0.03),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                  width: screenWidth! * 0.4,
                                                  child: AutoSizeText(
                                                    deliverZone ?? '',
                                                    maxLines: 2,
                                                    minFontSize: 9,
                                                    maxFontSize: 11,
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          widget.ordersDataModel?.deliverTime !=
                                                      null &&
                                                  (widget.ordersDataModel?.deliverTime.toString().length?? 2) > 18
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      'Deliver Time'.tr(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth! *
                                                                  0.03),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(deliverTime.day
                                                            .toString() +
                                                        "-" +
                                                        deliverTime.month
                                                            .toString() +
                                                        "-" +
                                                        deliverTime.year
                                                            .toString()),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(deliverTime.hour
                                                            .toString() +
                                                        ":" +
                                                        deliverTime.minute
                                                            .toString()),
                                                  ],
                                                )
                                              : Container(),
                                          widget.ordersDataModel?.deliverAddress !=
                                                      null &&
                                                  widget.ordersDataModel?.deliverAddress != ''
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      'Deliver address:'.tr(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth! *
                                                                  0.03),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Container(
                                                        width:
                                                            screenWidth! * 0.5,
                                                        child: AutoSizeText(
                                                          widget.ordersDataModel?.deliverAddress ?? '',
                                                          maxLines: 3,
                                                          maxFontSize: 13,
                                                          minFontSize: 9,
                                                        )),
                                                  ],
                                                )
                                              : Container(),
                                          widget.ordersDataModel?.deliverMap !=
                                                      null &&
                                                  widget.ordersDataModel?.deliverMap != ''
                                              ? FlatButton(
                                                  onPressed: () {
                                                    ComFunctions.launchURL(
                                                        widget.ordersDataModel?.deliverMap??"");
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                                  padding: EdgeInsets.all(2),
                                                  child: Container(
                                                    width: screenWidth,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffCE5C6B),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Center(
                                                        child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Position on google maps'
                                                            .tr(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                screenWidth! *
                                                                    0.03),
                                                      ),
                                                    )),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Container(
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Color(0xffFEF1E7),
                                  // color: Colors.red,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/images/empty-white-box.svg",
                                                    color: Colors.black54,
                                                    placeholderBuilder: (context) =>
                                                        CircularProgressIndicator(),
                                                    height: 20.0,
                                                    width: 20,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Packaging:'.tr()),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(packaging??"".tr())
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'No. of pieces :'.tr(),
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      AutoSizeText(
                                                        '${widget.ordersDataModel?.quantity ?? "1"}',
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          // fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'No of Cartoons : '
                                                            .tr(),
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                      SizedBox(
                                                        width: 3,
                                                      ),
                                                      AutoSizeText(
                                                        '${widget.ordersDataModel?.noOfCartoons ?? "1"}',
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          // fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                          widget.ordersDataModel?.cod != '' &&
                                                          widget.ordersDataModel?.cod != '0' &&
                                                          widget.ordersDataModel?.cod != null
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                                'Cash on delivery:'
                                                                    .tr()),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(widget
                                                                    .ordersDataModel?.cod ?? ''),
                                                            SizedBox(width: 2),
                                                            Text(
                                                              'SR'.tr(),
                                                              style: TextStyle(
                                                                  fontSize: 11),
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                                  widget.ordersDataModel?.rc != '' &&
                                                  widget.ordersDataModel?.rc != '0' &&
                                                  widget.ordersDataModel?.rc != null
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                                'Delivery charge:'
                                                                    .tr()),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(widget
                                                                    .ordersDataModel?.rc ?? ''),
                                                            SizedBox(width: 2),
                                                            Text(
                                                              'SR'.tr(),
                                                              style: TextStyle(
                                                                  fontSize: 11),
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                                  widget.ordersDataModel?.fragile == '1'
                                                      ? Text('Fragile'.tr())
                                                      : Container(),
                                                  // widget.ordersDataModel?.extra != "0" &&
                                                  // widget.ordersDataModel?.extra != null
                                                  //     ? Row(
                                                  //         children: [
                                                  //           Text(
                                                  //             'Extra :'.tr(),
                                                  //             style:
                                                  //                 TextStyle(),
                                                  //           ),
                                                  //           SizedBox(
                                                  //             width: 3,
                                                  //           ),
                                                  //           Text(
                                                  //             widget.ordersDataModel?.extra ?? '',
                                                  //             style: TextStyle(
                                                  //               color: Colors
                                                  //                   .black,
                                                  //             ),
                                                  //           ),
                                                  //           SizedBox(
                                                  //             width: 3,
                                                  //           ),
                                                  //           Text(
                                                  //             'SR'.tr(),
                                                  //             style: TextStyle(
                                                  //                 fontSize: 11),
                                                  //           )
                                                  //         ],
                                                  //       )
                                                  //     : Container(),
                                                  widget.ordersDataModel?.rc != '' &&
                                                  widget.ordersDataModel?.rc != '0' &&
                                                  widget.ordersDataModel?.rc !=  null
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                              'Shipping on receiver:'
                                                                  .tr(),
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Icon(
                                                              Icons.check,
                                                              size: 13,
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                                  widget.ordersDataModel?.deductFromCod != '' &&
                                                  widget.ordersDataModel?.deductFromCod != '0' &&
                                                  widget.ordersDataModel?.deductFromCod != null
                                                      ? Row(
                                                          children: [
                                                            AutoSizeText(
                                                              'deductFromCod'
                                                                  .tr(),
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Icon(Icons.check,
                                                                size: 16),
                                                          ],
                                                        )
                                                      : Container()
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
