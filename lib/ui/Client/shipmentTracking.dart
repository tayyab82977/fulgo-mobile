import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/tracking_controller.dart';
import 'package:Fulgox/ui/Client/shipment_live_tracking.dart';
import 'package:Fulgox/ui/custom%20widgets/home_button.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/utilities/idToNameFunction.dart';
import '../custom widgets/NetworkErrorView.dart';
import 'dart:ui' as ui;
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/trackingDataModel.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

import 'package:Fulgox/utilities/Constants.dart';

import '../custom widgets/custom_loading.dart';

class ShipmentTracking extends StatefulWidget {
  String? trackingId;
  ResourcesData? resourcesData;
  ProfileDataModel? dashboardDataModel;
  bool showBottomBar = true;
  ShipmentTracking(
      {this.resourcesData,
      this.dashboardDataModel,
      this.trackingId,
      this.showBottomBar = true});
  @override
  _ShipmentTrackingState createState() => _ShipmentTrackingState();
}

class _ShipmentTrackingState extends State<ShipmentTracking> {
  double? width, height;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  List<TrackingDataModel> trackingList = [];
  var _formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  FocusNode trackingFocus = FocusNode();
  double screenWidth = 0, screenHeight = 0;
  final TrackingController _trackingController = Get.put(TrackingController());
  @override
  void dispose() {
    trackingFocus.dispose();
    super.dispose();
  }

  bool showLiveTracking = false;

  @override
  void initState() {
    super.initState();
    if (widget.trackingId != null && widget.trackingId != '') {
      idController.text = widget.trackingId!;
      _trackingController.getTracking(id: widget.trackingId!);
    }
  }

  String id = "";
  String taker = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    screenWidth = size.width;
    screenHeight = size.height;
    return Scaffold(
        key: _drawerKey,
        backgroundColor: Constants.clientBackgroundGrey,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.showBottomBar
                        ? const ClientAppBar()
                        : ClientAppBarNoAction(),
                    Expanded(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: width! * 0.03, left: width! * 0.03),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Shipment tracking'.tr(),
                                    style: TextStyle(fontSize: 19),
                                  ),
                                  widget.trackingId != null
                                      ? ButtonTheme(
                                          minWidth: 0,
                                          height: 0,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 2,
                                                    offset: Offset(0,
                                                        3), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: idController,
                                      focusNode: trackingFocus,
                                      autofocus: widget.trackingId != null
                                          ? false
                                          : true,
                                      onFieldSubmitted: (v) {
                                        if (_formKey.currentState!.validate()) {
                                          _trackingController.getTracking(id: idController.text);
                                        }
                                      },
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter the shipment tracking number'
                                              .tr();
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration:
                                          kTextFieldDecoration2.copyWith(
                                              hintText: "Shipment number".tr(),
                                              suffixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.search,
                                                    color: Constants.blueColor,
                                                  ),
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      _trackingController.getTracking(id: idController.text);
                                                    }
                                                  })),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              showLiveTracking
                                  ? ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MyMap(
                                                      shipmentId: id,
                                                      taker: taker,
                                                    )));
                                      },
                                      child: Text('Live tracking'.tr()),
                                    )
                                  : SizedBox(),
                              Expanded(
                                child: Obx(() {
                                  // Handle errors
                                  if (_trackingController.errorMessage.value.isNotEmpty) {
                                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                                      String error = _trackingController.errorMessage.value;
                                      if (error == "TIMEOUT") {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return NetworkErrorView();
                                            });
                                        Future.delayed(Duration(seconds: 2), () {
                                          Navigator.pop(context);
                                          _trackingController.errorMessage.value = '';
                                        });
                                      } else if (error == 'inValidShipment') {
                                        ComFunctions.showToastEditable(
                                          color: Colors.red,
                                          text: 'This shipment does not exist'.tr(),
                                          toastGravity: ToastGravity.CENTER,
                                          length: Toast.LENGTH_SHORT,
                                        );
                                        _trackingController.errorMessage.value = '';
                                      } else if (error == 'needUpdate') {
                                        GeneralHandler.handleNeedUpdateState(context);
                                        _trackingController.errorMessage.value = '';
                                      } else if (error == "general") {
                                        GeneralHandler.handleGeneralError(context);
                                        _trackingController.errorMessage.value = '';
                                      }
                                    });
                                  }

                                  // Show loading
                                  if (_trackingController.isLoading.value) {
                                    return Center(child: CustomLoading());
                                  }

                                  // Show tracking data
                                  if (_trackingController.trackingList.value != null) {
                                    return CreateTrackingScreen(_trackingController.trackingList.value);
                                  }

                                  return Container();
                                }),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              widget.showBottomBar ? Expanded(child: HomeButton()) : SizedBox(),
            ],
          ),
        ),
      );
  }

  Widget CreateTrackingScreen(dynamic trackingData) {
    // Convert dynamic data to TrackingList
    TrackingList trackingList = TrackingList.fromJson(trackingData ?? {});
    
    return ListView.builder(
      itemCount: 1,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Card(
          child: _DeliveryProcesses(processes: trackingList),
        );
      },
    );
  }
}

