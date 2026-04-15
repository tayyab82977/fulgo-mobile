import 'package:auto_size_text/auto_size_text.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:get/get.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/controllers/checkin_controller.dart';
import 'package:Fulgox/controllers/my_reserves_controller.dart';
import 'package:Fulgox/controllers/bulk_pickup_controller.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/paymentReport.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/courier/captainDashboard.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/custom%20widgets/captainOrdersCard.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/custom%20widgets/customCheckBox.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'dart:ui' as ui;
import 'package:Fulgox/ui/dialogs/clintBalanceDialog.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/dialogs/pickupReportDialog.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import '../custom widgets/CaptainAppBar.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import '../custom widgets/custom_loading.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import '../custom widgets/drawerCaptain.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

class CaptainOrdersListScreen extends StatefulWidget {
  MyReservesController? myReservesController;
  bool? reserved;
  ResourcesData? resourcesData;
  List<OrdersDataModelMix>? orderList;
  int? index;

  CaptainOrdersListScreen(
      {this.resourcesData,
      this.orderList,
      this.reserved,
      this.myReservesController,
      this.index});

  @override
  _CaptainOrdersListScreenState createState() =>
      _CaptainOrdersListScreenState();
}

class _CaptainOrdersListScreenState extends State<CaptainOrdersListScreen>
    with TickerProviderStateMixin {
  AuthController authController = Get.put(AuthController());

  List<OrdersDataModelMix> allOrdersList = [];
  List<OrdersDataModelMix> acceptedOrdersList = [];
  final _codeController = TextEditingController();

  CheckInController checkInController = Get.put(CheckInController());
  BulkPickupController bulkPickupController = Get.put(BulkPickupController());

  String receipt = "";

  List<OrdersDataModelMix> all2 = [];
  List<OrdersDataModelMix> all3 = [];
  List<OrdersDataModelMix> accepted2 = [];
  List<OrdersDataModelMix> accepted3 = [];
  PaymentMethod? _currentSelectedPaymentMethod;

  TextEditingController editingControllerAll = TextEditingController();
  TextEditingController editingControllerAccepted = TextEditingController();

  void filterSearchResults(String query, List<OrdersDataModelMix> list1,
      List<OrdersDataModelMix> list2) {
    List<OrdersDataModelMix> dummySearchList = [];
    dummySearchList.addAll(list2);
    if (query.isNotEmpty) {
      List<OrdersDataModelMix> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.id!.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        list1.clear();
        list1.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        list1.clear();
        list1.addAll(list2);
      });
    }
  }

  String? amountNew;

  TabController? _tabController;

  bool showReceipt = true;

  var _formKey = GlobalKey<FormState>();

  PaymentReport paymentReport = PaymentReport();

  double? screenWidth, screenHeight;
  List<CapOrdersDataModel>? confirmedOrdersList;

  double amount = 0;

  bool priceCalculated = false;
  bool showMsgButton = true;

  Future<bool> _willPopCallback() async {
    if (acceptedOrdersList.length > 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              titlePadding: EdgeInsets.all(0),
              title: Container(
                  height: 60.00,
                  width: 300.00,
                  decoration: BoxDecoration(
                    color: Constants.blueColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32)),
                  ),
                  child: Center(
                    child: Text('Back'.tr(),
                        style: TextStyle(color: Colors.white)),
                  )),
              content: Container(
                width: 300.0,
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Are you sure ?'.tr(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                        'If you pressed continue all your edits will be reset'
                            .tr(),
                        style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Constants.redColor),
                            child: CustomButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        CaptainDashboard(
                                      resourcesData: widget.resourcesData,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Text('Continue'.tr(),
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Constants.blueColor),
                            child: CustomButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel'.tr(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          });
    } else {
      Navigator.pop(context);
    }

    return true; // return true if the route to be popped
  }

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  String? clientGeneralCreditList;

  String? total = '0.0';
  String? suspectedPrice = '0.0';
  bool selectAll = false;

  @override
  void initState() {
    allOrdersList =
        widget.orderList!.where((element) => element.accepted == null).toList();
    acceptedOrdersList =
        widget.orderList!.where((element) => element.accepted == true).toList();
    all2 = allOrdersList.map((element) => element).toList();
    all3 = allOrdersList.map((element) => element).toList();
    accepted2 = acceptedOrdersList.map((element) => element).toList();
    accepted3 = acceptedOrdersList.map((element) => element).toList();
    _tabController =
        new TabController(vsync: this, length: 2, initialIndex: widget.index!);
    _tabController!.addListener(_handleTabSelection);
    try {
      widget.resourcesData?.paymentMethods?.forEach((e) {
        e.isSelected = false;
      });
      // _currentSelectedPaymentMethod = widget.resourcesData?.paymentMethods?.first ;
    } catch (e) {}

    ever(bulkPickupController.actionSuccess, (success) {
      if (success) {
        PickupReportDialog.showPickupReportDialog(
            bulkPickupController.pickupReport.value!, context, widget.resourcesData!);
      }
    });

    ever(bulkPickupController.msgSentSuccess, (success) {
      if (success) {
        setState(() {
          showMsgButton = false;
        });
        ComFunctions.showToast(
            text: "Successfully done".tr(), color: Colors.green);
      }
    });

    ever(bulkPickupController.calculations, (List<String>? calc) {
      if (calc != null && calc.isNotEmpty) {
        clientGeneralCreditList = calc.first;
      }
    });

    ever(bulkPickupController.receipt, (r) {
      if (r != null) {
        setState(() {
          receipt = r.toString();
        });
      }
    });

     ever(bulkPickupController.errorMessage, (error) {
      if (error.isNotEmpty) {
        if (error == 'needUpdate') {
          GeneralHandler.handleNeedUpdateState(context);
        } else if (error == "invalidToken") {
          GeneralHandler.handleInvalidToken(context);
        } else if (error == "general") {
          GeneralHandler.handleGeneralError(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Wrap(
              runAlignment: WrapAlignment.start,
              direction: Axis.vertical,
              children: [
                Text(
                  error.tr(),
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ));
        }
      }
    });

    super.initState();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print('from build function ${paymentReport.tote}');

    checkInController = Get.find<CheckInController>();
    Size size = MediaQuery.of(context).size;

    screenWidth = size.width;
    screenHeight = size.height;

    return widget.reserved!
        ? Obx(() {
            if (bulkPickupController.isLoading.value) {
              return Stack(
                children: [
                   CreatePickUpSceenTWO(
                      controller: bulkPickupController,
                      loading: true),
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: screenWidth,
                        height: screenHeight,
                        child: Center(
                          child: CustomLoading(),
                        ),
                      )),
                ],
              );
            }
            return CreatePickUpSceenTWO(
                controller: bulkPickupController);
          })
        : SafeArea(
            child: Scaffold(
              key: _drawerKey,
              drawer: CaptainDrawer(
                resourcesData: widget.resourcesData,
                width: screenWidth,
                height: screenHeight,
              ),
              body: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white])),
                child: Column(
                  children: [
                    CaptainAppBar(
                      drawerKey: _drawerKey,
                      screenName: 'Single Pickup'.tr(),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  '${widget.orderList![0].senderName}',
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 25),
                                ),
                              ),
                              // SizedBox(width: 10,),
                              // ButtonTheme(
                              //   minWidth: 78,
                              //   height: 40,
                              //   child: CustomButton(
                              //     padding: EdgeInsets.all(0),
                              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              //     onPressed: (){
                              //       Navigator.pop(context);
                              //     },
                              //     child: Container(
                              //       width: 78,
                              //       height: 40,
                              //       decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.circular(10),
                              //           border: Border.all(color: Colors.black)
                              //       ),
                              //       child:EasyLocalization.of(context)!.locale == Locale('en')?
                              //       Row(
                              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //         children: [
                              //           Icon(Icons.arrow_back, size: 15,),
                              //           Text('Back'.tr()),
                              //         ],
                              //       ) :
                              //       Row(
                              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //         children: [
                              //           Text('Back'.tr()),
                              //           Icon(Icons.arrow_forward, size: 15,),
                              //
                              //         ],
                              //       ) ,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth,
                            // height: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(25),
                                    topLeft: Radius.circular(25)),
                                color: Colors.white),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xffF9F9F9),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20))),
                                  child: ListView.builder(
                                    itemCount: allOrdersList.length,
                                    itemBuilder: (context, i) {
                                      return CapOrdersCard(
                                        ordersList: widget.orderList,
                                        resourcesData: widget.resourcesData,
                                        ordersDataModel: allOrdersList[i],
                                        reserved: widget.reserved,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget CreatePickUpSceenTWO(
      {BulkPickupController? controller,
      bool loading = false}) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: WillPopScope(
          onWillPop: _willPopCallback,
          child: Scaffold(
            key: _drawerKey,
            drawer: CaptainDrawer(
              resourcesData: widget.resourcesData,
              width: screenWidth,
              height: screenHeight,
            ),
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white])),
              child: Column(
                children: [
                  CaptainAppBar(
                    drawerKey: _drawerKey,
                    screenName: 'Single Pickup'.tr(),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller!.getClientBalances(widget.orderList![0].member);
                                },
                                child: AutoSizeText(
                                  '${widget.orderList![0].senderName}',
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 25),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            EasyLocalization.of(context)!.locale == Locale('en')
                                ? ButtonTheme(
                                    minWidth: 78,
                                    height: 40,
                                    child: CustomButton(
                                      padding: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () {
                                        if (acceptedOrdersList.length > 0) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  32.0))),
                                                  titlePadding:
                                                      EdgeInsets.all(0),
                                                  title: Container(
                                                      height: 60.00,
                                                      width: 300.00,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.blueColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        32),
                                                                topRight: Radius
                                                                    .circular(
                                                                        32)),
                                                      ),
                                                      child: Center(
                                                        child: Text('Back'.tr(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      )),
                                                  content: Container(
                                                    width: 300.0,
                                                    height: 200,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                          'Are you sure ?'.tr(),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                            'If you pressed continue all your edits will be reset'
                                                                .tr(),
                                                            style: TextStyle(
                                                                fontSize: 18)),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5),
                                                                child:
                                                                    Container(
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                                15),
                                                                            color: Constants
                                                                                .redColor),
                                                                        child:
                                                                            CustomButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pushAndRemoveUntil(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (BuildContext context) => CaptainDashboard(
                                                                                  resourcesData: widget.resourcesData,
                                                                                ),
                                                                              ),
                                                                              (route) => false,
                                                                            );
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'Continue'.tr(),
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                        ))),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    color: Constants
                                                                        .blueColor),
                                                                child:
                                                                    CustomButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                    'Cancel'
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        } else {
                                          Navigator.pop(context);
                                        }
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
                                              MainAxisAlignment.spaceEvenly,
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
                                    child: CustomButton(
                                      padding: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      onPressed: () {
                                        if (acceptedOrdersList.length > 0) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  32.0))),
                                                  titlePadding:
                                                      EdgeInsets.all(0),
                                                  title: Container(
                                                      height: 60.00,
                                                      width: 300.00,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Constants.blueColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        32),
                                                                topRight: Radius
                                                                    .circular(
                                                                        32)),
                                                      ),
                                                      child: Center(
                                                        child: Text('Back'.tr(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      )),
                                                  content: Container(
                                                    width: 300.0,
                                                    height: 240,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Text(
                                                          'Are you sure ?'.tr(),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        Text(
                                                            'If you pressed continue all your edits will be reset'
                                                                .tr(),
                                                            style: TextStyle(
                                                                fontSize: 18)),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    color: Constants
                                                                        .redColor),
                                                                child:
                                                                    CustomButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator
                                                                              .pushAndRemoveUntil(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (BuildContext context) => CaptainDashboard(
                                                                                resourcesData: widget.resourcesData,
                                                                              ),
                                                                            ),
                                                                            (route) =>
                                                                                false,
                                                                          );
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          'Continue'
                                                                              .tr(),
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        )),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    color: Constants
                                                                        .blueColor),
                                                                child:
                                                                    CustomButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                    'Cancel'
                                                                        .tr(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        width: 78,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: EasyLocalization.of(context)!
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
                                                    Icons.arrow_forward,
                                                    size: 15,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 62),
                          child: Container(
                            width: screenWidth,
                            // height: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(25),
                                    topLeft: Radius.circular(25)),
                                color: Constants.greyColor,
                                border: Border.all(color: Constants.blueColor)),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Container(
                                width: 350,
                                child: Column(
                                  children: [
                                    TabBar(
                                        controller: _tabController,
                                        unselectedLabelColor: Colors.grey,
                                        indicatorColor: Colors.transparent,
                                        tabs: [
                                          Tab(
                                            child: Container(
                                              width: 80,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color:
                                                      _tabController!.index == 0
                                                          ? Constants.blueColor
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      width: 0.5)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "All".tr(),
                                                    style: TextStyle(
                                                        color: _tabController!
                                                                    .index ==
                                                                0
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "(${allOrdersList.length})",
                                                    style: TextStyle(
                                                        color: _tabController!
                                                                    .index ==
                                                                0
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Tab(
                                            child: Container(
                                              width: 150,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color:
                                                      _tabController!.index == 1
                                                          ? Constants.blueColor
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      width: 0.5)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Accepted".tr(),
                                                    style: TextStyle(
                                                        color: _tabController!
                                                                    .index ==
                                                                1
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "(${acceptedOrdersList.length})",
                                                    style: TextStyle(
                                                        color: _tabController!
                                                                    .index ==
                                                                1
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 65),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Constants.greyColor,
                                  borderRadius: BorderRadius.circular(25)),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectAll = !selectAll;
                                                  if (selectAll) {
                                                    widget.orderList
                                                        ?.forEach((element) {
                                                      element.selected = true;
                                                      element.accepted = true;
                                                    });
                                                  } else {
                                                    widget.orderList
                                                        ?.forEach((element) {
                                                      element.selected = false;
                                                      element.accepted = null;
                                                    });
                                                  }
                                                });
                                              },
                                              child: SizedBox(
                                                height: 30,
                                                width: 30,
                                                child: CustomCheckBox(
                                                    backgroundColor:
                                                        Colors.white,
                                                    checked: selectAll,
                                                    checkedColor:
                                                        Constants.blueColor,
                                                    unCheckedColor:
                                                        Constants.blueColor),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12, right: 12, top: 8),
                                              child: TextFormField(
                                                  autofocus: false,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
                                                    filterSearchResults(
                                                        value, all2, all3);
                                                  },
                                                  controller:
                                                      editingControllerAll,
                                                  decoration:
                                                      kTextFieldDecoration2
                                                          .copyWith(
                                                    hintText: 'Search'.tr(),
                                                    suffixIcon:
                                                        Icon(Icons.search),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  25)),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: CustomButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CaptainOrdersListScreen(
                                                                resourcesData:
                                                                    widget
                                                                        .resourcesData,
                                                                orderList: widget
                                                                    .orderList,
                                                                reserved: true,
                                                                index: 1)));
                                              },
                                              // child: Text('Accept'.tr() + " " + "( ${widget.orderList?.where((element) => element.selected == true  &&  element.accepted == true).length.toString()} )"),
                                              child: Text('Accept'.tr()),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: all2.length,
                                          itemBuilder: (context, i) {
                                            return CapOrdersCard(
                                              ordersList: widget.orderList,
                                              resourcesData:
                                                  widget.resourcesData,
                                              ordersDataModel: all2[i],
                                              reserved: widget.reserved,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  CreateAccaptedTab(
                                      controller: controller,
                                      loading: loading),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget CreateAccaptedTab(
      {BulkPickupController? controller,
      bool loading = false}) {
    if (controller?.calculations.value != null) {
      priceCalculated = true;

      total = controller!.calculations.value!.first;
      suspectedPrice = controller.calculations.value!.last;

      if (controller.calculations.value!.first == "0") {
        showReceipt = false;
      } else {
        showReceipt = true;
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 8),
            child: TextFormField(
                autofocus: false,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  filterSearchResults(value, accepted2, accepted3);
                },
                controller: editingControllerAccepted,
                decoration: kTextFieldDecoration2.copyWith(
                  hintText: 'Search'.tr(),
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                )),
          ),
          Wrap(
            children: accepted2.map((e) {
              return CapOrdersCard(
                ordersList: widget.orderList,
                resourcesData: widget.resourcesData,
                ordersDataModel: e,
                reserved: widget.reserved,
                cancel: true,
              );
            }).toList(),
          ),
          SizedBox(
            height: 20,
          ),
          accepted2.length > 0 && priceCalculated
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: Constants.redColor.withOpacity(0.3),
                        // border: Border.all(color: Colors.grey,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Suspected Price =  '.tr(),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            suspectedPrice.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            'SR'.tr(),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          SizedBox(
            height: 15,
          ),
          accepted2.length > 0
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 60,
                          child: CustomButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              controller!.getClientCredit(
                                widget.orderList![0].member!,
                                acceptedOrdersList,
                                false,
                              );
                            },
                            color: Constants.blueColor,
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Calculate price'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  total!,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'SR'.tr(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : EmptyView(),
          SizedBox(
            height: 10,
          ),
          showReceipt && priceCalculated
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          children: (widget.resourcesData?.paymentMethods ?? [])
                              .map((item) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 2),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (item.val2 != "B") {
                                            setState(() {
                                              item.isSelected =
                                                  !item.isSelected;
                                              if (item.isSelected) {
                                                _currentSelectedPaymentMethod =
                                                    item;
                                                controller?.getReceipt(
                                                    widget.orderList
                                                        ?.first.pickupStoreId ?? "",
                                                    _currentSelectedPaymentMethod
                                                            ?.val2 ?? "");
                                              }
                                              receipt = "";
                                              widget
                                                  .resourcesData?.paymentMethods
                                                  ?.forEach((e) {
                                                if (e.id != item.id) {
                                                  e.isSelected = false;
                                                }
                                              });
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      unselectedWidgetColor:
                                                          Colors.black54,
                                                    ),
                                                    child: SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child: CustomCheckBox(
                                                          checkedColor:
                                                              Constants
                                                                  .blueColor,
                                                          unCheckedColor:
                                                              Colors.grey,
                                                          backgroundColor:
                                                              Colors.white,
                                                          checked:
                                                              item.isSelected,
                                                        )),
                                                  )
                                                ]),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                                child: Text(
                                              item.name ?? "",
                                              style: TextStyle(fontSize: 16),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList()
                              .cast<Widget>()),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.receipt)),
                                    Flexible(
                                        child: Text(
                                      "receipt number".tr(),
                                      style: TextStyle(fontSize: 17),
                                    )),
                                  ],
                                ),
                              ),
                              receipt != ""
                                  ? Flexible(
                                      child: Text(
                                      receipt,
                                      style: TextStyle(fontSize: 17),
                                    ))
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          total == "0"
              ? Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ButtonTheme(
                          height: 60,
                          child: CustomButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              if (!priceCalculated) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Note'.tr()),
                                        content: Text(
                                            'please calculate the price first'
                                                .tr()),
                                        actions: [
                                          CustomButton(
                                            child: Text('ok'.tr()),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                if (!loading) {
                                  controller!.bulkPickupThisList(
                                      memberId: widget.orderList![0].member!,
                                      list: acceptedOrdersList,
                                      amount: total ?? '0',
                                      receipt: receipt,
                                      msgCodee: _codeController.text,
                                      paymentMethodId:
                                          _currentSelectedPaymentMethod?.id ?? "",
                                      creditList: null // Assuming creditList is handled or null here based on original code not showing it
                                      );
                                }
                              }
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 2,
                                      offset: Offset(4, 4), // Shadow position
                                    ),
                                  ],
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      // colors: [Color(0xffE0DAE8), Color(0xffE6C7D0)])
                                      colors: [
                                        Constants.redColor,
                                        Constants.redColor
                                      ])),
                              child: Center(
                                  child: Text(
                                'Pickup'.tr(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Column(
                      children: [
                        receipt != "" && showMsgButton
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Send Confirmation code".tr(),
                                      style: TextStyle(
                                          fontSize: 19,
                                          decoration: TextDecoration.underline),
                                    ),
                                    Row(
                                      children: [
                                          IconButton(
                                            onPressed: () {
                                              controller?.sendConfirmationMsg(
                                                widget.orderList?.first.member ?? "",
                                                widget.orderList?.first.senderPhone ?? "",
                                                "1",
                                              );
                                            },
                                            icon: Icon(
                                                MdiIcons.messageArrowLeftOutline),
                                            color: Colors.black,
                                            iconSize: 22,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              controller?.sendConfirmationMsg(
                                                widget.orderList?.first.member ?? "",
                                                widget.orderList?.first.senderPhone ?? "",
                                                "2",
                                              );
                                            },
                                          icon: Icon(MdiIcons.whatsapp),
                                          color: Colors.green,
                                          iconSize: 22,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : receipt != ""
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularCountDownTimer(
                                      duration: 10,
                                      initialDuration: 0,
                                      controller: CountDownController(),
                                      width: 40,
                                      height: 40,
                                      ringColor: Colors.grey,
                                      ringGradient: null,
                                      fillColor: Constants.blueColor,
                                      fillGradient: null,
                                      backgroundColor: Colors.white,
                                      backgroundGradient: null,
                                      strokeWidth: 20.0,
                                      strokeCap: StrokeCap.round,
                                      textStyle: TextStyle(
                                          fontSize: 18.0,
                                          color: Constants.blueColor,
                                          fontWeight: FontWeight.bold),
                                      textFormat: CountdownTextFormat.S,
                                      isReverse: true,
                                      isReverseAnimation: false,
                                      isTimerTextShown: true,
                                      autoStart: true,
                                      onStart: () {
                                        print('Countdown Started');
                                      },
                                      onComplete: () {
                                        setState(() {
                                          showMsgButton = true;
                                        });
                                      },
                                    ),
                                  )
                                : SizedBox(),
                        receipt != ""
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 10),
                                child: Container(
                                  width: screenWidth! * 0.7,
                                  child: Directionality(
                                    textDirection: ui.TextDirection.ltr,
                                    child: Pinput(
                                      autofocus: false,
                                      length: 6,
                                      onCompleted: (v) {},
                                      controller: _codeController,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ],
                ),
          receipt != ""
              ? Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ButtonTheme(
                          height: 60,
                          child: CustomButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              if (!priceCalculated) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Note'.tr()),
                                        content: Text(
                                            'please calculate the price first'
                                                .tr()),
                                        actions: [
                                          CustomButton(
                                            child: Text('ok'.tr()),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                if (!loading) {
                                  if (_codeController.text.length != 6) {
                                    //Please enter the code
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text("Please enter the code".tr()),
                                      dismissDirection:
                                          DismissDirection.vertical,
                                      duration: Duration(seconds: 1),
                                      backgroundColor: Colors.red,
                                    ));
                                  } else {
                                    controller!.bulkPickupThisList(
                                        memberId: widget.orderList![0].member!,
                                        list: acceptedOrdersList,
                                        amount: total ?? '0',
                                        receipt: receipt,
                                        msgCodee: _codeController.text,
                                        paymentMethodId:
                                            _currentSelectedPaymentMethod?.id ?? "",
                                        creditList: null // Provide creditList if available
                                        );
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 2,
                                      offset: Offset(4, 4), // Shadow position
                                    ),
                                  ],
                                  gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      // colors: [Color(0xffE0DAE8), Color(0xffE6C7D0)])
                                      colors: [
                                        Constants.redColor,
                                        Constants.redColor
                                      ])),
                              child: Center(
                                  child: Text(
                                'Pickup'.tr(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }
}
