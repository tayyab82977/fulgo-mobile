import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:date_field/date_field.dart';
import 'package:fluttertoast/fluttertoast.dart' as Toast;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/captainOrders_bloc.dart';
import 'package:xturbox/blocs/bloc/myPickupActions_bloc.dart';
import 'package:xturbox/blocs/bloc/myPickup_bloc.dart';
import 'package:xturbox/blocs/bloc/myReserve_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/captainOrders_events.dart';
import 'package:xturbox/blocs/events/myPickupActions_events.dart';
import 'package:xturbox/blocs/events/myPickup_events.dart';
import 'package:xturbox/blocs/events/myReserve_events.dart';
import 'package:xturbox/blocs/states/myPickupActions_states.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/courier/DetailedCaptainOrder.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/NetworkErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/ui/courier/deliverScreen.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';


import '../Client/DetailedOrder.dart';
import 'customCheckBox.dart';

enum CaptainPickUpActions { deliver, cancel, reject, lost, damaged, postpone }
enum ShortAction { storeOut }

class CaptainOrderCardTwo extends StatefulWidget {
  MyPickupBloc? myPickupBloc;
  MyReservesBloc? myReservesBloc;
  ResourcesData? resourcesData;
  OrdersDataModelMix? ordersDataModel;
  CaptainOrdersBloc? captainOrdersBloc;
  bool? longActions;
  bool? shortActions;
  bool? noActions;
  bool? showD;
  bool reActive = false;
  List<OrdersDataModelMix>? orderList;
  GlobalKey<ScaffoldState>? scaffoldKey;

  CaptainOrderCardTwo(
      {this.resourcesData,
      this.ordersDataModel,
      this.myPickupBloc,
      this.longActions,
      this.noActions,
      this.shortActions,
      this.captainOrdersBloc,
      this.showD,
      this.orderList,
      this.reActive = false,
      this.myReservesBloc,
      this.scaffoldKey});

  @override
  _CaptainOrderCardTwoState createState() => _CaptainOrderCardTwoState();
}

class _CaptainOrderCardTwoState extends State<CaptainOrderCardTwo> {
  final GlobalKey<ScaffoldState> alertScfKey = GlobalKey<ScaffoldState>();

  CaptainPickUpActions? _selection;
  ShortAction? _selectionShortAction;
  String? pickUpCity;
  String? deliverCity;
  String? deliverTime;
  String? shipmentStatus;
  String? deliverZone;
  String? pickUpZone;
  double totalPayment = 0.0;
  bool isAsync = false;

  Cancellation? cancelIdSelected = Cancellation();
  Cancellation? postponeIdSelected = Cancellation();
  PaymentMethod? _currentSelectedPaymentMethod ;

  double? width, height, screenHeight, screenWidth;

  String? token;
  final rejectionReason = TextEditingController();
  final rescheduleReason = TextEditingController();
  final postponeReason = TextEditingController();

  PickupActionsBloc pickupActionsBloc = PickupActionsBloc();
  DateTime pickupTime = DateTime.now();

  idToNames() {
    try {
      cancelIdSelected = widget.resourcesData!.cancellation!.first;
      postponeIdSelected = widget.resourcesData!.postpone!.first;
    } catch (e) {}
    pickUpCity = IdToName.idToName(
        'city', widget.ordersDataModel!.pickupCityId.toString());

    pickUpZone = IdToName.idToName(
        'zone', widget.ordersDataModel!.pickupNeighborhood.toString());

    deliverCity = IdToName.idToName(
        'city', widget.ordersDataModel!.deliverCityId.toString());

    deliverZone = IdToName.idToName(
        'zone', widget.ordersDataModel!.deliverNeighborhood.toString());

    deliverTime = IdToName.idToName(
        'times', widget.ordersDataModel!.deliverTime.toString());

    shipmentStatus = IdToName.idToName(
        'shipmentStatus', widget.ordersDataModel!.status.toString());

    try {
      var cod, price;
      try{
        _currentSelectedPaymentMethod = widget.resourcesData?.paymentMethods?.first ;
      }catch(e){}
      cod = double.tryParse(widget.ordersDataModel?.cod ?? "0");
      price = double.tryParse(widget.ordersDataModel?.rc ?? "0");

      totalPayment = cod + price;

      // if(widget.ordersDataModel?.payment_method == '2'){
      //   totalPayment += price ;
      // }

    } catch (e) {
      ComFunctions.showToast(color: Colors.red, text: "error".tr());
    }
  }

