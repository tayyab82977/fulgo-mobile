import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/captain_orders_controller.dart';
import 'package:Fulgox/controllers/reserve_client_controller.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/courier/bulkPickupScreen.dart';
import 'package:Fulgox/ui/courier/captainDashboard.dart';
import 'package:Fulgox/ui/courier/captainOrdersList.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/dialogs/pickup_dialog.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/utilities/downloader.dart';
import 'package:Fulgox/utilities/idToNameFunction.dart';

import '../common/dashboard.dart';
import 'custom_loading.dart';

class NamesAndOrdersCard extends StatefulWidget {
  bool? print;
  ResourcesData? resourcesData;
  CaptainOrdersController? captainOrdersController;
  List<OrdersDataModelMix>? capOrdersList;
  bool? permEmpty;
  bool? hasAction;
  bool? reserved;
  ProfileDataModel? dashboardDataModel;
  OrdersDataModelMix? ordersDataModel;
  // List<List<CapOrdersDataModel>> mainList ;
  int? index;

  NamesAndOrdersCard(
      {this.capOrdersList,
      this.permEmpty,
      this.resourcesData,
      this.reserved,
      this.index,
      this.captainOrdersController,
      this.hasAction,
      this.print,
      this.dashboardDataModel,
      this.ordersDataModel});

  @override
  _NamesAndOrdersCardState createState() => _NamesAndOrdersCardState();
}

class _NamesAndOrdersCardState extends State<NamesAndOrdersCard> {
  UserRepository userRepository = UserRepository();
  double? screenWidth, screenHeight;
  String? token;
  int progress = 0;
  DownloadTaskStatus? status;
  bool isAsync = false;
  int? timeH;
  String? dateDays;
  String? dateMonth;
  String? dateYear;
  String? timeM;
  String? zoneName;
  String? AMPM;

  final ReserveClientController _reserveClientController = Get.put(ReserveClientController());

  gettingDate() {
    dateDays = widget.capOrdersList?.first.stamp.toString().substring(8, 10);
    dateMonth = widget.capOrdersList?.first.stamp.toString().substring(5, 7);
    dateYear = widget.capOrdersList?.first.stamp.toString().substring(0, 4);
    timeM = widget.capOrdersList?.first.stamp.toString().substring(14, 16);
    timeH = int.parse(
        widget.capOrdersList?.first.stamp.toString().substring(11, 13) ?? "12");

    if ((timeH ?? 1) > 12) {
      timeH = (timeH ?? 1) - 12;
      AMPM = "PM".tr();
    } else if (timeH == 12) {
      AMPM = "PM".tr();
    } else if (timeH == 0) {
      timeH = (timeH ?? 1) + 12;
      AMPM = "AM".tr();
    } else {
      AMPM = 'AM'.tr();
    }
  }

  Future<String> _findLocalPath() async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  late String _localPath;

