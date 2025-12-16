import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:xturbox/blocs/bloc/newTracking_bloc.dart';
import 'package:xturbox/blocs/bloc/tracking_bloc.dart';
import 'package:xturbox/blocs/events/newTracking_events.dart';
import 'package:xturbox/blocs/states/newTracking_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/trackingDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/custom%20widgets/NetworkErrorView.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';

import '../custom widgets/custom_loading.dart';
import '../custom widgets/myAppBar.dart';

class NewTrackingScreen extends StatefulWidget {
  String? shipmentId;
  NewTrackingScreen({this.shipmentId});
  @override
  _NewTrackingScreenState createState() => _NewTrackingScreenState();
}

class _NewTrackingScreenState extends State<NewTrackingScreen> {
  double? width, height;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  List<TrackingDataModel> trackingList = [];
  var _formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  FocusNode trackingFocus = FocusNode();
  double screenWidth = 0, screenHeight = 0;
  NewTrackingBloc trackingBloc = NewTrackingBloc();

  @override
  void dispose() {
    trackingFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.shipmentId != null && widget.shipmentId != '') {
      idController.text = widget.shipmentId!;
      trackingBloc.add(GetNewTracking(id: widget.shipmentId));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    screenWidth = size.width;
    screenHeight = size.height;
    return BlocProvider(
      create: (context) => NewTrackingBloc(),
      child: Scaffold(
        key: _drawerKey,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              ClientAppBarNoAction(),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: width! * 0.03, left: width! * 0.03),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipment tracking'.tr(),
                              style: TextStyle(fontSize: 19),
                            ),
                            ButtonTheme(
                              key: const ValueKey('closeTracking'),
                              minWidth: 0,
                              height: 0,
                              child: FlatButton(
                                padding: EdgeInsets.all(1),
                                minWidth: 0,
                                height: 0,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
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
                                autofocus:
                                    widget.shipmentId != null ? false : true,
                                onFieldSubmitted: (v) {
                                  if (_formKey.currentState!.validate()) {
                                    trackingBloc.add(
                                        GetNewTracking(id: idController.text));
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
                                decoration: kTextFieldDecoration2.copyWith(
                                    hintText: "Shipment number".tr(),
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            FocusScope.of(context).unfocus();

                                            trackingBloc.add(GetNewTracking(
                                                id: idController.text));
                                          }
                                        })),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child:
                              BlocConsumer<NewTrackingBloc, NewTrackingStates>(
                            bloc: trackingBloc,
                            builder: (context, state) {
                              if (state is NewTrackingLoading) {
                                return Center(
                                    child: CustomLoading());
                              }
                              if (state is NewTrackingLoaded) {
                                return CreateTrackingScreen(state);
                              }
                              return Container();
                            },
                            listener: (context, state) {
                              if (state is NewTrackingError) {
                                if (state.error == "TIMEOUT") {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return NetworkErrorView();
                                      });
                                  Future.delayed(Duration(seconds: 2), () {
                                    Navigator.pop(context);
                                  });
                                } else if (state.error == 'inValidShipment') {
                                  ComFunctions.showToastEditable(
                                    color: Colors.red,
                                    text: 'This shipment does not exist'.tr(),
                                    toastGravity: ToastGravity.CENTER,
                                    length: Toast.LENGTH_SHORT,
                                  );
                                } else if (state.error == 'needUpdate') {
                                  GeneralHandler.handleNeedUpdateState(context);
                                } else if (state.error == "general") {
                                  GeneralHandler.handleGeneralError(context);
                                }
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget CreateTrackingScreen(NewTrackingLoaded state) {
    List<TrackingDataModel> newOrder = [];
    List<TrackingDataModel> processing = [];
    List<TrackingDataModel> lost = [];
    List<TrackingDataModel> done = [];

    newOrder =
        state.trackingList!.where((element) => element.type == '9').toList();

    lost = state.trackingList!
        .where((element) => element.type == '10' || element.type == '14')
        .toList();
    done = state.trackingList!
        .where((element) =>
            element.type == '5' || element.type == '10' || element.type == '14')
        .toList();
    processing = state.trackingList!
        .where((element) =>
            element.type == '1' ||
            element.type == '2' ||
            element.type == '3' ||
            element.type == '4' ||
            element.type == '8' ||
            element.type == '7' ||
            element.type == '17')
        .toList();

    bool isActive(List<dynamic> list) {
      if (list.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }

    String newDate;
    String doneDate;
    String processingDate;
    if (isActive(newOrder)) {
      newDate = newOrder.first.stamp!.substring(0, 10);
    }
    if (isActive(processing)) {
      processingDate = processing.first.stamp!.substring(0, 10);
    }
    if (isActive(done)) {
      doneDate = done.first.stamp!.substring(0, 10);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(right: width! * 0.04),
                child: TimelineTile(
                  alignment: TimelineAlign.start,
                  indicatorStyle: IndicatorStyle(
                    width: screenWidth * 0.1,
                    color: isActive(newOrder) ? Colors.green : Colors.grey,
                    padding: const EdgeInsets.all(8),
                    iconStyle: IconStyle(
                      color: Colors.white,
                      iconData: Icons.check_circle_outline,
                    ),
                  ),
                  beforeLineStyle: LineStyle(color: Colors.transparent),
                  afterLineStyle: LineStyle(
                    color: isActive(processing) ? Colors.green : Colors.grey,
                  ),
                  endChild: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      constraints: const BoxConstraints(
                          // minHeight: 120,
                          ),
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Order Placed'.tr(),
                            style: TextStyle(
                                color: isActive(newOrder)
                                    ? Colors.black
                                    : Colors.grey,
                                fontWeight: FontWeight.w900,
                                fontSize: 19),
                          ),
                          Container(
                            width: screenWidth * 0.75,
                            height: newOrder.length * 50.0,
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: newOrder.length,
                                itemBuilder: (context, i) {
                                  return NewTrackingCard(
                                    // resourcesData: widget.resourcesData,
                                    trackingDataModel: newOrder[i],
                                    trackingBloc: trackingBloc,
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: width! * 0.04),
                child: TimelineTile(
                  alignment: TimelineAlign.start,
                  indicatorStyle: IndicatorStyle(
                    width: screenWidth * 0.1,
                    color: isActive(processing) ? Colors.green : Colors.grey,
                    padding: const EdgeInsets.all(8),
                    iconStyle: IconStyle(
                      color: Colors.white,
                      iconData: Icons.check_circle_outline,
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color: isActive(processing) ? Colors.green : Colors.grey,
                  ),
                  afterLineStyle: LineStyle(
                    color: isActive(done) ? Colors.green : Colors.grey,
                  ),
                  endChild: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      constraints: const BoxConstraints(
                          // minHeight: 120,
                          ),
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Processing'.tr(),
                            style: TextStyle(
                                color: isActive(processing)
                                    ? Colors.black
                                    : Colors.grey,
                                fontWeight: FontWeight.w900,
                                fontSize: 19),
                          ),
                          Container(
                            width: screenWidth * 0.75,
                            height: processing.length * 60.0,
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: processing.length,
                                itemBuilder: (context, i) {
                                  return NewTrackingCard(
                                    // resourcesData: widget.resourcesData,
                                    trackingDataModel: processing[i],
                                    trackingBloc: trackingBloc,
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: width! * 0.04),
                child: TimelineTile(
                  alignment: TimelineAlign.start,
                  indicatorStyle: IndicatorStyle(
                    width: screenWidth * 0.1,
                    color: isActive(lost)
                        ? Colors.red
                        : isActive(done)
                            ? Colors.green
                            : Colors.grey,
                    padding: const EdgeInsets.all(8),
                    iconStyle: IconStyle(
                      color: Colors.white,
                      iconData: isActive(lost)
                          ? Icons.cancel
                          : Icons.check_circle_outline,
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color: isActive(done) ? Colors.green : Colors.grey,
                  ),
                  afterLineStyle: LineStyle(color: Colors.transparent),
                  endChild: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      constraints: const BoxConstraints(
                          // minHeight: 120,
                          ),
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          lost.length > 0
                              ? Text(
                                  'Cancelled'.tr(),
                                  style: TextStyle(
                                      color: isActive(processing)
                                          ? Colors.black
                                          : Colors.grey,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 19),
                                )
                              : Text(
                                  'Delivered'.tr(),
                                  style: TextStyle(
                                      color: isActive(done)
                                          ? Colors.black
                                          : Colors.grey,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 19),
                                ),
                          Container(
                            width: screenWidth * 0.75,
                            height: done.length * 80.0,
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: done.length,
                                itemBuilder: (context, i) {
                                  return NewTrackingCard(
                                    // resourcesData: widget.resourcesData,
                                    trackingDataModel: done[i],
                                    trackingBloc: trackingBloc,
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class NewTrackingCard extends StatefulWidget {
  TrackingDataModel? trackingDataModel;
  ResourcesData? resourcesData;
  NewTrackingBloc? trackingBloc;

  NewTrackingCard(
      {this.trackingDataModel, this.resourcesData, this.trackingBloc});

  @override
  _TrackingCardState createState() => _TrackingCardState();
}

class _TrackingCardState extends State<NewTrackingCard> {
  double screenWidth = 0, screenHeight = 0;
  String? trackingType;
  String? taker;
  String? giver;

  List<Cancellation> trackTypes = [
    Cancellation(id: "1", name: "reserve"),
    Cancellation(id: "2", name: "pickup"),
    Cancellation(id: "3", name: "store-in"),
    Cancellation(id: "4", name: "store-out"),
    Cancellation(id: "5", name: "deliver"),
    Cancellation(id: "6", name: "handover"),
    Cancellation(id: "7", name: "transfer-out"),
    Cancellation(id: "8", name: "transfer-in"),
    Cancellation(id: "9", name: "new"),
    Cancellation(id: "10", name: "rejected"),
    Cancellation(id: "11", name: "partner-out"),
    Cancellation(id: "12", name: "partner-in"),
    Cancellation(id: "13", name: "client-removal"),
    Cancellation(id: "14", name: "canceled"),
    Cancellation(id: "15", name: "reschedule"),
    Cancellation(id: "16", name: "partner-deliver"),
    Cancellation(id: "17", name: "postpone"),
  ];
  idToName() {
    // trackingType = IdToName
    //     .idToName('trackingType', widget.trackingDataModel!.type.toString());
    for (int i = 0; i < trackTypes.length; i++) {
      if (widget.trackingDataModel!.type == trackTypes[i].id) {
        trackingType = trackTypes[i].name;
      }
    }
  }

  @override
  void initState() {
    idToName();
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
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
          child: Column(
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
                      trackingType.toString().tr(),
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
              widget.trackingDataModel!.type == '9' ||
                      widget.trackingDataModel!.type == '1' ||
                      widget.trackingDataModel!.type == '10' ||
                      widget.trackingDataModel!.type == '14' ||
                      widget.trackingDataModel!.type == '8'
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          width: screenWidth * 0.2,
                          child: AutoSizeText(
                            widget.trackingDataModel!.giver ?? '',
                            textAlign: TextAlign.right,
                            minFontSize: 11,
                            maxFontSize: 13,
                            maxLines: 2,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black54,
                          size: screenWidth * 0.04,
                        ),
                        Container(
                            width: screenWidth * 0.3,
                            child: AutoSizeText(
                              widget.trackingDataModel!.taker ?? '',
                              minFontSize: 11,
                              maxFontSize: 13,
                              maxLines: 2,
                              textAlign: TextAlign.right,
                              style: TextStyle(),
                            )),
                      ],
                    ),
              widget.trackingDataModel!.type == '4' &&
                      widget.trackingDataModel!.comment != null &&
                      widget.trackingDataModel!.comment != ""
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          width: 90,
                          child: AutoSizeText(
                            'Reason'.tr(),
                            textAlign: TextAlign.right,
                            minFontSize: 11,
                            maxFontSize: 13,
                            maxLines: 2,
                          ),
                        ),
                        Container(
                          width: 150,
                          child: AutoSizeText(
                            widget.trackingDataModel!.comment ?? '',
                            textAlign: TextAlign.left,
                            minFontSize: 11,
                            maxFontSize: 13,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    )
                  : Container(),
              (widget.trackingDataModel!.type == '10' ||
                              widget.trackingDataModel!.type == '14') &&
                          widget.trackingDataModel!.reason != null ||
                      widget.trackingDataModel!.reason != ""
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
                              widget.trackingDataModel!.reason ?? '',
                              minFontSize: 11,
                              maxFontSize: 13,
                              maxLines: 2,
                              style: TextStyle(),
                            )),
                      ],
                    )
                  : Container(),
              (widget.trackingDataModel!.type == '10' ||
                          widget.trackingDataModel!.type == '14') &&
                      widget.trackingDataModel!.followup != '0'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          width: screenWidth * 0.3,
                          child: AutoSizeText(
                            'Follow up'.tr(),
                            textAlign: TextAlign.right,
                            minFontSize: 11,
                            maxFontSize: 13,
                            maxLines: 2,
                          ),
                        ),
                        Container(
                            width: screenWidth * 0.3,
                            child: AutoSizeText(
                              widget.trackingDataModel!.followup ?? '',
                              minFontSize: 9,
                              maxFontSize: 11,
                              maxLines: 2,
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline),
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
