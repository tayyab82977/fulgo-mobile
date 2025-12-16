import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xturbox/blocs/bloc/clientCancelOrder_bloc.dart';
import 'package:xturbox/blocs/bloc/getOrders_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/blocs/events/clientCancelOrder_events.dart';
import 'package:xturbox/blocs/events/gerOrders_events.dart';
import 'package:xturbox/blocs/states/clientCancelOrder_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/Client/DetailedOrder.dart';
import 'package:xturbox/ui/Client/MyOrders.dart';
import 'package:xturbox/ui/Client/shipment_live_tracking.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/downloader.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';

import '../../data_providers/models/shipments_lists_model.dart';

enum AllActions { cancel, edit }
enum AllAction { cancel }
enum cancelActions { cancel }

class OrdersCard extends StatefulWidget {
  GetOrdersBloc? getOrdersBloc;
  ResourcesData? resourcesData;
  OrdersDataModelMix? ordersDataModel;
  bool? hasAction;
  ProfileDataModel? dashboardDataModel;
  Key? key;
  int? index;
  bool? showStatus;
  String? taskId ;
  ShipmentsListsModel? mixedShipmentsModel ;
  OrdersCard(
      {this.hasAction,
      this.taskId,
      this.ordersDataModel,
      this.resourcesData,
      this.getOrdersBloc,
      this.dashboardDataModel,
      this.key,
      this.index,
      this.mixedShipmentsModel,
      this.showStatus});

  @override
  _OrdersCardState createState() => _OrdersCardState();
}

class _OrdersCardState extends State<OrdersCard> {
  String? pickUpCity;
  String? pickUpZone;
  String? deliverCity;
  String? pickUpTime;
  String? deliverTime;
  String? shipmentStatus;
  String? deliverZone;
  double? width, height, screenHeight, screenWidth;

  ClientCancelOrderBloc cancelOrderBloc = ClientCancelOrderBloc();
  List<String> printTypes = ["4*4", "4*6 / pcs".tr(), "4*6".tr()];
  int count = 0 ;




  idToNames() {
    pickUpCity = IdToName.idToName(
        'city', widget.ordersDataModel?.pickupCity.toString()??"");

    pickUpZone = IdToName.idToName(
        'zone', widget.ordersDataModel?.pickupNeighborhood.toString()??"");

    deliverCity = IdToName.idToName(
        'city', widget.ordersDataModel?.deliverCity.toString() ?? "");

    deliverZone = IdToName.idToName(
        'zone', widget.ordersDataModel?.deliverNeighborhood.toString() ?? "");

    pickUpTime = IdToName.idToName(
        'times', widget.ordersDataModel?.pickupTime.toString()??"");

    deliverTime = IdToName.idToName(
        'times', widget.ordersDataModel?.deliverTime.toString()??"");

    shipmentStatus = IdToName.idToName(
        'trackType', widget.ordersDataModel?.trackType.toString()??"");
  }

  AllAction? _selectionAll;
  cancelActions? _selectionCancel;