  Cancellation? cancelIdSelected = Cancellation();

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('File Downloaded'.tr()),
          backgroundColor: Colors.green,
        ));
        Future.delayed(Duration(seconds: 1), () {
          FlutterDownloader.open(taskId: id!);
        });
      }
    });
  }

  void _handleTabSelection() {
    print('Rebuild');
    setState(() {});
  }

  idToName() {
    if (widget.capOrdersList?.first.pickupNeighborhood != null) {
      zoneName = IdToName.idToName(
          'zone', widget.capOrdersList!.first.pickupNeighborhood!.toString());
    }
    cancelIdSelected = widget.resourcesData?.postpone?.first;
  }

  ReceivePort _port = ReceivePort();

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  void initState() {
    try {
      gettingDate();
      FlutterDownloader.registerCallback(Downloader.downloadCallback);
      idToName();
    } catch (e) {
    }

    _bindBackgroundIsolate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return Obx(() {
      if (_reserveClientController.reserveSuccess.value) {
          _reserveClientController.reserveSuccess.value = false;
          _onWidgetDidBuild(context, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully Reserved'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            widget.captainOrdersController?.fetchCaptainOrders();
          });
      }

      if (_reserveClientController.cancelSuccess.value) {
          _reserveClientController.cancelSuccess.value = false;
          _onWidgetDidBuild(context, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Canceled successfully'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            widget.captainOrdersController?.fetchCaptainOrders();
          });
      }

      if (_reserveClientController.recordPickupIssueSuccess.value) {
          _reserveClientController.recordPickupIssueSuccess.value = false;
          _onWidgetDidBuild(context, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pickup issue recorded successfully'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            widget.captainOrdersController?.fetchCaptainOrders();
          });
      }

      if (_reserveClientController.errorMessage.value != '') {
          String error = _reserveClientController.errorMessage.value;
          _reserveClientController.errorMessage.value = '';
          
          if (error == 'needUpdate') {
            GeneralHandler.handleNeedUpdateState(context);
          } else if (error == "invalidToken") {
            GeneralHandler.handleInvalidToken(context);
          } else if (error == "general") {
            GeneralHandler.handleGeneralError(context);
          } else if (error == "TIMEOUT") {
             GeneralHandler.handleNetworkError(context);
          }

          _onWidgetDidBuild(context, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Container(
                  width: screenWidth,
                  height: screenHeight! * 0.1,
                  child: ListView.builder(
                    itemCount: _reserveClientController.errorsList.length,
                    itemBuilder: (context, i) {
                      return Text(_reserveClientController.errorsList[i].toString());
                    },
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          });
      }

      return CreateNamesAndOrderCard(
          loading: _reserveClientController.loadingId.value == widget.capOrdersList?.first.member);
    });
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      callback();
    });
  }

  Widget CreateNamesAndOrderCard(
      {required bool loading}) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
        child: GestureDetector(
          onTap: () {
            if (widget.reserved!) {
              PickupDialog.showPickupDialog(
                context: context,
                capOrderList: widget.capOrdersList ?? [],
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth! * 0.4,
                            child: AutoSizeText(
                              '${widget.capOrdersList?[0].memberName}',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text('${widget.capOrdersList?.length}'),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Shipments'.tr())
                            ],
                          ),
                          Container(
                              width: screenWidth! * 0.4,
                              child: AutoSizeText(zoneName ?? '')),
                          Row(
                            children: [
                              Container(
                                height: 30,
                                child: IconButton(
                                  icon: Icon(Icons.call),
                                  color: Constants.blueColor,
                                  onPressed: () {
                                    ComFunctions.launcPhone(widget
                                        .capOrdersList?.first.senderPhone);
                                  },
                                ),
                              ),
                              Container(
                                height: 30,
                                child: IconButton(
                                  icon: Icon(MdiIcons.whatsapp),
                                  color: Colors.green,
                                  onPressed: () {
                                    ComFunctions.launcWhatsapp(widget
                                        .capOrdersList?.first.senderPhone);
                                  },
                                ),
                              ),
                              widget.capOrdersList?.first.pickupMap != null &&
                                      widget.capOrdersList?.first.pickupMap !=
                                          ""
                                  ? Container(
                                      height: 30,
                                      child: IconButton(
                                        icon: Icon(Icons.location_on),
                                        color: Colors.red,
                                        onPressed: () {
                                          ComFunctions.launchURL(widget
                                                  .capOrdersList
                                                  ?.first
                                                  .pickupMap ??
                                              "");
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          )
                        ],
                      ),
                      loading
                          ? Container(
                              width: 30,
                              height: 30,
                              child: Center(child: CustomLoading()),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$dateDays/$dateMonth/$dateYear',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('$timeH:$timeM $AMPM',
                                        style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    widget.print!
                                        ? isAsync
                                            ? Container(
                                                width: 30,
                                                height: 30,
                                                child: Center(
                                                    child: CustomLoading()),
                                              )
                                            : Container(
                                                height: 30,
                                                padding: EdgeInsets.all(0),
                                                child: GestureDetector(
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
                                                                    "Print"
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  CustomButton(
                                                                      height:
                                                                          40,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10)),
                                                                      color: Constants
                                                                          .capPurple,
                                                                      child:
                                                                          Text(
                                                                        '4*4'
                                                                            .tr(),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 11),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);

                                                                        if (Platform
                                                                            .isAndroid) {
                                                                          Downloader.downloadPDFAndroid2(
                                                                              widget.ordersDataModel?.taskId,
                                                                              "${EventsAPIs.url}files/${widget.capOrdersList?.first.member}/member",
                                                                              widget.capOrdersList?.first.senderName ?? "");
                                                                        } else {
                                                                          Downloader.downloadPDFIOS2(
                                                                              widget.ordersDataModel?.taskId,
                                                                              "${EventsAPIs.url}files/${widget.capOrdersList?.first.member}/member",
                                                                              widget.capOrdersList?.first.senderName ?? "");
                                                                        }
                                                                      }),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  CustomButton(
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
                                                                        Navigator.of(
                                                                            context);
                                                                        if (Platform
                                                                            .isAndroid) {
                                                                          Downloader.downloadPDFAndroid2(
                                                                              widget.ordersDataModel?.taskId,
                                                                              "https://portal.Fulgox.com/print_membervise/${widget.capOrdersList?.first.member}",
                                                                              widget.capOrdersList?.first.senderName ?? "");
                                                                        } else {
                                                                          Downloader.downloadPDFIOS2(
                                                                              widget.ordersDataModel?.taskId,
                                                                              "https://portal.Fulgox.com/print_membervise/${widget.capOrdersList?.first.member}",
                                                                              widget.capOrdersList?.first.senderName ?? "");
                                                                        }

                                                                        // ComFunctions.launchURL("https://portal.Fulgox.com/print_membervise/${widget.capOrdersList!.first.member}");
                                                                      }),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  CustomButton(
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
                                                                        if (Platform
                                                                            .isAndroid) {
                                                                          Downloader.downloadPDFAndroid2(
                                                                              widget.ordersDataModel?.taskId,
                                                                              "https://portal.Fulgox.com/print_membervise2/${widget.capOrdersList?.first.member}",
                                                                              widget.capOrdersList?.first.senderName ?? "");
                                                                        } else {
                                                                          Downloader.downloadPDFIOS2(
                                                                              widget.ordersDataModel?.taskId,
                                                                              "https://portal.Fulgox.com/print_membervise2/${widget.capOrdersList?.first.member}",
                                                                              widget.capOrdersList?.first.senderName ?? "");
                                                                        }
                                                                        // ComFunctions.launchURL("https://portal.Fulgox.com/print_membervise2/${widget.capOrdersList!.first.member}");
                                                                      }),
                                                                ],
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: Image.asset(
                                                        'assets/images/pdf.png')),
                                              )
                                        : Container(),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    widget.permEmpty == null
                                        ? widget.hasAction!
                                            ? CustomButton(
                                                onPressed: () {
                                                   _reserveClientController.reserveClient(widget.capOrdersList?[0].member);
                                                },
                                                padding: EdgeInsets.all(0),
                                                minWidth: screenWidth! * 0.25,
                                                height: 40,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                color: Constants.redColor,
                                                child: Text(
                                                  'Reserve'.tr(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ))
                                            : CustomButton(
                                                padding: EdgeInsets.all(0),
                                                minWidth: screenWidth! * 0.1,
                                                height: 30,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Image.asset(
                                                  'assets/images/recycle_bin.png',
                                                  height: 30,
                                                  // color: Constants.capOrange,
                                                ),
                                                onPressed: () {
                                                  bool confirmed = false;
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                          builder: (context,
                                                              setState2) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              32.0))),
                                                              titlePadding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              title: Container(
                                                                  height: 60.00,
                                                                  width: 300.00,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Constants
                                                                        .blueColor,
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                32),
                                                                        topRight:
                                                                            Radius.circular(32)),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                        'Cancel'
                                                                            .tr(),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white)),
                                                                  )),
                                                              content:
                                                                  Container(
                                                                width: 300.0,
                                                                height: 200,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Text(
                                                                                  "Can not pickup from ".tr(),
                                                                                  style: TextStyle(fontSize: 14),
                                                                                ),
                                                                                Flexible(
                                                                                    child: Text(
                                                                                  widget.capOrdersList?.first.senderName.toString() ?? "",
                                                                                  style: TextStyle(fontSize: 14),
                                                                                )),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              DropdownButtonHideUnderline(
                                                                            child:
                                                                                DropdownButton<Cancellation>(
                                                                              items: widget.resourcesData?.postpone?.map((Cancellation dropDownStringItem) {
                                                                                return DropdownMenuItem<Cancellation>(
                                                                                  value: dropDownStringItem,
                                                                                  child: Text(
                                                                                    dropDownStringItem.name ?? "",
                                                                                    style: TextStyle(color: Colors.black, fontSize: 15),
                                                                                  ),
                                                                                );
                                                                              }).toList(),
                                                                              onChanged: (Cancellation? newValue) {
                                                                                setState2(() {
                                                                                  cancelIdSelected = newValue;
                                                                                });
                                                                              },
                                                                              value: cancelIdSelected,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    confirmed
                                                                        ? Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(18.0),
                                                                            child:
                                                                                Text(
                                                                              "Are you sure ?".tr(),
                                                                              style: TextStyle(fontSize: 22),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                    Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        confirmed
                                                                            ? Container()
                                                                            : Padding(
                                                                                padding: const EdgeInsets.all(20),
                                                                                child: Container(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Constants.redColor),
                                                                                  child: GestureDetector(
                                                                                    onTap: () {
                                                                                      setState2(() {
                                                                                        confirmed = true;
                                                                                      });
                                                                                    },
                                                                                    child: Text(
                                                                                      'Submit'.tr(),
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                        confirmed
                                                                            ? Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Container(
                                                                                  // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Constants.redColor),
                                                                                  child: CustomButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text(
                                                                                      'Cancel'.tr(),
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ))
                                                                            : Container(),
                                                                        confirmed
                                                                            ? Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                child: Container(
                                                                                  // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Constants.blueColor),
                                                                                  child: CustomButton(
                                                                                    onPressed: () {
                                                                                      _reserveClientController.recordPickupIssue(widget.capOrdersList ?? [], cancelIdSelected?.id);
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text(
                                                                                      'Yes'.tr(),
                                                                                      style: TextStyle(color: Colors.white),
                                                                                    ),
                                                                                  ),
                                                                                ))
                                                                            : Container(),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      });
                                                })
                                        : Container(),
                                  ],
                                ),
                                widget.reserved!
                                    ? Row(
                                        children: [
                                          ButtonTheme(
                                            height: 40,
                                            minWidth: screenWidth! * 0.25,
                                            child: CustomButton(
                                                padding: EdgeInsets.all(0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                color: Constants.blueColor,
                                                child: Text(
                                                  'Pickup'.tr(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  PickupDialog.showPickupDialog(
                                                    context: context,
                                                    capOrderList:
                                                        widget.capOrdersList ??
                                                            [],
                                                  );
                                                }),
                                          ),
                                          // CustomButton(
                                          //     height: 40,
                                          //     minWidth: screenWidth! * 0.38,
                                          //     padding: EdgeInsets.all(0),
                                          //     shape: RoundedRectangleBorder(
                                          //         borderRadius:
                                          //         BorderRadius.circular(
                                          //             10)),
                                          //     color: Constants.capLightGreen,
                                          //     child: Text(
                                          //       'Bulk Pickup'.tr(),
                                          //       style: TextStyle(
                                          //           color: Colors.white,
                                          //           fontSize: 12),
                                          //     ),
                                          //     onPressed: () {
                                          //       Navigator.push(
                                          //           context,
                                          //           MaterialPageRoute(
                                          //               builder: (context) =>
                                          //                   BulkPickUpScreen(
                                          //                     resourcesData: widget
                                          //                         .resourcesData,
                                          //                     acceptedOrder: widget
                                          //                         .capOrdersList,
                                          //                   )));
                                          //     }),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
