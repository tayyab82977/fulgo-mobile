import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/clientCancelOrder_bloc.dart';
import 'package:xturbox/blocs/bloc/getOrders_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/blocs/events/clientCancelOrder_events.dart';
import 'package:xturbox/blocs/events/gerOrders_events.dart';
import 'package:xturbox/blocs/states/clientCancelOrder_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/ui/Client/addOrder.dart';
import 'package:xturbox/ui/Client/shipmentTracking.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/NetworkErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/drawerClient.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/packageCard.dart';
import 'package:xturbox/ui/dialogs/shipment_details_dialog.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/downloader.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';
import '../../main.dart';
import 'ClientEditShipment.dart';
import 'MyOrders.dart';
import '../custom widgets/custom_loading.dart';
import '../common/dashboard.dart';

class DetailedOrder extends StatefulWidget {
  ResourcesData? resourcesData;
  ProfileDataModel? dashboardDataModel;
  String? id;
  OrdersDataModelMix? ordersDataModelMix;
  DetailedOrder(
      {this.resourcesData,
      this.dashboardDataModel,
      this.id,
      this.ordersDataModelMix});

  @override
  _DetailedOrderState createState() => _DetailedOrderState();
}

class _DetailedOrderState extends State<DetailedOrder> {
  String? pickUpCity;
  String? pickUpZone;
  String? deliverCity;
  String? deliverZone;
  var pickUpTime;
  String? deliverTime;
  String? shipmentStatus;
  String? paymentMethod;
  String? packagingType;
  String? cancelReason;
  double? screenWidth, screenHeight;
  bool dataChanged = false;

  OrdersDataModelMix? ordersDataModelMix;

  idToNames(OrdersDataModelMix? ordersDataModelMix) {
    pickUpCity = IdToName.idToName('city', ordersDataModelMix?.pickupCity.toString()??"");
    if(pickUpCity == '' || pickUpCity == null){
      pickUpCity = IdToName.idToName(
          'cityFromNeighborhood', ordersDataModelMix?.pickupNeighborhood.toString()??"");
    }

    pickUpZone = IdToName.idToName(
        'zone', ordersDataModelMix?.pickupNeighborhood.toString()??"");

    deliverCity =
        IdToName.idToName('city', ordersDataModelMix?.deliverCity.toString()??"");

    if(deliverCity == '' || deliverCity == null){
      deliverCity = IdToName.idToName(
          'cityFromNeighborhood', ordersDataModelMix?.deliverNeighborhood.toString()??"");
    }

    deliverZone = IdToName.idToName(
        'zone', ordersDataModelMix?.deliverNeighborhood.toString()??"");

      pickUpTime = DateTime.tryParse(widget.ordersDataModelMix?.pickupTime.toString() ?? "");


    shipmentStatus = IdToName.idToName(
        'trackType', ordersDataModelMix?.trackType.toString() ?? "");

    paymentMethod = IdToName.idToName(
        'payment_method', ordersDataModelMix?.payment_method.toString() ?? "");
    packagingType =
        IdToName.idToName('packaging', ordersDataModelMix?.packaging.toString()??"");

    cancelReason = IdToName.idToName(
        'cancellation', ordersDataModelMix?.cancellation.toString()??"");
  }

  String? dateDays;
  String? dateMonth;
  String? dateYear;
  int timeH = 100000000;
  String? timeM;
  String? AMPM;
  late String _localPath;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  GlobalKey<RefreshIndicatorState>? refreshKeyHome;

  Future<Null>? onRefreshAll({required ClientCancelOrderBloc cancelOrderBloc}) {
    cancelOrderBloc.add(GetShipmentDetails(id: widget.ordersDataModelMix?.id));
    return null;
  }