class _DeliveryProcesses extends StatelessWidget {
  _DeliveryProcesses({required this.processes});

  // final List<TrackingDataModel> processes;
  final TrackingList processes;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 12.5,
      ),
      child: Column(
        children: [
          processes.newTracks != null &&
                  (processes.newTracks?.isNotEmpty ?? false)
              ? _InnerTimeline(trackingDataModel: processes.newTracks ?? [])
              : SizedBox(),
          processes.processing != null &&
                  (processes.processing?.isNotEmpty ?? false)
              ? _InnerTimeline(trackingDataModel: processes.processing ?? [])
              : SizedBox(),
          processes.done != null && (processes.done?.isNotEmpty ?? false)
              ? _InnerTimeline(trackingDataModel: processes.done ?? [])
              : SizedBox(),
          processes.lost != null && (processes.lost?.isNotEmpty ?? false)
              ? _InnerTimeline(trackingDataModel: processes.lost ?? [])
              : SizedBox(),
        ],
      ),
      // child: Padding(
      //   padding: const EdgeInsets.all(20.0),
      //   child: FixedTimeline.tileBuilder(
      //     theme: TimelineThemeData(
      //       nodePosition: 0,
      //       color: Color(0xff989898),
      //       indicatorTheme: IndicatorThemeData(
      //         position: 0,
      //         size: 30.0,
      //       ),
      //       connectorTheme: ConnectorThemeData(
      //         thickness: 2.5,
      //       ),
      //     ),
      //     builder: TimelineTileBuilder.connected(
      //       connectionDirection: ConnectionDirection.after,
      //       itemCount: 3,
      //       contentsBuilder: (_, index) {
      //         return Padding(
      //           padding: EdgeInsets.symmetric(horizontal: 8.0),
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               if (index == 0)
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(
      //                     horizontal: 10,
      //                   ),
      //                   child: Text(
      //                     "Order Placed".tr(),
      //                     style: DefaultTextStyle.of(context).style.copyWith(
      //                           fontSize: 18.0,
      //                         ),
      //                   ),
      //                 )
      //               else if (index == 1)
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(
      //                     horizontal: 10,
      //                   ),
      //                   child: Text(
      //                     "Processing".tr(),
      //                     style: DefaultTextStyle.of(context).style.copyWith(
      //                           fontSize: 18.0,
      //                         ),
      //                   ),
      //                 )
      //               else if (index == 2 &&
      //                   (processes.lost?.isNotEmpty ?? false))
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(
      //                     horizontal: 10,
      //                   ),
      //                   child: Text(
      //                     "Cancelled".tr(),
      //                     style: DefaultTextStyle.of(context).style.copyWith(
      //                           fontSize: 18.0,
      //                         ),
      //                   ),
      //                 )
      //               else
      //                 Padding(
      //                   padding: const EdgeInsets.symmetric(
      //                     horizontal: 10,
      //                   ),
      //                   child: Text(
      //                     "Delivered".tr(),
      //                     style: DefaultTextStyle.of(context).style.copyWith(
      //                           fontSize: 18.0,
      //                         ),
      //                   ),
      //                 ),

      //               // for(int i = 0 ; i < processes.length ; i++)
      //               if (index == 0)
      //                 _InnerTimeline(
      //                     trackingDataModel: processes.newTracks ?? [])
      //               else if (index == 1)
      //                 _InnerTimeline(
      //                     trackingDataModel: processes.processing ?? [])
      //               else
      //                 _InnerTimeline(trackingDataModel: processes.done ?? [])
      //             ],
      //           ),
      //         );
      //       },
      //       indicatorBuilder: (_, index) {
      //         bool done = false;
      //         if (index == 0)
      //           done = true;
      //         else if (index == 1)
      //           done = processes.done?.isNotEmpty ?? false;
      //         else
      //           done = processes.done?.isNotEmpty ?? false;
      //         if (done) {
      //           if (index == 2 && (processes.lost?.isNotEmpty ?? false))
      //             return DotIndicator(
      //               color: Constants.redColor.withOpacity(0.8),
      //               child: Icon(
      //                 Icons.close,
      //                 color: Colors.white,
      //                 size: 12.0,
      //               ),
      //             );
      //           else
      //             return DotIndicator(
      //               color: Color(0xff66c97f),
      //               child: Icon(
      //                 Icons.check,
      //                 color: Colors.white,
      //                 size: 12.0,
      //               ),
      //             );
      //         } else {
      //           return OutlinedDotIndicator(
      //             borderWidth: 2.5,
      //           );
      //         }
      //       },
      //       connectorBuilder: (_, index, ___) {
      //         bool done = false;
      //         if (index == 0)
      //           done = true;
      //         else if (index == 1)
      //           done = processes.done?.isNotEmpty ?? false;
      //         else
      //           done = processes.done?.isNotEmpty ?? false;
      //         if (index == 2 && (processes.lost?.isNotEmpty ?? false))
      //           return SolidLineConnector(
      //             color: Constants.redColor,
      //           );
      //         else
      //           return SolidLineConnector(
      //             color: done ? Color(0xff66c97f) : null,
      //           );
      //       },
      //     ),
      //   ),
      // ),
    );
  }
}