  @override
  void dispose() {
    cancelOrderBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    idToNames();
    try {
      idToNames();
    } catch (e) {
      cancelOrderBloc.add(ClientCancelOrderEventsGenerateError());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      idToNames();
    } catch (e) {
      // cancelOrderBloc.add(ClientCancelOrderEventsGenerateError());
    }

    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    width = size.width;
    height = size.height;
    return BlocProvider(
      create: (context) => ClientCancelOrderBloc(),
      child: BlocConsumer<ClientCancelOrderBloc, ClientCancelOrderStates>(
        bloc: cancelOrderBloc,
        builder: (context, state) {
          if (state is ClientCancelOrderInitial) {
            return CreateOrderCard(
                cancelOrderBloc: cancelOrderBloc, loading: false);
          } else if (state is ClientCancelOrderLoading) {
            return CreateOrderCard(
                cancelOrderBloc: cancelOrderBloc, loading: true);
            ;
          } else if (state is ClientCancelOrderSuccess) {
            widget.getOrdersBloc!.add(GetOrders());
            return Container();
          } else if (state is ClientCancelOrderFailure) {
            return CreateOrderCard(
                cancelOrderBloc: cancelOrderBloc, loading: false);
          }
          return Container();
        },
        listener: (context, state) {
          if (state is ClientCancelOrderSuccess) {
            _onWidgetDidBuild(context, () {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('The Order has been cancelled'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
            });

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyOrdersScreen(
                          resourcesData: widget.resourcesData,
                        )));
          } else if (state is ClientCancelOrderFailure) {
            if (state.error == 'needUpdate') {
              GeneralHandler.handleNeedUpdateState(context);
            } else if (state.error == "general") {
              GeneralHandler.handleGeneralError(context);
            } else if (state.error == "invalidToken") {
              GeneralHandler.handleInvalidToken(context);
            }
            _onWidgetDidBuild(context, () {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Something went wrong please try again'.tr()),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
        },
      ),
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      callback();
    });
  }

  Widget CreateOrderCard(
      {ClientCancelOrderBloc? cancelOrderBloc, bool? loading}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(
                builder: (context) => DetailedOrder(
                      resourcesData: widget.resourcesData,
                      id: widget.ordersDataModel?.id ?? "",
                      dashboardDataModel: widget.dashboardDataModel,
                      ordersDataModelMix: widget.ordersDataModel,
                    )));
      },
      child: Padding(
        padding: EdgeInsets.only(
            left: screenWidth! * 0.02,
            right: screenWidth! * 0.02,
            top: screenWidth! * 0.02),
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.index != null
                            ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text("${widget.index! + 1} -" ,style: TextStyle(color: Constants.blueColor , fontWeight: FontWeight.bold,fontSize: 12 ), ),
                            )
                            :  const SizedBox(),
                        widget.ordersDataModel?.packaging == '1'
                            ? SvgPicture.asset(
                              "assets/images/regular.svg",
                              height: 35.0,
                            )
                            : widget.ordersDataModel?.packaging == '2'
                                ? SvgPicture.asset(
                                  "assets/images/save.svg",
                                  height: 35.0,
                                )
                                : widget.ordersDataModel?.packaging == '3'
                                    ? SvgPicture.asset(
                                      "assets/images/liquid.svg",
                                      height: 35.0,
                                    )
                                    : widget.ordersDataModel?.packaging == '4'
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: SvgPicture.asset(
                                              "assets/images/cold.svg",
                                              height: 35.0,
                                            ),
                                             ): Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: SvgPicture.asset(
                                                  "assets/images/save.svg",
                                                  height: 35.0,
                                                ),
                                              ),

                        const SizedBox(width: 5,),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, top: 7, bottom: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text('# '),
                                            Text(
                                              widget.ordersDataModel?.id ?? "",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'From : '.tr(),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.ordersDataModel?.senderName ?? "",
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Color(0xFF4C8FF8),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'To      : '.tr(),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.ordersDataModel?.receiverName ?? "",
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Color(0xFF4C8FF8),
                                          fontSize: 13,
                                          // fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                widget.ordersDataModel?.cod != "0"  &&  widget.ordersDataModel?.cod != null ?
                                Row(
                                  children: [
                                    Text(
                                      'Cash on delivery'.tr(),
                                      style: TextStyle(
                                          fontSize: 11),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.ordersDataModel?.cod.toString() ?? " ",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 12),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      'SR'.tr(),
                                      style: TextStyle(
                                          fontSize: 9),
                                    )
                                  ],
                                )  : SizedBox()

                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  widget.showStatus != null
                      ? Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Container(
                          width: screenWidth! * 0.14,
                          height: screenHeight! * 0.03,
                          decoration: BoxDecoration(
                              color: widget.ordersDataModel?.trackType == '5' || widget.ordersDataModel?.trackType == '16'? Color(0xFF56D340) : widget.ordersDataModel?.trackType == '14' || widget.ordersDataModel?.trackType == '20' || widget.ordersDataModel?.trackType == '21'?
                              Color(0xFFFF8A7B) : Color(0xFF4C8FF8),
                              borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: AutoSizeText(
                                '$shipmentStatus',
                                maxLines: 2,
                                maxFontSize: 9,
                                minFontSize: 7,
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontSize: screenWidth*0.1,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                      : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: (){

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
                                                  'A4'.tr(),
                                                  style: TextStyle(
                                                      color:
                                                      Colors.white,
                                                      fontSize: 11),
                                                ),
                                                onPressed:
                                                    () {

                                                  if (Platform.isAndroid) {
                                                    Downloader.downloadPDFAndroid2( widget.taskId , "https://portal.xturbox.com/print_invoice/${widget.ordersDataModel?.id}", widget.ordersDataModel?.id?? "");
                                                  } else {
                                                    Downloader.downloadPDFIOS2(widget.taskId , "https://portal.xturbox.com/print_invoice/${widget.ordersDataModel?.id}", widget.ordersDataModel?.id?? "");
                                                  }

                                                  Future.delayed(Duration(seconds: 1), () {
                                                    Navigator.of(context).pop();
                                                  });


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

                                                      if (Platform.isAndroid) {
                                                    Downloader.downloadPDFAndroid2( widget.taskId , "https://portal.xturbox.com/print_invoices/${widget.ordersDataModel?.id}", widget.ordersDataModel?.id?? "");
                                                  } else {
                                                    Downloader.downloadPDFIOS2(widget.taskId , "https://portal.xturbox.com/print_invoices/${widget.ordersDataModel?.id}", widget.ordersDataModel?.id?? "");
                                                  }
                                                      Future.delayed(Duration(seconds: 1), () {
                                                        Navigator.of(context).pop();
                                                      });

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

                                                      if (Platform.isAndroid) {
                                                    Downloader.downloadPDFAndroid2( widget.taskId , "https://portal.xturbox.com/print_invoices2/${widget.ordersDataModel?.id}", widget.ordersDataModel?.id?? "");
                                                  } else {
                                                    Downloader.downloadPDFIOS2(widget.taskId , "https://portal.xturbox.com/print_invoices2/${widget.ordersDataModel?.id}", widget.ordersDataModel?.id?? "");
                                                  }
                                                      Future.delayed(Duration(seconds: 1), () {
                                                        Navigator.of(context).pop();
                                                      });

                                                      // ComFunctions.launchURL("https://portal.xturbox.com/print_membervise2/${widget.capOrdersList!.first.member}");
                                                }),
                                          ],
                                        ),
                                      );
                                    });

                              },
                              child: Image.asset('assets/images/pdf.png', height: 30,),
                            ),
                            (widget.ordersDataModel?.followup?.isNotEmpty ?? false) && (widget.ordersDataModel?.followup != "0") && widget.ordersDataModel?.followup != widget.ordersDataModel?.id
                            ? Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: GestureDetector(
                                onTap: (){

                                  OrdersDataModelMix? reversedShipment ;
                                  try{
                                    reversedShipment = widget.mixedShipmentsModel?.deliveredShipments?.where((element) => element.id == widget.ordersDataModel?.followup).first ;
                                  }catch(e){



                                  }

                                  if(reversedShipment != null){
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context) => DetailedOrder(
                                              resourcesData: widget.resourcesData,
                                              id: widget.ordersDataModel?.id ?? "",
                                              dashboardDataModel: widget.dashboardDataModel,
                                              ordersDataModelMix: reversedShipment,
                                            )));
                                  }


                                  // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DetailedOrder()));
                                },
                                child: Icon(
                                    Icons.refresh,
                                    size: 30,
                                    color:Colors.black
                                ),
                              ),
                            )
                            : SizedBox(),
                         widget.ordersDataModel?.trackType == "4"?
                         Padding(
                           padding: const EdgeInsets.only(top: 5),
                           child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context)=>MyMap( shipmentId: widget.ordersDataModel?.id ,taker: widget.ordersDataModel?.taker,)));
                                  },
                             child: Image.asset('assets/images/live_tracking.png', height: 30,)),
                         ):SizedBox()
                          ],
                        ),
                      )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${widget.ordersDataModel?.stamp!.substring(0, 11)}', style: TextStyle(color: Colors.grey),),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