  ReceivePort _port = ReceivePort();

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];
      _handleTabSelection();

      setState(() {
        widget.ordersDataModelMix?.taskId = id;
        widget.ordersDataModelMix?.statusDownload = status;
        widget.ordersDataModelMix?.progress = progress;
      });

      if (widget.ordersDataModelMix?.statusDownload ==
          DownloadTaskStatus.complete) {
        Future.delayed(Duration(seconds: 1), () {
          FlutterDownloader.open(taskId: widget.ordersDataModelMix?.taskId ?? "");
        });

        _onWidgetDidBuild(context, () {
          _drawerKey.currentState!.showSnackBar(
            SnackBar(
              content: Text('File Downloaded'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        });
      }
    });
  }

  void _handleTabSelection() {
    setState(() {});
  }

  gettingDate(OrdersDataModelMix? ordersDataModelMix) {
    timeH = int.parse(ordersDataModelMix?.stamp.toString().substring(11, 13) ?? "");
    if (timeH.toString().length > 13){

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


  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  void initState() {
    refreshKeyHome = GlobalKey<RefreshIndicatorState>();
    try {
      _bindBackgroundIsolate();
    } catch (e) {
    }
    FlutterDownloader.registerCallback(Downloader.downloadCallback);
    super.initState();
  }

  AuthenticationBloc authenticationBloc = AuthenticationBloc();
  Future<bool> _onBackPressed() async {
    if (dataChanged) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyOrdersScreen(
                    dashboardDataModel: widget.dashboardDataModel,
                    resourcesData: widget.resourcesData,
                  )));
    } else {
      Navigator.pop(context);
    }
    try {
      FlutterDownloader.remove(
          taskId: widget.ordersDataModelMix?.taskId ?? "",
          shouldDeleteContent: true);
      widget.ordersDataModelMix?.statusDownload = DownloadTaskStatus.undefined;
      widget.ordersDataModelMix?.progress = 0;
    } catch (e) {}
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // String timeH = ordersDataModelMix.stamp.toString().substring(11,13);
    // String timeM = ordersDataModelMix.stamp.toString().substring(14,16);

    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return BlocProvider(
      create: (context) => ClientCancelOrderBloc(),
      child: BlocConsumer<ClientCancelOrderBloc, ClientCancelOrderStates>(
        builder: (context, state) {
          if (state is ClientCancelOrderLoading) {
            return CreateDetailedOrderScreen(
                cancelOrderBloc:
                    BlocProvider.of<ClientCancelOrderBloc>(context),
                ordersDataModelMix: widget.ordersDataModelMix);
          }

          if (state is ShipmentDetailsLoaded) {
            return CreateDetailedOrderScreen(
                cancelOrderBloc:
                    BlocProvider.of<ClientCancelOrderBloc>(context),
                ordersDataModelMix: state.ordersDataModel);
          } else if (state is ShipmentDetailsError) {
            return CreateDetailedOrderScreen(
                cancelOrderBloc:
                    BlocProvider.of<ClientCancelOrderBloc>(context),
                ordersDataModelMix: widget.ordersDataModelMix);
          }
          return CreateDetailedOrderScreen(
              cancelOrderBloc: BlocProvider.of<ClientCancelOrderBloc>(context),
              ordersDataModelMix: widget.ordersDataModelMix);
        },
        listener: (context, state) {
          if (state is ClientCancelOrderSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MyOrdersScreen(
                        dashboardDataModel: widget.dashboardDataModel,
                        resourcesData: widget.resourcesData,
                      )),
              (route) => false,
            );
          } else if (state is ClientCancelOrderFailure) {
            Navigator.pop(context);
            if (state.error == 'TIMEOUT') {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetworkErrorView();
                  });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            } else if (state.error == "invalidToken") {
              GeneralHandler.handleInvalidToken(context);
            } else if (state.error == 'needUpdate') {
              GeneralHandler.handleNeedUpdateState(context);
            } else if (state.error == "general") {
              GeneralHandler.handleGeneralError(context);
            } else {
              _onWidgetDidBuild(context, () {
                _drawerKey.currentState!.showSnackBar(
                  SnackBar(
                    content: Container(
                      width: screenWidth,
                      height: screenHeight! * 0.1,
                      child: ListView.builder(
                        itemCount: state.errors!.length,
                        itemBuilder: (context, i) {
                          return Text(state.errors![i]!);
                        },
                      ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }
          } else if (state is ShipmentDetailsLoaded) {
            Navigator.pop(context);
            dataChanged = true;
            widget.ordersDataModelMix = state.ordersDataModel;
          } else if (state is ShipmentDetailPop) {
            Navigator.pop(context);
          } else if (state is ShipmentDetailsLoading) {
            ComFunctions.ProgressDialog(context);
          } else if (state is ClientCancelOrderLoading) {
            ComFunctions.ProgressDialog(context);
          } else if (state is ShipmentDetailsError) {
            _onWidgetDidBuild(context, () {
              _drawerKey.currentState!.showSnackBar(
                SnackBar(
                  content: Container(
                    width: screenWidth,
                    height: screenHeight! * 0.1,
                    child: ListView.builder(
                      itemCount: state.errorList!.length,
                      itemBuilder: (context, i) {
                        return Text(state.errorList![i]!);
                      },
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            });
          } else if (state is ShipmentZeroActionSuccess) {
            Navigator.pop(context);
            BlocProvider.of<ClientCancelOrderBloc>(context)
                .add(GetShipmentDetails(id: widget.ordersDataModelMix?.id));
          }
        },
      ),
    );
  }

  Widget CreateDetailedOrderScreen({bool? loading, ClientCancelOrderBloc? cancelOrderBloc, required OrdersDataModelMix? ordersDataModelMix}) {

    try {
      gettingDate(ordersDataModelMix);
      idToNames(ordersDataModelMix);

      dateDays = ordersDataModelMix?.stamp.toString().substring(8, 10);
      dateMonth = ordersDataModelMix?.stamp.toString().substring(5, 7);
      dateYear = ordersDataModelMix?.stamp.toString().substring(0, 4);
      timeM = ordersDataModelMix?.stamp.toString().substring(14, 16);
    } catch (e) {
      // // cancelOrderBloc!.addError(ClientCancelOrderEventsGenerateError());
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Constants.clientBackgroundGrey,
        body: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SafeArea(
              child: SingleChildScrollView(
                key: ValueKey('detailedOrderScroll'),
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/images/regular.svg",
                                      height: 38.0,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '#'.tr(),
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              ordersDataModelMix?.id ?? "",
                                              style: TextStyle(fontSize: 16),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${ordersDataModelMix?.stamp!.substring(0, 11)}',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '$timeH:$timeM',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  AMPM ?? ''.tr(),
                                                  style:
                                                      TextStyle(fontSize: 9),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ButtonTheme(
                              key: const ValueKey('closeDtOrder'),
                              minWidth: 0,
                              height: 0,
                              child: FlatButton(
                                padding: EdgeInsets.all(1),
                                minWidth: 0,
                                height: 0,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onPressed: _onBackPressed,
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
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ordersDataModelMix?.trackType == '9' ||  ordersDataModelMix?.trackType == '1' ||  ordersDataModelMix?.trackType == '18'
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Options'.tr(),
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: IconButton(
                                            key: const ValueKey(
                                                'editShipment'),
                                            padding: EdgeInsets.all(2),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddOrder(
                                                            resourcesData: widget
                                                                .resourcesData,
                                                            dashboardDataModelNew:
                                                                widget
                                                                    .dashboardDataModel,
                                                            ordersDataModel:
                                                                ordersDataModelMix,
                                                          )));
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              size: 30,
                                              color: Colors.black54,
                                            ),
                                          )),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('Edit shipment'.tr())
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: IconButton(
                                            key: const ValueKey(
                                                'cancelShipment'),
                                            padding: EdgeInsets.all(2),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Column(
                                                        children: [
                                                          Text(
                                                              'Are you sure that you want to cancel this shipment ?'
                                                                  .tr()),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          child: Text(
                                                            'No'.tr(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        TextButton(
                                                          key: const ValueKey(
                                                              'yesCancel'),
                                                          child: Text(
                                                            'Yes'.tr(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red),
                                                          ),
                                                          onPressed: () {
                                                            cancelOrderBloc!.add(CancelMyOrder(
                                                                    id: ordersDataModelMix?.id));
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                            icon: Icon(
                                              Icons.block,
                                              size: 30,
                                              color: Color(0xFFFA8154),
                                            ),
                                          )),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Cancel shipment'.tr(),
                                        style: TextStyle(
                                            color: Color(0xFFFA8154)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          )
                   : ordersDataModelMix?.trackType == '5' && ((ordersDataModelMix?.followup?.isEmpty ?? true)|| ordersDataModelMix?.followup == "0")
                        ? Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (context) {
                                          return ShipmentDetailsDialog(ordersDataModelMix: widget.ordersDataModelMix!,cancelOrderBloc: cancelOrderBloc!);
                                        });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10)
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.refresh,
                                              size: 30,
                                                color:Colors.black
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Reverse shipment'.tr(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color:Colors.black),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                                SizedBox(height: 10,),

                              ],
                            ),
                          ],
                        )
                        : SizedBox(),
                    Row(
                      children: [
                        Text(
                          'Shipment information'.tr(),
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Shipment status'.tr()),
                            Column(
                              children: [
                                ordersDataModelMix?.trackType == '5' ||
                                        ordersDataModelMix?.status == '16'
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        child: Container(
                                          width: 120,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Color(0xFF56D340),
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              border: Border.all(
                                                  color: Color(0xFF56D340),
                                                  width: 1)),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$shipmentStatus',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w900),
                                            ),
                                          ),
                                        ),
                                      )
                                    : ordersDataModelMix?.trackType == '14' || ordersDataModelMix?.trackType == '20' || ordersDataModelMix?.trackType == '21'
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            child: Container(
                                              width: 120,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFFF8A7B),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40),
                                                  border: Border.all(
                                                      color:
                                                      Color(0xFFFF8A7B),
                                                      width: 1)),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '$shipmentStatus',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            child: Container(
                                              width: 120,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: Constants.blueColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40),
                                                  border: Border.all(
                                                      color:
                                                         Constants.blueColor,
                                                      width: 1)),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '$shipmentStatus',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ),
                                            ),
                                          ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),

                  ordersDataModelMix?.trackType == "11"  && ordersDataModelMix?.barcode != null ?
                   InkWell(
                    onTap: (){
                      ComFunctions.launchURL("https://sdm.smsaexpress.com/track.aspx");
                    },
                    child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Constants.blueColor),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Track from the partner'.tr()),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(ordersDataModelMix?.barcode ?? ""),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                  ) : SizedBox(),

                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Payment method'.tr()),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text( paymentMethod??''),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Packaging'.tr()),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(packagingType ?? ''),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('no. of pieces'.tr()),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      widget.ordersDataModelMix?.quantity ??
                                          '1'),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    widget.ordersDataModelMix?.comment != null &&
                            widget.ordersDataModelMix?.comment != ""
                        ? Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('parcel details'.tr()),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AutoSizeText(
                                            widget.ordersDataModelMix?.comment ??
                                                '',
                                            textAlign:
                                                EasyLocalization.of(context)!
                                                            .currentLocale ==
                                                        Locale("en")
                                                    ? TextAlign.right
                                                    : TextAlign.left,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pickup time'.tr()),
                                // pickUpTime != null && ordersDataModelMix.pickupTime.toString().length > 1 ?
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Row(
                                //     children: [
                                //       Text(pickUpTime!.day.toString() + "-" + pickUpTime!.month.toString() + "-" + pickUpTime!.year.toString() ),
                                //       SizedBox(width: 10,),
                                //       Text(pickUpTime!.hour.toString() + ":" + pickUpTime!.minute.toString() ),
                                //     ],
                                //   ),
                                // ) :  Text(pickUpTime.toString() ),

                                (ordersDataModelMix?.pickupTime.toString().length  ?? 0) > 12  ?
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Date".tr(),style: TextStyle(fontSize: 12)),
                                    SizedBox(width: screenWidth!*0.015,),
                                    Text(pickUpTime.day.toString() + " - " + pickUpTime.month.toString() + " - " + pickUpTime.year.toString() ,style: TextStyle(fontSize: 12), ),
                                    SizedBox(width: screenWidth!*0.03,),
                                    Text("Time".tr(),style: TextStyle(fontSize: 14)),
                                    SizedBox(width: screenWidth!*0.015,),
                                    EasyLocalization.of(context)!.locale == Locale('en') ?
                                    Text(pickUpTime.hour.toString() + " : " + pickUpTime.minute.toString(),style: TextStyle(fontSize: 12) ) :
                                    Text( pickUpTime.minute.toString() + " : "  + pickUpTime.hour.toString(),style: TextStyle(fontSize: 12))
                                  ],
                                ) : Container()

                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                    ordersDataModelMix?.por == '1'
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Shipping on receiver'.tr()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.fragile == '1'
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Fragile'.tr()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.cod != '0' &&
                            ordersDataModelMix?.cod != null &&
                            ordersDataModelMix?.cod != ''
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Cash on delivery'.tr()),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Text(
                                                ordersDataModelMix?.cod ?? ''),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Text(
                                              'SR'.tr(),
                                              style: TextStyle(fontSize: 11),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.deductFromCod != "0" &&
                            ordersDataModelMix?.deductFromCod != "" &&
                            ordersDataModelMix?.deductFromCod != ""
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('deductFromCod'.tr()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.rc != '0' &&
                            ordersDataModelMix?.rc != '' &&
                            ordersDataModelMix?.rc != null
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Shipping on receiver'.tr()),
                                          // ordersDataModelMix?.status == "1" ||
                                          //         ordersDataModelMix?.status ==
                                          //             "2" ||
                                          //         ordersDataModelMix?.status ==
                                          //             "3" ||
                                          //         ordersDataModelMix?.status ==
                                          //             "4"
                                          //     ? InkWell(
                                          //         onTap: () {
                                          //           showDialog(
                                          //               context: context,
                                          //               barrierDismissible:
                                          //                   true,
                                          //               builder: (context) {
                                          //                 return AlertDialog(
                                          //                   title: Column(
                                          //                     children: [
                                          //                       Text('Are you sure ?'
                                          //                           .tr()),
                                          //                     ],
                                          //                   ),
                                          //                   actions: [
                                          //                     TextButton(
                                          //                       child: Text(
                                          //                         'No'.tr(),
                                          //                         style: TextStyle(
                                          //                             color: Colors
                                          //                                 .green),
                                          //                       ),
                                          //                       onPressed:
                                          //                           () {
                                          //                         Navigator.pop(
                                          //                             context);
                                          //                       },
                                          //                     ),
                                          //                     TextButton(
                                          //                       child: Text(
                                          //                         'Yes'.tr(),
                                          //                         style: TextStyle(
                                          //                             color: Colors
                                          //                                 .red),
                                          //                       ),
                                          //                       onPressed:
                                          //                           () {
                                          //                         cancelOrderBloc!.add(ZeroRC(
                                          //                             shipmentId:
                                          //                                 ordersDataModelMix?.id));
                                          //                         Navigator.pop(
                                          //                             context);
                                          //                       },
                                          //                     ),
                                          //                   ],
                                          //                 );
                                          //               });
                                          //         },
                                          //         child: Padding(
                                          //           padding:
                                          //               EdgeInsets.symmetric(
                                          //                   vertical: 8,
                                          //                   horizontal:
                                          //                       screenWidth! *
                                          //                           0.03),
                                          //           child: Container(
                                          //             width:
                                          //                 screenWidth! * 0.12,
                                          //             height: 30,
                                          //             decoration:
                                          //                 BoxDecoration(
                                          //               color:
                                          //                   Color(0xFFFA8154),
                                          //               borderRadius:
                                          //                   BorderRadius
                                          //                       .circular(40),
                                          //             ),
                                          //             child: Center(
                                          //                 child: AutoSizeText(
                                          //               'Cancel'.tr(),
                                          //               style: TextStyle(
                                          //                   color:
                                          //                       Colors.white,
                                          //                   fontSize: 11,
                                          //                   fontWeight:
                                          //                       FontWeight
                                          //                           .w900),
                                          //             )),
                                          //           ),
                                          //         ),
                                          //       )
                                          //     : Container()
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.extra != "0" &&
                            ordersDataModelMix?.extra != null
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('extra'.tr()),
                                      Row(
                                        children: [
                                          Text(
                                            ordersDataModelMix?.extra ??"",
                                            style: TextStyle(),
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            "SR".tr(),
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.cancellation != '0'
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Cancellation reason'.tr()),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(cancelReason ?? ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.reject != null
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Rejection reason'.tr()),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            ordersDataModelMix?.reject ?? ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    ordersDataModelMix?.followup != '0'
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Follow up'.tr()),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${ordersDataModelMix?.followup}',
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    Row(
                      children: [
                        Text(
                          'Receiver information'.tr(),
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Full name'.tr(),
                              style: TextStyle(fontSize: 11),
                            ),
                            Container(
                              width: screenWidth! * 0.6,
                              child: Text(
                                ordersDataModelMix?.receiverName ?? '',
                              ),
                            )
                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Phone number'.tr(),
                                style: TextStyle(fontSize: 11)),
                            Container(
                              width: screenWidth! * 0.6,
                              child: Row(
                                children: [
                                  Text(
                                    ordersDataModelMix?.receiverPhone ?? '',
                                  ),
                                  SizedBox(
                                    width: screenWidth! * 0.10,
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      ComFunctions.launcPhone(
                                          ordersDataModelMix?.receiverPhone ??
                                              '');
                                    },
                                    icon: Icon(
                                      Icons.phone,
                                      size: screenWidth! * 0.06,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      ComFunctions.launcWhatsapp(
                                          ordersDataModelMix?.receiverPhone ??
                                              '');
                                    },
                                    icon: Icon(
                                      MdiIcons.whatsapp,
                                      size: screenWidth! * 0.06,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('City'.tr(), style: TextStyle(fontSize: 11)),
                            Container(
                              width: screenWidth! * 0.6,
                              child: AutoSizeText(
                                deliverCity ?? '',
                                maxLines: 1,
                              ),
                            )

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Neighborhood'.tr(),
                                style: TextStyle(fontSize: 11)),
                            Container(
                              width: screenWidth! * 0.6,
                              child: AutoSizeText(
                                deliverZone ?? '',
                                maxLines: 1,
                              ),
                            )

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    ordersDataModelMix?.deliverAddress != null &&
                            ordersDataModelMix?.deliverAddress != ''
                        ? Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Address'.tr()),
                                      Container(
                                        width: screenWidth! * 0.7,
                                        height: 35,
                                        child: AutoSizeText(
                                          ordersDataModelMix?.deliverAddress ??
                                              '',
                                          maxLines: 3,
                                          maxFontSize: 12,
                                          minFontSize: 9,
                                        ),
                                      )
                                      // Text(ordersDataModelMix.senderName)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    ordersDataModelMix?.deliverMap != '' &&
                            ordersDataModelMix?.deliverMap != null
                        ? Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  ComFunctions.launchURL(
                                      ordersDataModelMix?.deliverMap ?? '');
                                },
                                child: Container(
                                  width: screenWidth! * 0.7,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Color(0xFF56D340), width: 2),
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: SvgPicture.asset(
                                          "assets/images/google-maps.svg",
                                          placeholderBuilder: (context) =>
                                              CustomLoading(),
                                          // height: 18.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Position on Google Maps'.tr(),
                                        style: TextStyle(
                                          color: Color(0xFF56D340),
                                          fontSize: 17,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    Row(
                      children: [
                        Text(
                          'Shipment Tracking'.tr(),
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    InkWell(
                      key: const ValueKey("trackingBtn"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShipmentTracking(
                                      resourcesData: widget.resourcesData,
                                      trackingId: ordersDataModelMix?.id,
                                    )));
                      },
                      child: Container(
                        width: screenWidth! * 0.7,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Constants.blueColor, width: 2),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: SvgPicture.asset(
                                "assets/images/route.svg",
                                color: Constants.blueColor,
                                placeholderBuilder: (context) =>
                                    CustomLoading(),
                                height: 20.0,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Track'.tr(),
                              style: TextStyle(
                                color: Constants.blueColor,
                                fontSize: 17,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    widget.ordersDataModelMix?.statusDownload ==
                            DownloadTaskStatus.complete
                        ? InkWell(
                            onTap: () {
                              FlutterDownloader.open(
                                  taskId: widget.ordersDataModelMix?.taskId ?? "");
                            },
                            child: Container(
                              width: screenWidth! * 0.7,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Icon(
                                      MdiIcons.filePdfBox,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Preview'.tr(),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 17,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              15)),
                                      title: Column(
                                        children: [
                                          Text(
                                            "Print".tr(),
                                            style: TextStyle(
                                                fontSize:
                                                14),
                                          ),
                                          FlatButton(
                                              height:
                                              40,
                                              padding:
                                              EdgeInsets.all(
                                                  0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      10)),
                                              color: Constants.capPurple,
                                              child:
                                              Text(
                                                '4*4'.tr(),
                                                style: TextStyle(
                                                    color:
                                                    Colors.white,
                                                    fontSize: 11),
                                              ),
                                              onPressed:
                                                  () {
                                                Navigator.pop(context);

                                                if (Platform.isAndroid) {
                                                  Downloader.downloadPDFAndroid2( widget.ordersDataModelMix?.taskId , "https://portal.xturbox.com/print_invoice/${widget.ordersDataModelMix?.id}", widget.ordersDataModelMix?.id?? "");
                                                } else {
                                                  Downloader.downloadPDFIOS2(widget.ordersDataModelMix?.taskId , "https://portal.xturbox.com/print_invoice/${widget.ordersDataModelMix?.id}", widget.ordersDataModelMix?.id?? "");
                                                }

                                              }),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          FlatButton(
                                              height:
                                              40,
                                              padding:
                                              EdgeInsets.all(
                                                  0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      10)),
                                              color: Constants
                                                  .capDarkPink,
                                              child:
                                              Text(
                                                "4*6 / pcs"
                                                    .tr(),
                                                style: TextStyle(
                                                    color:
                                                    Colors.white,
                                                    fontSize: 11),
                                              ),
                                              onPressed:
                                                  () {
                                                Navigator.of(context);
                                                if (Platform.isAndroid) {
                                                  Downloader.downloadPDFAndroid2( widget.ordersDataModelMix?.taskId , "https://portal.xturbox.com/print_invoices/${widget.ordersDataModelMix?.id}", widget.ordersDataModelMix?.id?? "");
                                                } else {
                                                  Downloader.downloadPDFIOS2(widget.ordersDataModelMix?.taskId , "https://portal.xturbox.com/print_invoices/${widget.ordersDataModelMix?.id}", widget.ordersDataModelMix?.id?? "");
                                                }

                                                // ComFunctions.launchURL("https://portal.xturbox.com/print_membervise/${widget.capOrdersList!.first.member}");
                                              }),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          FlatButton(
                                              height:
                                              40,
                                              padding:
                                              EdgeInsets.all(
                                                  0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      10)),
                                              color: Colors
                                                  .blueAccent,
                                              child:
                                              Text(
                                                "4*6"
                                                    .tr(),
                                                style: TextStyle(
                                                    color:
                                                    Colors.white,
                                                    fontSize: 11),
                                              ),
                                              onPressed:
                                                  () {
                                                Navigator.of(
                                                    context);
                                                if (Platform.isAndroid) {
                                                  Downloader.downloadPDFAndroid2( widget.ordersDataModelMix?.taskId , "https://portal.xturbox.com/print_invoices2/${widget.ordersDataModelMix?.id}", widget.ordersDataModelMix?.id?? "");
                                                } else {
                                                  Downloader.downloadPDFIOS2(widget.ordersDataModelMix?.taskId , "https://portal.xturbox.com/print_invoices2/${widget.ordersDataModelMix?.id}", widget.ordersDataModelMix?.id?? "");
                                                }
                                                // ComFunctions.launchURL("https://portal.xturbox.com/print_membervise2/${widget.capOrdersList!.first.member}");
                                              }),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              width: screenWidth! * 0.7,
                              height: 35,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Constants.redColor, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Icon(
                                        Icons.print,
                                        color: Constants.redColor,
                                      )),
                                  Text(
                                    'Print'.tr(),
                                    style: TextStyle(
                                      color: Constants.redColor,
                                      fontSize: 17,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 5,
                    ),
                    widget.ordersDataModelMix?.statusDownload ==
                                DownloadTaskStatus.running ||
                            widget.ordersDataModelMix?.statusDownload ==
                                DownloadTaskStatus.paused
                        ? Container(
                            width: screenWidth,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              value: (widget.ordersDataModelMix?.progress ?? 100) / 100,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }
}