class _InnerTimeline extends StatefulWidget {
  const _InnerTimeline({required this.trackingDataModel});

  final List<TrackingDataModel> trackingDataModel;
  // final int currentIndex;

  @override
  State<_InnerTimeline> createState() => _InnerTimelineState();
}

class _InnerTimelineState extends State<_InnerTimeline> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdgeIndex(int index) {
      return index == 0 || index == widget.trackingDataModel.length + 1;
    }

    // return Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 8.0),
    //   child: FixedTimeline.tileBuilder(
    //     theme: TimelineTheme.of(context).copyWith(
    //       nodePosition: 0,
    //       connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
    //             thickness: 1.0,
    //           ),
    //       indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
    //             size: 10.0,
    //             position: 0.5,
    //           ),
    //     ),
    //     builder: TimelineTileBuilder(
    //       indicatorBuilder: (_, index) => Indicator.outlined(borderWidth: 1.0),
    //       startConnectorBuilder: (_, index) => Connector.solidLine(),
    //       endConnectorBuilder: (_, index) => Connector.solidLine(),
    //       contentsBuilder: (_, index) {
    //         return Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Flexible(
    //                 child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 20),
    //               child: Column(
    //                 children: [
    //                   Text(
    //                     widget.trackingDataModel[index].typeName ?? "",
    //                     style: TextStyle(fontSize: 16),
    //                   ),
    //                   // Directionality(
    //                   //     textDirection: ui.TextDirection.ltr,
    //                   //     child: Text(DateFormat("yyyy-MM-dd hh:mm aaa").format(DateTime.parse(widget.trackingDataModel[index].stamp ??'1974-03-20 00:00:00.000') ) , style: TextStyle(color: Colors.grey , fontSize: 10),)),
    //                 ],
    //               ),
    //             )),
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 Flexible(
    //                     child: Text(
    //                   widget.trackingDataModel[index].reason ?? "",
    //                   style: TextStyle(fontSize: 17),
    //                 )),
    //                 Directionality(
    //                     textDirection: ui.TextDirection.ltr,
    //                     child: Text(
    //                       DateFormat("yyyy-MM-dd hh:mm aaa").format(
    //                           DateTime.parse(
    //                               widget.trackingDataModel[index].stamp ??
    //                                   '1974-03-20 00:00:00.000')),
    //                       style: TextStyle(color: Colors.grey, fontSize: 13),
    //                     )),
    //               ],
    //             ),
    //           ],
    //         );
    //       },
    //       itemExtentBuilder: (_, index) => isEdgeIndex(index) ? 50.0 : 50.0,
    //       nodeItemOverlapBuilder: (_, index) =>
    //           isEdgeIndex(index) ? true : null,
    //       itemCount: widget.trackingDataModel.length,
    //     ),
    //   ),
    // );

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.trackingDataModel.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(
            Icons.check_circle,
            color: Constants.blueColor,
          ),
          title: Text(
            widget.trackingDataModel[index].typeName ?? "",
            style: TextStyle(fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.trackingDataModel[index].reason ?? "",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 5,
              ),
              Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Text(
                    DateFormat("yyyy-MM-dd hh:mm aaa").format(DateTime.parse(
                        widget.trackingDataModel[index].stamp ??
                            '1974-03-20 00:00:00.000')),
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _OrderInfo {
  const _OrderInfo({
    required this.id,
    required this.date,
    required this.driverInfo,
    required this.deliveryProcesses,
  });

  final int id;
  final DateTime date;
  final _DriverInfo driverInfo;
  final List<_DeliveryProcess> deliveryProcesses;
}

class _DriverInfo {
  const _DriverInfo({
    required this.name,
    required this.thumbnailUrl,
  });

  final String name;
  final String thumbnailUrl;
}

class _DeliveryProcess {
  const _DeliveryProcess(
    this.name, {
    this.messages = const [],
  });

  const _DeliveryProcess.complete()
      : this.name = 'Done',
        this.messages = const [];

  final String name;
  final List<_DeliveryMessage> messages;

  bool get isCompleted => name == 'Done';
}

class _DeliveryMessage {
  const _DeliveryMessage(this.createdAt, this.message);

  final String createdAt; // final DateTime createdAt;
  final String message;

  @override
  String toString() {
    return '$createdAt $message';
  }
}

class TrackingCard extends StatefulWidget {
  TrackingDataModel? trackingDataModel;
  ResourcesData? resourcesData;

  TrackingCard({this.trackingDataModel, this.resourcesData});

  @override
  _TrackingCardState createState() => _TrackingCardState();
}

class _TrackingCardState extends State<TrackingCard> {
  double screenWidth = 0, screenHeight = 0;
  String? trackingType;
  String? taker;
  String? giver;
  idToName() {
    trackingType = IdToName.idToName(
        'trackType', widget.trackingDataModel!.type.toString());
    // for (int i = 0; i < widget.resourcesData!.trackType!.length; i++) {
    //   if (widget.trackingDataModel!.type ==
    //       widget.resourcesData!.trackType![i].id) {
    //     trackingType = widget.resourcesData!.trackType![i].name;
    //   }
    // }
  }

  @override
  void initState() {
    idToName();
    print(widget.trackingDataModel?.reason);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.trackingDataModel!.stamp!.substring(0, 10),
                    style: TextStyle(fontSize: 12),
                  ),
                  Container(
                    width: screenWidth * 0.3,
                    child: AutoSizeText(
                      trackingType ?? '',
                      minFontSize: 9,
                      maxFontSize: 13,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3,
              ),
              widget.trackingDataModel?.type == '14'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          width: screenWidth * 0.3,
                          child: AutoSizeText(
                            'Reason'.tr(),
                            minFontSize: 9,
                            maxFontSize: 11,
                            maxLines: 2,
                          ),
                        ),
                        Container(
                            width: screenWidth * 0.3,
                            child: AutoSizeText(
                              widget.trackingDataModel?.reason ?? '',
                              minFontSize: 11,
                              maxFontSize: 13,
                              maxLines: 2,
                            )),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