  Future<String> _findLocalPath() async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  late String _localPath;




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
      print('_port.listen');
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];
      print('real id $id ');
      _handleTabSelection();

      if (status == DownloadTaskStatus.complete) {
        Future.delayed(Duration(seconds: 1), () {
          FlutterDownloader.open(taskId: id!);
        });

        _onWidgetDidBuild(context, () {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('File Downloaded'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        });
      }

      // if (widget.orderList != null && widget.orderList.isNotEmpty) {
      //   final task = widget.orderList.firstWhere((task) => task.taskId == id);
      //
      //     if(status == DownloadTaskStatus.running|| status == DownloadTaskStatus.enqueued){
      //       isAsync = true ;
      //     }
      //     else if(status == DownloadTaskStatus.complete){
      //       isAsync = false ;
      //       task.statusDownload = status;
      //
      //       _onWidgetDidBuild(context, () {
      //         Scaffold.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text('File Downloaded'.tr()),
      //             backgroundColor: Colors.green,
      //           ),
      //         );
      //       });
      //     }else {
      //       isAsync = false ;
      //     }
      //
      //   setState(() {
      //     task.statusDownload = status;
      //     task.progress = progress;
      //   });
      //
      //
      //
      // }
    });
  }

  void _handleTabSelection() {
    print('Rebuild');
    setState(() {});
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    pickupActionsBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    try {
      idToNames();
      _bindBackgroundIsolate();
    } catch (e) {
      // pickupActionsBloc.add(PickupActionsEventsGenerateError());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      idToNames();
    } catch (e) {
      // pickupActionsBloc.add(PickupActionsEventsGenerateError());
    }
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    width = size.width;
    height = size.height;

    return BlocProvider(
      create: (context) => PickupActionsBloc(),
      child: BlocConsumer<PickupActionsBloc, PickupActionsStates>(
        bloc: pickupActionsBloc,
        builder: (context, state) {
          if (state is PickupActionsInitial) {
            return CreateOrderCardTwo(
                loading: false, pickupActionsBloc: pickupActionsBloc);
          } else if (state is PickupActionsLoading) {
            return CreateOrderCardTwo(
                loading: true, pickupActionsBloc: pickupActionsBloc);
          } else if (state is PickupActionSuccess || state is PickupActionDispatchIssueSuccess) {
            widget.myPickupBloc?.add(GetMyPickup());

            return Container();
          } else if (state is PickupActionSoreOutSuccess) {
            widget.myPickupBloc?.add(GetMyPickup());

            return Container();
          }
          else if (state is PickupReActiveSuccess) {
            widget.myReservesBloc?.add(GetMyReserves());

            return Container();
          }

          else if (state is PickupActionsFailure) {
            return CreateOrderCardTwo(
                loading: false, pickupActionsBloc: pickupActionsBloc);
          }

          return CreateOrderCardTwo(
              loading: false, pickupActionsBloc: pickupActionsBloc);
        },
        listener: (context, state) {
          if (state is PickupActionSuccess || state is PickupActionDispatchIssueSuccess) {
            _showToast(
                color: Colors.green,
                msg: 'Successfully done'.tr(),
                context: context);
          }
          else if (state is PickupActionsFailure) {
            if (state.error == 'TIMEOUT') {
            } else if (state.error == 'needUpdate') {
              GeneralHandler.handleNeedUpdateState(context);
            } else if (state.error == "invalidToken") {
              GeneralHandler.handleInvalidToken(context);
            } else if (state.error == "general") {
              GeneralHandler.handleGeneralError(context);
            }
            else if (state is PickupActionSoreOutSuccess || state is PickupActionSuccess ) {
             print("PickupActionSoreOutSuccess is here");

            }
            else {
              _onWidgetDidBuild(context, () {
                widget.scaffoldKey!.currentState!.showSnackBar(
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
            }
          }
          else if(state is NoCallNoCancel){
            ComFunctions.showToast(color: Colors.red, text: "Can't cancel or postopne without calling the receiver".tr());
          }
          else if(state is ContactPrmNotGranted){
            ComFunctions.showToast(color: Colors.red, text: "You must give the access to the contacts ".tr());
          }
        },
      ),
    );
  }

  Widget CreateOrderCardTwo(
      {required bool loading, PickupActionsBloc? pickupActionsBloc}) {
    // return Container();
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailedCapOrder(
                        resourcesData: widget.resourcesData,
                        ordersDataModel: widget.ordersDataModel ?? OrdersDataModelMix(),
                        showDetails: widget.showD,
                      )));
        },
        child: Padding(
          padding: EdgeInsets.only(left: 12, right: 12, top: 15),
          child: Container(
            // width: screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(screenWidth! * 0.03),
                          child: Image.asset(
                            "assets/images/box.png",
                            // color: Colors.black54,
                            // placeholderBuilder: (context) => CustomLoading(),
                            height: screenWidth! * 0.08,
                            width: screenWidth! * 0.08,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                widget.shortActions! ?
                                Row(
                                  children: [
                                    GestureDetector(
                                        onTap:(){
                                          setState(() {
                                            widget.ordersDataModel?.selected = !(widget.ordersDataModel?.selected ?? false) ;
                                            if( widget.ordersDataModel?.selected ?? false){
                                              widget.ordersDataModel?.accepted = true;
                                            }else{
                                              widget.ordersDataModel?.accepted = null;
                                            }
                                          });
                                        },
                                        child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CustomCheckBox(
                                              backgroundColor: Colors.white,
                                              checked: widget.ordersDataModel?.selected,
                                              checkedColor: Constants.blueColor,
                                              unCheckedColor: Constants.blueColor),
                                        ),
                                      ),
                                    SizedBox(width: 5,),

                                  ],
                                ) : SizedBox(),
                                  Text(
                                    "#" + (widget.ordersDataModel?.id ?? ""),
                                    style: TextStyle(
                                        fontSize: screenWidth! * 0.04,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  widget.ordersDataModel?.direction == "2"
                                      ? Icon(
                                          Icons.settings_backup_restore,
                                          size: 17,
                                        )
                                      : Container(),
                                ],
                              ),
                              SizedBox(
                                height: 3,
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
                                        color: Constants.blueColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '$pickUpZone',
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Constants.blueColor,
                                        fontSize: 13,
                                        // fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'To      : '.tr(),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Flexible(
                                    child: Text(
                                      widget.ordersDataModel?.receiverName ??"",
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Constants.redColor,
                                        fontSize: 13,
                                        // fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  deliverZone != null
                                      ? Flexible(
                                          child: Text(
                                            '$deliverZone',
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: Constants.redColor,
                                              fontSize: 13,
                                              // fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        )
                                      : Flexible(
                                          child: Text(
                                            'Not specified'.tr(),
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: Constants.redColor,
                                              fontSize: 11,
                                              // fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              SizedBox(height: 5),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'No. of pieces :'.tr(),
                                    style: TextStyle(fontSize: 10),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'No of Cartoons : '.tr(),
                                    style: TextStyle(fontSize: 10),
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

                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //
                              //   children: [
                              //     Text('Neighborhood'.tr(),
                              //       style: TextStyle(
                              //           fontSize: 10
                              //       ),
                              //     ),
                              //     Container(
                              //       child: ConstrainedBox(
                              //         constraints: BoxConstraints(
                              //           minWidth: width!*0.1,
                              //           maxWidth: width!*0.4,),
                              //
                              //         child: AutoSizeText('$pickUpZone',
                              //           maxLines: 2,
                              //           style: TextStyle(
                              //             color: Constants.capPurple,
                              //             fontSize: 13,
                              //             // fontWeight: FontWeight.bold
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //     Icon(Icons.arrow_forward , size: screenWidth!*0.025,),
                              //     Container(
                              //       child: ConstrainedBox(
                              //         constraints: BoxConstraints(
                              //           minWidth: width!*0.1,
                              //           maxWidth: width!*0.4,),
                              //
                              //         child: AutoSizeText('$deliverZone',
                              //           maxLines: 2,
                              //           style: TextStyle(
                              //             color: Constants.capDarkPink,
                              //             fontSize: 13,
                              //             // fontWeight: FontWeight.bold
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //
                              //   ],
                              // ),

                              totalPayment > 0
                                  ? Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Cash on delivery'.tr(),
                                            style: TextStyle(
                                                fontSize: screenWidth! * 0.025),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          totalPayment.toString(),
                                          style: TextStyle(
                                              fontSize: screenWidth! * 0.03),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          'SR'.tr(),
                                          style: TextStyle(
                                              fontSize: screenWidth! * 0.03),
                                        )
                                      ],
                                    )
                                  : Container(),
                              totalPayment == -111111
                                  ? Row(
                                      children: [
                                        Text(
                                          'Error in getting cod value please refresh'
                                              .tr(),
                                          style: TextStyle(fontSize: 9),
                                        ),
                                      ],
                                    )
                                  : Container(),

                              widget.shortActions!
                                  ? FlatButton(
                                      padding: EdgeInsets.all(0),
                                      // minWidth: screenWidth! * 0.2,
                                      height: 15,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      color: Constants.redColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Dispatch Issue'.tr(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                                titlePadding: EdgeInsets.all(0),
                                                title: Container(
                                                  height: 60.00,
                                                  width: 300.00,
                                                  decoration: BoxDecoration(
                                                    color: Constants.blueColor,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                                                  ),
                                                    child: Center(
                                                      child: Text('Dispatch Issue'.tr(),
                                                          style: TextStyle(color: Colors.white)),
                                                    )
                                                ),

                                                content: Container(
                                                  width: 300.0,
                                                  height: 100,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Center(
                                                            child: Text(
                                                              'Dispatch Issue'.tr(),
                                                              maxLines: 2,
                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          EasyLocalization.of(
                                                                          context)!
                                                                      .locale ==
                                                                  Locale('en')
                                                              ? Text(
                                                                  '${widget.ordersDataModel?.id} ?',
                                                                  maxLines: 2,
                                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                                )
                                                              : Text(
                                                                  '${widget.ordersDataModel?.id} ؟ ',
                                                                  maxLines: 2,
                                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                                ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 20,),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20),
                                                          color: Constants.redColor
                                                        ),
                                                        child: GestureDetector(
                                                          onTap: (){
                                                            pickupActionsBloc!.add(
                                                                DispatchIssueShipment(
                                                                    id: widget.ordersDataModel?.id ?? ""));
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text('Submit'.tr(), style: TextStyle(color: Colors.white),),
                                                        ),
                                                      )
                                                    ],
                                                  ),

                                                ),
                                              );
                                            });
                                      })
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            width: 30,
                            height: 30,
                            child: Center(
                              child: CustomLoading(),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // widget.ordersDataModel!.status == '4' ?
                            // Row(
                            //   children: [
                            //     Text(shipmentStatus??'', style: TextStyle(color: Constants.capOrange , fontSize: screenWidth!*0.04),),
                            //     SizedBox(width: 5,),
                            //     Container(
                            //       width: 10,
                            //       height: 10,
                            //       decoration: BoxDecoration(
                            //         color: Constants.capOrange,
                            //         shape: BoxShape.circle,
                            //       ),
                            //     )
                            //   ],
                            // ) :
                            // Row(
                            //   children: [
                            //     Text(shipmentStatus??'', style: TextStyle(color: Constants.capGreen , fontSize: screenWidth!*0.04),),
                            //     SizedBox(width: 5,),
                            //     Container(
                            //       width: 15,
                            //       height: 15,
                            //       decoration: BoxDecoration(
                            //         color: Constants.capGreen,
                            //         shape: BoxShape.circle,
                            //       ),
                            //     )
                            //   ],
                            // ),
                            widget.longActions!
                                ? PopupMenuButton<CaptainPickUpActions>(
                                    onSelected: (CaptainPickUpActions result) {
                                      setState(() {
                                        _selection = result;
                                      });
                                      // Navigator.pop(context);
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<CaptainPickUpActions>>[
                                      PopupMenuItem<CaptainPickUpActions>(
                                        value: CaptainPickUpActions.deliver,
                                        child: MaterialButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // if((totalPayment ?? 0) > 0 ){
                                            //   Navigator.of(context).push(
                                            //     PageRouteBuilder(
                                            //       opaque: false, // set to false
                                            //       pageBuilder: (_, __, ___) => DeliverScreen(
                                            //         resourcesData: widget.resourcesData,
                                            //         ordersDataModel: widget.ordersDataModel,
                                            //         payment: totalPayment,
                                            //         myPickupBloc: widget.myPickupBloc,
                                            //       ),
                                            //     ),
                                            //   );
                                            // }
                                            // else{
                                            //   bool confirmed = false ;
                                            //   showDialog(
                                            //       context: context,
                                            //       builder: (context) {
                                            //         return StatefulBuilder(
                                            //             builder: (context , setState2){
                                            //               return AlertDialog(
                                            //                 shape: RoundedRectangleBorder(
                                            //                     borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                            //                 titlePadding: EdgeInsets.all(0),
                                            //                 title: Container(
                                            //                     height: 60.00,
                                            //                     width: 300.00,
                                            //                     decoration: BoxDecoration(
                                            //                       color: Constants.blueColor,
                                            //                       borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                                            //                     ),
                                            //                     child: Center(
                                            //                       child: Text('Deliver'.tr(),
                                            //                           style: TextStyle(color: Colors.white)),
                                            //                     )
                                            //                 ),
                                            //                 content: Container(
                                            //                   width: 300.0,
                                            //                   height: 200,
                                            //                   child: Column(
                                            //                     crossAxisAlignment: CrossAxisAlignment.center,
                                            //                     mainAxisAlignment: MainAxisAlignment.center,
                                            //                     children: [
                                            //                       Row(
                                            //                         crossAxisAlignment: CrossAxisAlignment.center,
                                            //                         mainAxisAlignment: MainAxisAlignment.center,
                                            //                         children: [
                                            //                           Text(
                                            //                             'Deliver'.tr(),
                                            //                             maxLines: 2,
                                            //                             style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                            //                           ),
                                            //                           SizedBox(
                                            //                             width: 5,
                                            //                           ),
                                            //                           EasyLocalization.of(
                                            //                               context)!
                                            //                               .locale ==
                                            //                               Locale(
                                            //                                   'en')
                                            //                               ? Text(
                                            //                             '${widget.ordersDataModel?.id} ?',
                                            //                             maxLines: 2,
                                            //                             style: TextStyle(fontWeight: FontWeight.w600),
                                            //                           )
                                            //                               : Text(
                                            //                             '${widget.ordersDataModel?.id} ؟ ',
                                            //                             maxLines: 2,
                                            //                             style: TextStyle(fontWeight: FontWeight.w600),
                                            //                           ),
                                            //                         ],
                                            //                       ),
                                            //                       confirmed ? Padding(
                                            //                         padding: const EdgeInsets.all(18.0),
                                            //                         child: Text("Are you sure ?".tr() , style: TextStyle(fontSize: 22),),
                                            //                       ) : Container(),
                                            //                       Row(
                                            //                         crossAxisAlignment: CrossAxisAlignment.center,
                                            //                         mainAxisAlignment: MainAxisAlignment.center,
                                            //                         children: [
                                            //                           confirmed ? Container() :
                                            //                           Padding(
                                            //                             padding: const EdgeInsets.all(20),
                                            //                             child: Container(
                                            //                               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            //                               decoration: BoxDecoration(
                                            //                                   borderRadius: BorderRadius.circular(15),
                                            //                                   color: Constants.redColor
                                            //                               ),
                                            //                               child: TextButton(
                                            //                                 child: Text(
                                            //                                     'submit'.tr(), style: TextStyle(color: Colors.white),),
                                            //                                 onPressed: () {
                                            //                                   setState2(() {
                                            //                                     confirmed = true ;
                                            //                                   });
                                            //                                 },
                                            //                               ),
                                            //                             ),
                                            //                           ),
                                            //                           confirmed ?
                                            //                           Padding(
                                            //                             padding: const EdgeInsets.symmetric(horizontal: 5),                                                                        child: Container(
                                            //                               decoration: BoxDecoration(
                                            //                                   borderRadius: BorderRadius.circular(15),
                                            //                                   color: Constants.redColor
                                            //                               ),
                                            //                               child: TextButton(
                                            //                                 child: Text(
                                            //                                   'Cancel'.tr() , style: TextStyle(color: Colors.white),),
                                            //                                 onPressed: () {
                                            //                                   Navigator.pop(context);
                                            //                                 },
                                            //                               ),
                                            //                             ),
                                            //                           ): Container(),
                                            //                           confirmed ?
                                            //                           Padding(
                                            //                             padding: const EdgeInsets.symmetric(horizontal: 5),
                                            //                             child: Container(
                                            //                               decoration: BoxDecoration(
                                            //                                   borderRadius: BorderRadius.circular(15),
                                            //                                   color: Constants.blueColor
                                            //                               ),
                                            //                               child: TextButton(
                                            //                                 child: Text(
                                            //                                     'Yes'.tr(), style: TextStyle(color: Colors.white),),
                                            //                                 onPressed: () {
                                            //                                   pickupActionsBloc?.add(
                                            //                                       DeliverShipment(
                                            //                                         id: widget.ordersDataModel?.id,));
                                            //                                   Navigator.pop(context);
                                            //
                                            //                                 },
                                            //                               ),
                                            //                             ),
                                            //                           ): Container(),
                                            //
                                            //                         ],
                                            //                       )
                                            //
                                            //                     ],
                                            //                   ),
                                            //                 ),
                                            //               );
                                            //             });
                                            //
                                            //       });
                                            // }
                                            //                                  // bool confirmed = false ;

                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                opaque: false, // set to false
                                                pageBuilder: (_, __, ___) => DeliverScreen(
                                                  resourcesData: widget.resourcesData,
                                                  ordersDataModel: widget.ordersDataModel,
                                                  payment: totalPayment,
                                                  myPickupBloc: widget.myPickupBloc,
                                                ),
                                              ),
                                            );

                                          },
                                          child: Text('Deliver'.tr()),
                                        ),
                                      ),
                                      PopupMenuItem<CaptainPickUpActions>(
                                        value: CaptainPickUpActions.cancel,
                                        child: MaterialButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            bool confirmed = false ;

                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder:
                                                        (context, setState2) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                                        titlePadding: EdgeInsets.all(0),
                                                        title: Container(
                                                            height: 60.00,
                                                            width: 300.00,
                                                            decoration: BoxDecoration(
                                                              color: Constants.blueColor,
                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                                                            ),
                                                            child: Center(
                                                              child: Text('Cancel'.tr(),
                                                                  style: TextStyle(color: Colors.white)),
                                                            )
                                                        ),
                                                        content: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [

                                                                    Text(
                                                                        '${widget.ordersDataModel?.id}',
                                                                        maxLines: 2,
                                                                        style: TextStyle(fontWeight: FontWeight.bold , fontSize: 26),
                                                                      )

                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,

                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    decoration:BoxDecoration(
                                                                      border: Border.all(color: Constants.blueColor),
                                                                      borderRadius: BorderRadius.circular(8)
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(3.0),
                                                                      child: DropdownButtonHideUnderline(
                                                                        child: DropdownButton<
                                                                            Cancellation>(
                                                                          items: widget.resourcesData?.cancellation?.map((Cancellation
                                                                                  dropDownStringItem) {
                                                                            return DropdownMenuItem<
                                                                                Cancellation>(
                                                                              value:
                                                                              dropDownStringItem,
                                                                              child:
                                                                                  Text(
                                                                                dropDownStringItem.name ?? "",
                                                                                style:
                                                                                    TextStyle(color: Colors.black, fontSize: 15),
                                                                              ),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged:
                                                                              (Cancellation?
                                                                                  newValue) {
                                                                            setState2(
                                                                                () {
                                                                              cancelIdSelected =
                                                                                  newValue;
                                                                            });
                                                                          },
                                                                          value:
                                                                              cancelIdSelected,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            confirmed ? Padding(
                                                              padding: const EdgeInsets.all(18.0),
                                                              child: Text("Are you sure ?".tr() , style: TextStyle(fontSize: 22),),
                                                            ) : Container(),
                                                            Row(

                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                confirmed ? Container() :

                                                                Padding(
                                                                  padding: const EdgeInsets.all(20),
                                                                  child: Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        color: Constants.redColor
                                                                    ),
                                                                    child: GestureDetector(
                                                                      onTap: (){
                                                                        setState2(() {
                                                                          confirmed = true ;
                                                                        });
                                                                      },
                                                                      child: Text('Submit'.tr(), style: TextStyle(color: Colors.white),),
                                                                    ),
                                                                  ),
                                                                ),

                                                                confirmed ?
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                  child: Container(
                                                                    // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        color: Constants.redColor
                                                                    ),
                                                                    child: TextButton(

                                                                      child: Text(
                                                                        'Cancel'.tr() , style: TextStyle(color: Colors.white),),
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                    ),
                                                                  ),
                                                                ): Container(),

                                                                confirmed ?
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                  child: Container(
                                                                    // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        color: Constants.blueColor
                                                                    ),
                                                                    child: TextButton(
                                                                      child: Text(
                                                                          'Yes'.tr(), style: TextStyle(color: Colors.white),),
                                                                      onPressed: () {
                                                                        pickupActionsBloc!.add(
                                                                            CancelShipment(
                                                                                shipment: widget.ordersDataModel!,
                                                                                cancelId: cancelIdSelected?.id));
                                                                        Navigator.pop(context);

                                                                      },
                                                                    ),
                                                                  ),
                                                                ): Container(),

                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                });
                                          },
                                          child: Text('Cancel'.tr()),
                                        ),
                                      ),
                                      PopupMenuItem<CaptainPickUpActions>(
                                        value: CaptainPickUpActions.postpone,
                                        child: MaterialButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            bool confirmed = false ;
                                            bool showDatePicker = false;

                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder: (context, setState2) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                                        titlePadding: EdgeInsets.all(0),
                                                        title:  Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                                width: 300.00,
                                                                decoration: BoxDecoration(
                                                                  color: Constants.blueColor,
                                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Center(
                                                                    child: Text('Postpone'.tr(),
                                                                        style: TextStyle(color: Colors.white , fontSize: 22 , fontWeight: FontWeight.bold)),
                                                                  ),
                                                                )
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(15.0),
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    'Postpone'
                                                                        .tr(),
                                                                    style: TextStyle( fontSize: 18, fontWeight: FontWeight.w600),
                                                                    maxLines: 2,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  EasyLocalization.of(context)!
                                                                      .locale ==
                                                                      Locale(
                                                                          'en')
                                                                      ? Text(
                                                                      widget.ordersDataModel?.id ?? "",
                                                                      maxLines: 2,
                                                                      style: TextStyle(fontWeight: FontWeight.w600 ,fontSize: 18)
                                                                  )
                                                                      : Text(
                                                                      widget.ordersDataModel?.id ?? "",
                                                                      maxLines:  2,
                                                                      style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 18)
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    DropdownButtonHideUnderline(
                                                                      child: DropdownButton<
                                                                          Cancellation>(
                                                                        items: widget.resourcesData?.postpone?.map((Cancellation dropDownStringItem) {
                                                                          return DropdownMenuItem<Cancellation>(
                                                                            value: dropDownStringItem,
                                                                            child: Text(
                                                                              dropDownStringItem.name ?? "",
                                                                              style: TextStyle(color: Colors.black, fontSize: 15),
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (Cancellation? newValue) {
                                                                          setState2(() {
                                                                            postponeIdSelected = newValue;
                                                                            if (postponeIdSelected!.id == "7" || postponeIdSelected!.id == "8") {
                                                                              showDatePicker = true;
                                                                            } else {
                                                                              showDatePicker = false;
                                                                            }
                                                                          });
                                                                        },
                                                                        value:
                                                                        postponeIdSelected,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                showDatePicker
                                                                    ?
                                                                DateTimeFormField(
                                                                  decoration: kTextFieldDecoration.copyWith(
                                                                    hintText: 'Pickup time'.tr(),
                                                                    suffixIcon: Icon(Icons.event_note, color: Constants.blueColor,),

                                                                  ),
                                                                  mode: DateTimeFieldPickerMode.dateAndTime,
                                                                  dateFormat:DateFormat('yyyy-MM-dd hh:mm aaa') ,
                                                                  onDateSelected: (DateTime value) {
                                                                    pickupTime = value ;
                                                                  },
                                                                  onSaved: (value) {
                                                                    pickupTime = value ?? DateTime.now() ;
                                                                  },
                                                                )

                                                                    : Container()
                                                              ],
                                                            ),
                                                            confirmed ? Padding(
                                                              padding: const EdgeInsets.all(18.0),
                                                              child: Text("Are you sure ?".tr() , style: TextStyle(fontSize: 22),),
                                                            ) : Container(),
                                                            Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                confirmed ? Container() :
                                                                Padding(
                                                                  padding: const EdgeInsets.all(20),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        color: Constants.redColor
                                                                    ),
                                                                    child: TextButton(
                                                                      child: Text(
                                                                        'Submit'.tr(), style: TextStyle(color: Colors.white),),
                                                                      onPressed: () {
                                                                        setState2(() {
                                                                          confirmed = true ;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                confirmed ?
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 5 , vertical: 5),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        color: Constants.redColor
                                                                    ),
                                                                    child: TextButton(
                                                                      child: Text(
                                                                        'Cancel'.tr() , style: TextStyle(color: Colors.white),),
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                    ),
                                                                  ),
                                                                ): Container(),
                                                                confirmed ?
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 5 , vertical: 5),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(15),
                                                                        color: Constants.blueColor
                                                                    ),
                                                                    child: TextButton(
                                                                      child: Text(
                                                                        'Yes'.tr(),style: TextStyle(color: Colors.white),),
                                                                      onPressed: () {
                                                                        pickupActionsBloc!.add(PostponeShipment(
                                                                            shipment: widget.ordersDataModel!,
                                                                            date: pickupTime.toString(),
                                                                            reason:
                                                                            postponeIdSelected!
                                                                                .id));
                                                                        Navigator.pop(context);

                                                                      },
                                                                    ),
                                                                  ),
                                                                ): Container(),

                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        // content: Container(
                                                        //   width: 300.0,
                                                        //   // height: 200,
                                                        //   child: Column(
                                                        //     crossAxisAlignment: CrossAxisAlignment.center,
                                                        //     mainAxisAlignment: MainAxisAlignment.center,
                                                        //     children: [
                                                        //       Row(
                                                        //         crossAxisAlignment: CrossAxisAlignment.center,
                                                        //         mainAxisAlignment: MainAxisAlignment.center,
                                                        //         children: [
                                                        //           Text(
                                                        //             'Postpone'
                                                        //                 .tr(),
                                                        //             style: TextStyle( fontSize: 13, fontWeight: FontWeight.bold),
                                                        //             maxLines: 2,
                                                        //           ),
                                                        //           SizedBox(
                                                        //             width: 5,
                                                        //           ),
                                                        //           EasyLocalization.of(context)!
                                                        //                       .locale ==
                                                        //                   Locale(
                                                        //                       'en')
                                                        //               ? Text(
                                                        //                   widget.ordersDataModel?.id ?? "",
                                                        //                   maxLines: 2,
                                                        //                   style: TextStyle(fontWeight: FontWeight.w600)
                                                        //                 )
                                                        //               : Text(
                                                        //                  widget.ordersDataModel?.id ?? "",
                                                        //                   maxLines:  2,
                                                        //               style: TextStyle(fontWeight: FontWeight.w600)
                                                        //                 ),
                                                        //         ],
                                                        //       ),
                                                        //       Column(
                                                        //         children: [
                                                        //           Row(
                                                        //             crossAxisAlignment: CrossAxisAlignment.center,
                                                        //             mainAxisAlignment: MainAxisAlignment.center,
                                                        //             children: [
                                                        //               DropdownButtonHideUnderline(
                                                        //                   child: DropdownButton<
                                                        //                 Cancellation>(
                                                        //               items: widget.resourcesData?.postpone?.map((Cancellation dropDownStringItem) {
                                                        //                 return DropdownMenuItem<Cancellation>(
                                                        //                   value: dropDownStringItem,
                                                        //                   child: Text(
                                                        //                     dropDownStringItem.name ?? "",
                                                        //                     style: TextStyle(color: Colors.black, fontSize: 15),
                                                        //                   ),
                                                        //                 );
                                                        //               }).toList(),
                                                        //               onChanged:
                                                        //                   (Cancellation? newValue) {
                                                        //                 setState2(() {
                                                        //                   postponeIdSelected = newValue;
                                                        //                   if (postponeIdSelected!.id == "7" || postponeIdSelected!.id == "8") {
                                                        //                     showDatePicker = true;
                                                        //                   } else {
                                                        //                     showDatePicker = false;
                                                        //                   }
                                                        //                 });
                                                        //               },
                                                        //               value:
                                                        //                   postponeIdSelected,
                                                        //                   ),
                                                        //                 ),
                                                        //             ],
                                                        //           ),
                                                        //           showDatePicker
                                                        //               ?
                                                        //             TextButton(
                                                        //               onPressed: () {
                                                        //                 DatePicker.showDateTimePicker(context,
                                                        //                     showTitleActions: true,
                                                        //                     minTime: DateTime.now(),
                                                        //                     maxTime: DateTime(2023, 1, 1), onChanged: (date) {
                                                        //                       print('change $date');
                                                        //                       setState2(() {
                                                        //                         pickupTime = date ;
                                                        //
                                                        //                       });
                                                        //                     }, onConfirm: (date) {
                                                        //                       print('confirm $date');
                                                        //                       setState2(() {
                                                        //                         pickupTime = date;
                                                        //
                                                        //                       });
                                                        //
                                                        //                     }, currentTime: DateTime.now(), locale: EasyLocalization.of(context)!.currentLocale == Locale('en') ? LocaleType.en  :LocaleType.ar);
                                                        //               },
                                                        //               child: Row(
                                                        //                 crossAxisAlignment: CrossAxisAlignment.center,
                                                        //                 children: [
                                                        //                   Text("Date".tr(), style: TextStyle(fontSize: 15),),
                                                        //                   SizedBox(width: 10,),
                                                        //                   Text(pickupTime.day.toString() + " - " + pickupTime.month.toString() + " - " + pickupTime.year.toString() ),
                                                        //                   SizedBox(width:5),
                                                        //                   Text("Time".tr() , style: TextStyle(fontSize: 15),),
                                                        //                   SizedBox(width: 10),
                                                        //                   EasyLocalization.of(context)!.locale == Locale('en') ?
                                                        //                   Text(pickupTime.hour.toString() + " : " + pickupTime.minute.toString() ) :
                                                        //                   Text( pickupTime.minute.toString() + " : "  + pickupTime.hour.toString())
                                                        //                 ],
                                                        //               ))
                                                        //               : Container()
                                                        //         ],
                                                        //       ),
                                                        //       confirmed ? Padding(
                                                        //         padding: const EdgeInsets.all(18.0),
                                                        //         child: Text("Are you sure ?".tr() , style: TextStyle(fontSize: 22),),
                                                        //       ) : Container(),
                                                        //       Row(
                                                        //         crossAxisAlignment: CrossAxisAlignment.center,
                                                        //         mainAxisAlignment: MainAxisAlignment.center,
                                                        //         children: [
                                                        //           confirmed ? Container() :
                                                        //           Padding(
                                                        //             padding: const EdgeInsets.all(20),
                                                        //             child: Container(
                                                        //               decoration: BoxDecoration(
                                                        //                   borderRadius: BorderRadius.circular(10),
                                                        //                   color: Constants.redColor
                                                        //               ),
                                                        //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                        //               child: TextButton(
                                                        //                 child: Text(
                                                        //                     'Submit'.tr(), style: TextStyle(color: Colors.white),),
                                                        //                 onPressed: () {
                                                        //                   setState2(() {
                                                        //                     confirmed = true ;
                                                        //                   });
                                                        //                 },
                                                        //               ),
                                                        //             ),
                                                        //           ),
                                                        //           confirmed ?
                                                        //           Padding(
                                                        //             padding: const EdgeInsets.symmetric(horizontal: 5),
                                                        //             child: Container(
                                                        //               decoration: BoxDecoration(
                                                        //                   borderRadius: BorderRadius.circular(10),
                                                        //                   color: Constants.redColor
                                                        //               ),
                                                        //               child: TextButton(
                                                        //                 child: Text(
                                                        //                   'Cancel'.tr() , style: TextStyle(color: Colors.white),),
                                                        //                 onPressed: () {
                                                        //                   Navigator.pop(context);
                                                        //                 },
                                                        //               ),
                                                        //             ),
                                                        //           ): Container(),
                                                        //           confirmed ?
                                                        //           Padding(
                                                        //             padding: const EdgeInsets.symmetric(horizontal: 5),
                                                        //             child: Container(
                                                        //               decoration: BoxDecoration(
                                                        //                   borderRadius: BorderRadius.circular(15),
                                                        //                   color: Constants.blueColor
                                                        //               ),
                                                        //               child: TextButton(
                                                        //                 child: Text(
                                                        //                     'Yes'.tr(),style: TextStyle(color: Colors.white),),
                                                        //                 onPressed: () {
                                                        //                   pickupActionsBloc!.add(PostponeShipment(
                                                        //                       id: widget.ordersDataModel?.id,
                                                        //                       date: pickupTime.toString(),
                                                        //                       reason:
                                                        //                       postponeIdSelected!
                                                        //                           .id));
                                                        //                   Navigator.pop(context);
                                                        //
                                                        //                 },
                                                        //               ),
                                                        //             ),
                                                        //           ): Container(),
                                                        //
                                                        //         ],
                                                        //       )
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                        // actions: [
                                                        //   TextButton(
                                                        //     child:
                                                        //         Text('ok'.tr()),
                                                        //     onPressed: () {
                                                        //       pickupActionsBloc!.add(PostponeShipment(
                                                        //           id: widget.ordersDataModel?.id,
                                                        //           date: pickupTime.toString(),
                                                        //           reason:
                                                        //               postponeIdSelected!
                                                        //                   .id));
                                                        //       Navigator.pop(
                                                        //           context);
                                                        //     },
                                                        //   ),
                                                        // ],
                                                      );
                                                    },
                                                  );
                                                });
                                          },
                                          child: Text('Postpone'.tr()),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),

                            widget.longActions! ? IconButton(onPressed: (){
                             ComFunctions.launcWhatsappWithMsg(widget.ordersDataModel?.receiverPhone);
                            },icon: Icon(MdiIcons.whatsapp , size: 22, color: Colors.green,), ) : Container(),

                            widget.shortActions!
                                ? FlatButton(
                                    padding: EdgeInsets.all(0),
                                    minWidth: screenWidth! * 0.2,
                                    height: 30,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    color: Constants.blueColor,
                                    child: Text(
                                      'Store out'.tr(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth! * 0.035),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                              titlePadding: EdgeInsets.all(0),
                                              title: Container(
                                                  height: 60.00,
                                                  width: 300.00,
                                                  decoration: BoxDecoration(
                                                    color: Constants.blueColor,
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                                                  ),
                                                  child: Center(
                                                    child: Text('Dispatch Issue'.tr(),
                                                        style: TextStyle(color: Colors.white)),
                                                  )
                                              ),
                                              content: Container(
                                                width: 300.0,
                                                height: 100,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          'Store out'.tr(), style: TextStyle(fontWeight: FontWeight.bold),
                                                          maxLines: 2,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        EasyLocalization.of(context)!
                                                                    .locale ==
                                                                Locale('en')
                                                            ? Text(
                                                                widget.ordersDataModel?.id ?? "",
                                                                maxLines: 2,
                                                          style: TextStyle(fontWeight: FontWeight.w600),

                                                        )
                                                            : Text(
                                                                widget.ordersDataModel?.id ?? "",
                                                                maxLines: 2,
                                                          style: TextStyle(fontWeight: FontWeight.w600),

                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 20,),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20),
                                                          color: Constants.redColor
                                                      ),
                                                      child: GestureDetector(
                                                        onTap: (){
                                                          pickupActionsBloc!.add(
                                                              StoreOutShipment(
                                                                  id: widget.ordersDataModel?.id));
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text('Submit'.tr(), style: TextStyle(color: Colors.white),),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),


                                            );
                                          });
                                    })
                                : Container(),


                            widget.reActive
                                ? widget.ordersDataModel?.trackType.toString() == "14" ||
                                widget.ordersDataModel?.trackType.toString() == "17" ?
                                FlatButton(
                                padding: EdgeInsets.all(0),
                                minWidth: screenWidth! * 0.2,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8)),
                                color: Constants.blueColor,
                                child: Text(
                                  'Ready to deliver'.tr(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth! * 0.035),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                          titlePadding: EdgeInsets.all(0),
                                          title: Container(
                                              height: 60.00,
                                              width: 300.00,
                                              decoration: BoxDecoration(
                                                color: Constants.blueColor,
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                                              ),
                                              child: Center(
                                                child: Text('Ready to deliver'.tr(),
                                                    style: TextStyle(color: Colors.white)),
                                              )
                                          ),
                                          content: Container(
                                            width: 300.0,
                                            height: 100,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Ready to deliver'.tr(), style: TextStyle(fontWeight: FontWeight.bold),
                                                      maxLines: 2,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    EasyLocalization.of(context)!
                                                        .locale ==
                                                        Locale('en')
                                                        ? Text(
                                                      widget.ordersDataModel?.id ?? "",
                                                      maxLines: 2,
                                                      style: TextStyle(fontWeight: FontWeight.w600),

                                                    )
                                                        : Text(
                                                      widget.ordersDataModel?.id ?? "",
                                                      maxLines: 2,
                                                      style: TextStyle(fontWeight: FontWeight.w600),

                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20,),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      color: Constants.redColor
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      pickupActionsBloc!.add(
                                                          ReActiveShipment(
                                                              shipment: widget.ordersDataModel ?? OrdersDataModelMix()));
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Submit'.tr(), style: TextStyle(color: Colors.white),),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),


                                        );
                                      });
                                })
                                : SizedBox() : SizedBox() ,
                            widget.ordersDataModel?.statusDownload ==
                                    DownloadTaskStatus.complete
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          MdiIcons.filePdfBox,
                                          color: Constants.capOrange,
                                        ),
                                        onPressed: () {
                                          FlutterDownloader.open(
                                              taskId: widget.ordersDataModel?.taskId ?? "");
                                        },
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: null,
      // actions: widget.ordersDataModel?.statusDownload ==
      //         DownloadTaskStatus.complete
      //     ? null
      //     : <Widget>[
      //         IconSlideAction(
      //           caption: 'Print'.tr(),
      //           color: Colors.deepOrange,
      //           icon: Icons.print,
      //           onTap: () {
      //             if (Platform.isAndroid) {
      //             } else {
      //             }
      //           },
      //         ),
      //       ],
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }

  void _showToast(
      {required BuildContext context, required String msg, Color? color}) {
    final scaffold = Scaffold.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(msg),
      backgroundColor: color,
    ));
  }
}
