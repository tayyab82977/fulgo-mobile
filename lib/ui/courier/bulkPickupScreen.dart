import 'package:auto_size_text/auto_size_text.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:Fulgox/controllers/bulk_pickup_controller.dart';
import 'package:Fulgox/data_providers/models/pickupReportModel.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/courier/captainDashboard.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/ui/custom%20widgets/counterWidget.dart';
import 'package:Fulgox/ui/custom%20widgets/customCheckBox.dart';
import 'package:Fulgox/ui/dialogs/clintBalanceDialog.dart';
import 'package:Fulgox/data_providers/models/memberBalanceModel.dart';
import 'package:Fulgox/ui/dialogs/pickupReportDialog.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'dart:ui' as ui;

var _formKey = GlobalKey<FormState>();

class BulkPickUpScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  bool returnToClient = false;
  List<OrdersDataModelMix>? acceptedOrder;

  BulkPickUpScreen(
      {this.resourcesData, this.acceptedOrder, this.returnToClient = false});
  @override
  _BulkPickUpScreenState createState() => _BulkPickUpScreenState();
}

class _BulkPickUpScreenState extends State<BulkPickUpScreen> {
  final BulkPickupController bulkPickupController = Get.put(BulkPickupController());
  int index = 0;

  bool phoneValidation(String value) {
    if (value.length == 9 && value.characters.first == '5') {
      return true;
    }
    return false;
  }

  final TextEditingController _pickUpTextAreaController =
      TextEditingController();
  double width = 0, height = 0;
  List<OrdersDataModelMix> shipmentList = [];
  List<OrdersDataModelMix> confirmedShipmentList = [];
  List<DataRow> shipmentListRow = [];
  PaymentMethod? _currentSelectedPaymentMethod;
  String receipt = "";

  FocusNode addCheckbox = FocusNode();

  bool priceCalculated = false;
  bool showScanner = false;
  bool showText = false;
  bool showTextField = false;
  bool autoAdding = false;
  String? total = '0.0';
  String? suspectedPrice = '0.0';
  MobileScannerController controller = MobileScannerController();
  bool showReceipt = false;
  final _codeController = TextEditingController();

  String? _barcode;
  late bool visible;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Color primaryColor = Constants.blueColor;
  Future<bool> _willPopCallback() async {
    if (shipmentList.length > 0) {
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
                      height: 15,
                    ),
                    Text(
                      'Are you sure ?'.tr(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                        'If you pressed continue all your edits will be reset'
                            .tr(),
                        style: TextStyle(fontSize: 18)),
                    SizedBox(
                      height: 15,
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
                              child: Text(
                                'Continue'.tr(),
                                style: TextStyle(color: Colors.white),
                              ),
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

  bool selectAll = false;
  bool showMsgButton = true;

  HDTRefreshController _hdtRefreshController = HDTRefreshController();

  static const int sortName = 0;
  static const int sortStatus = 1;
  bool isAscending = true;
  int sortType = sortName;
  @override
  void dispose() {
    // bulkPickupController is managed by GetX
    super.dispose();
  }

  var dts;
  @override
  void initState() {
    // shipmentList.addAll(widget.acceptedOrder!);
    if (widget.returnToClient) {
      primaryColor = primaryColor;
    }
    try {
      widget.resourcesData?.paymentMethods?.forEach((e) {
        e.isSelected = false;
      });
      // _currentSelectedPaymentMethod = widget.resourcesData?.paymentMethods?.first ;
    } catch (e) {}
    super.initState();
  }

  String _scanBarcode = 'Unknown';

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return ProgressHUD(
      backgroundColor: primaryColor,
      barrierEnabled: false,
      child: Obx(() {
        if (bulkPickupController.isLoading.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ProgressHUD.of(context)?.show();
          });
        } else {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ProgressHUD.of(context)?.dismiss();
          });
        }

        if (bulkPickupController.errorMessage.value.isNotEmpty) {
          String err = bulkPickupController.errorMessage.value;
          bulkPickupController.errorMessage.value = '';
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            if (err == 'needUpdate') {
              GeneralHandler.handleNeedUpdateState(context);
            } else if (err == "invalidToken") {
              GeneralHandler.handleInvalidToken(context);
            } else if (err == "TIMEOUT") {
              GeneralHandler.handleNetworkError(context);
            } else if (err == "general") {
              GeneralHandler.handleGeneralError(context);
            } else {
              ComFunctions.showToast(color: Colors.red, text: err);
            }
          });
        }

        if (bulkPickupController.clientBalance.value != null) {
          ClientBalanceModel balance = bulkPickupController.clientBalance.value!;
          bulkPickupController.clientBalance.value = null;
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ClientBalanceDialog.showClientBalanceDialog(balance, context);
          });
        }

        if (bulkPickupController.newShipment.value != null) {
          OrdersDataModelMix shipment = bulkPickupController.newShipment.value!;
          bulkPickupController.newShipment.value = null;
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            if (shipmentList.any((e) => e.id == shipment.id)) {
              ComFunctions.showToast(
                  text: "This shipment already exist".tr(), color: Colors.red);
              if (showText) {
                FocusScope.of(context).requestFocus(addCheckbox);
              }
            } else {
              setState(() {
                if (showText) {
                  FocusScope.of(context).requestFocus(addCheckbox);
                }
                bool senderPhoneCheck =
                    phoneValidation(shipment.senderPhone ?? "");
                bool receiverPhoneCheck =
                    phoneValidation(shipment.receiverPhone ?? "");

                if (!senderPhoneCheck || !receiverPhoneCheck) {
                  shipment.inValidPhones = true;
                }
                shipmentList.add(shipment);
                priceCalculated = false;
                _pickUpTextAreaController.clear();
                controller.start();
              });
            }
          });
        }

        if (bulkPickupController.msgSentSuccess.value) {
          bulkPickupController.msgSentSuccess.value = false;
          showMsgButton = false;
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ComFunctions.showToast(
                text: "Successfully done".tr(), color: Colors.green);
          });
        }

        if (bulkPickupController.receipt.value != null) {
          receipt = bulkPickupController.receipt.value!;
          bulkPickupController.receipt.value = null;
        }

        if (bulkPickupController.calculations.value != null) {
          List<String> results = bulkPickupController.calculations.value!;
          bulkPickupController.calculations.value = null;
          total = results.first;
          suspectedPrice = results.last;
          priceCalculated = true;
          if (total != "0") {
            showReceipt = true;
          }
        }

        if (bulkPickupController.pickupReport.value != null) {
          PickupReportModel report = bulkPickupController.pickupReport.value!;
          bulkPickupController.pickupReport.value = null;
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            PickupReportDialog.showPickupReportDialog(
                report, context, widget.resourcesData!);
          });
        }

        if (bulkPickupController.returnShipmentsSuccess.value) {
          bulkPickupController.returnShipmentsSuccess.value = false;
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Successfully done'.tr(),
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          )
                        ],
                      ),
                      actions: [
                        CustomButton(
                          child: Text('ok'.tr()),
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
                        ),
                      ]);
                });
          });
        }

        if (bulkPickupController.errorsList.isNotEmpty) {
          List<String> errors = List.from(bulkPickupController.errorsList);
          bulkPickupController.errorsList.clear();
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Container(
                height: errors.length * 40.0,
                child: ListView.builder(
                  itemCount: errors.length,
                  itemBuilder: (context, i) {
                    return Text(errors[i]);
                  },
                ),
              ),
              duration: const Duration(milliseconds: 500),
              backgroundColor: Colors.red,
            ));
          });
        }

        return buildBulkPickUpScreen();
      }),
    );
  }

  Widget buildBulkPickUpScreen() {
    return Form(
      key: _formKey,
      child: WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          floatingActionButton: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.camera_enhance_outlined,
                color: primaryColor,
              ),
              onPressed: () async {
                _floatingButton();

                // if(showScanner){
                //   setState(() {
                //     controller.pause();
                //     showScanner = false ;
                //
                //
                //   });
                // }else {
                //   setState(() {
                //     controller.start();
                //     showScanner = true ;
                //     _resetTheLists();
                //     autoAdding = false ;
                //
                //
                //   });
                //
                // }

                // _pickUpTextAreaController.text = await FlutterBarcodeScanner.scanBarcode(
                //     '#ff6666', 'Cancel'.tr(), true, ScanMode.BARCODE );
                // if(_pickUpTextAreaController.text.isNotEmpty){
                //   if(widget.returnToClient){
                //     bulkPickupBloc.add(GetShipmentData(shipmentId: _pickUpTextAreaController.text.trim() , type: "rtc"));
                //
                //   }else {
                //     bulkPickupBloc.add(GetShipmentData(shipmentId: _pickUpTextAreaController.text.trim(),type: "bulkPickup"));
                //
                //   }
                //
                // }
              },
              // child: Center(
              //   child: IconButton(
              //     icon: Icon(Icons.camera_enhance_outlined , size: 40, color: primaryColor,),
              //     onPressed: ()async{
              //       _pickUpTextAreaController.text = await FlutterBarcodeScanner.scanBarcode(
              //           '#ff6666', 'Cancel'.tr(), true, ScanMode.BARCODE );
              //       if(_pickUpTextAreaController.text.isNotEmpty){
              //
              //       }
              //     },
              //   ),
              // ),
            ),
          ),
          key: _drawerKey,
          body: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _willPopCallback),
                    widget.returnToClient
                        ? Text(
                            'Return to client'.tr(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          )
                        : Text(
                            'Pickup'.tr(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                    SizedBox(
                      width: 20,
                    ),
                    widget.returnToClient
                        ? Container()
                        : Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    bulkPickupController.getClientBalances(
                                        widget.acceptedOrder?.first.member ?? "");
                                  },
                                  child: Text(
                                widget.acceptedOrder?.first.memberName
                                        .toString() ??
                                    "",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              showScanner
                  ? Container(
                      width: width,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(120, 135, 198, .3),
                                  blurRadius: 80,
                                  offset: Offset(0, 20),
                                )
                              ]),
                          margin: EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: 200, // custom wrap size
                                  height: 150,
                                  child: MobileScanner(
                                    controller: controller,
                                    onDetect: (str) {
                                      if (str.barcodes.isEmpty &&
                                          str.barcodes.length != 0 &&
                                          str.barcodes[0].rawValue!.length >
                                              7 &&
                                          ComFunctions.isNumeric(
                                              str.barcodes[0].rawValue)) {
                                        _pickUpTextAreaController.text =
                                            str.barcodes[0].rawValue!;
                                        bulkPickupController.getShipmentData(
                                            _pickUpTextAreaController.text.trim(),
                                            widget.returnToClient ? "rtc" : "bulkPickup"
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )),
                    )
                  : SizedBox(),
              showTextField
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 30, right: 10, left: 10),
                      child: Container(
                        child: TextField(
                          controller: _pickUpTextAreaController,
                          focusNode: addCheckbox,
                          autofocus: true,
                          maxLines: 1, //unlimited lines
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: primaryColor,
                            )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: primaryColor,
                            )),
                            hintText: 'Shipment id'.tr(),
                          ),
                          onChanged: (str) {
                            if (str.isNotEmpty &&
                                str.trim().length != 0 &&
                                str.trim().length > 8 &&
                                ComFunctions.isNumeric(str)) {
                                bulkPickupController.getShipmentData(
                                    _pickUpTextAreaController.text.trim(),
                                    widget.returnToClient ? "rtc" : "bulkPickup"
                                );
                            }
                          },
                          onSubmitted: (str) => print(
                              'This will not get called when return is pressed'),
                        ),
                      ),
                    )
                  : SizedBox(),
              showText
                  ? Container(
                      child: Center(
                      // Add visiblity detector to handle barcode
                      // values only when widget is visible
                      child: VisibilityDetector(
                        onVisibilityChanged: (VisibilityInfo info) {
                          visible = info.visibleFraction > 0;
                        },
                        key: Key('visible-detector-key'),
                        child: BarcodeKeyboardListener(
                          bufferDuration: Duration(milliseconds: 200),
                          onBarcodeScanned: (barcode) {
                            if (!visible) return;
                            print(barcode);
                            _pickUpTextAreaController.text = barcode;
                            bulkPickupController.getShipmentData(
                                _pickUpTextAreaController.text.trim(),
                                widget.returnToClient ? "rtc" : "bulkPickup"
                            );
                            setState(() {
                              _barcode = barcode;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _barcode == null
                                    ? 'SCAN BARCODE'
                                    : 'BARCODE: $_barcode',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                  : SizedBox(),
              Expanded(
                flex: 24,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Column(children: <Widget>[
                      SizedBox(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Text(
                              "All".tr(),
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "(${shipmentList.length.toString()})",
                              style:
                                  TextStyle(color: primaryColor, fontSize: 18),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Confirmed Shipments".tr(),
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "(${confirmedShipmentList.length.toString()})",
                                  style: TextStyle(
                                      color: primaryColor, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(120, 135, 198, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ]),
                        height: height / 100 * 60,
                        width: width,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [_getBodyWidget()],
                        ),
                      ),
                      SizedBox(
                        height: height / 100 * 2,
                      ),
                      confirmedShipmentList.length > 0 &&
                              priceCalculated &&
                              !widget.returnToClient
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Suspected Price =  '.tr(),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                      Text(
                                        suspectedPrice.toString(),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 22),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        'SR'.tr(),
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),

                      Column(
                        children: [
                          SizedBox(
                            height: height / 100 * 1,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ButtonTheme(
                                    height: 60,
                                    child: CustomButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      onPressed: () {
                                        if (confirmedShipmentList.isNotEmpty) {
                                          bulkPickupController.getClientCredit(
                                              confirmedShipmentList.first.member ?? "",
                                              confirmedShipmentList,
                                              widget.returnToClient);
                                        } else {
                                          ComFunctions.showToast(
                                              text:
                                                  "Confirm shipments first to calculate"
                                                      .tr(),
                                              color: Colors.red);
                                        }
                                      },
                                      color: primaryColor,
                                      padding: EdgeInsets.all(0),
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
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            total.toString(),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 18),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            'SR'.tr(),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          showReceipt && priceCalculated
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                          children:
                                              (widget.resourcesData
                                                          ?.paymentMethods ??
                                                      [])
                                                  .map((item) => Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 2),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              if (item.val2 !=
                                                                  "B") {
                                                                setState(() {
                                                                  item.isSelected =
                                                                      !item
                                                                          .isSelected;
                                                                  if (item
                                                                      .isSelected) {
                                                                    _currentSelectedPaymentMethod =
                                                                        item;
                                                                    bulkPickupController.getReceipt(
                                                                        widget.acceptedOrder?.first.pickupStoreId ?? "",
                                                                        _currentSelectedPaymentMethod?.val2 ?? "");
                                                                  }
                                                                  receipt = "";
                                                                  widget
                                                                      .resourcesData
                                                                      ?.paymentMethods
                                                                      ?.forEach(
                                                                          (e) {
                                                                    if (e.id !=
                                                                        item.id) {
                                                                      e.isSelected =
                                                                          false;
                                                                    }
                                                                  });
                                                                });
                                                              }
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
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
                                                                              checkedColor: Constants.blueColor,
                                                                              unCheckedColor: Colors.grey,
                                                                              backgroundColor: Colors.white,
                                                                              checked: item.isSelected,
                                                                            )),
                                                                      )
                                                                    ]),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                    child: Text(
                                                                  item.name ??
                                                                      "",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {},
                                                        icon: Icon(
                                                            Icons.receipt)),
                                                    Flexible(
                                                        child: Text(
                                                      "receipt number".tr(),
                                                      style: TextStyle(
                                                          fontSize: 17),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              receipt != ""
                                                  ? Flexible(
                                                      child: Text(
                                                      receipt,
                                                      style: TextStyle(
                                                          fontSize: 17),
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
                        ],
                      ),
                      // : Container(),
                      Container(
                        height: 350,
                        child: Row(
                          children: [
                            if (total != "0" && receipt != "")
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          showMsgButton
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Send Confirmation code"
                                                            .tr(),
                                                        style: TextStyle(
                                                            fontSize: 19),
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              bulkPickupController.sendConfirmationMsg(
                                                                widget.acceptedOrder?.first.member ?? "",
                                                                widget.acceptedOrder?.first.senderPhone ?? "",
                                                                "1",
                                                              );
                                                            },
                                                            icon: Icon(MdiIcons
                                                                .messageArrowLeftOutline),
                                                            color: Colors.black,
                                                            iconSize: 22,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              bulkPickupController.sendConfirmationMsg(
                                                                widget.acceptedOrder?.first.member ?? "",
                                                                widget.acceptedOrder?.first.senderPhone ?? "",
                                                                "2",
                                                              );
                                                            },
                                                            icon: Icon(MdiIcons
                                                                .whatsapp),
                                                            color: Colors.green,
                                                            iconSize: 22,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: CircularCountDownTimer(
                                                    duration: 180,
                                                    initialDuration: 0,
                                                    controller:
                                                        CountDownController(),
                                                    width: 40,
                                                    height: 40,
                                                    ringColor: Colors.grey,
                                                    fillColor:
                                                        Constants.blueColor,
                                                    backgroundColor:
                                                        Colors.white,
                                                    strokeWidth: 20.0,
                                                    strokeCap: StrokeCap.round,
                                                    textStyle: TextStyle(
                                                        fontSize: 18.0,
                                                        color:
                                                            Constants.blueColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textFormat:
                                                        CountdownTextFormat.S,
                                                    isReverse: true,
                                                    isReverseAnimation: false,
                                                    isTimerTextShown: true,
                                                    autoStart: true,
                                                    onStart: () {
                                                      print(
                                                          'Countdown Started');
                                                    },
                                                    onComplete: () {
                                                      setState(() {
                                                        showMsgButton = true;
                                                      });
                                                    },
                                                  ),
                                                ),
                                          Container(
                                            width: width * 0.7,
                                            child: Directionality(
                                                textDirection:
                                                    ui.TextDirection.ltr,
                                                child: Pinput(
                                                  autofocus: false,
                                                  length: 6,
                                                  onCompleted: (v) {},
                                                  controller: _codeController,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: ButtonTheme(
                                          height: 60,
                                          child: CustomButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: EdgeInsets.all(0),
                                            onPressed: () async {
                                              if (widget.returnToClient) {
                                                if (confirmedShipmentList
                                                    .isNotEmpty) {
                                                  if (_codeController
                                                          .text.length !=
                                                      6) {
                                                    //Please enter the code
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Please enter the code"
                                                              .tr()),
                                                      dismissDirection:
                                                          DismissDirection
                                                              .vertical,
                                                      duration:
                                                          Duration(seconds: 1),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ));
                                                  } else {
                                                    bulkPickupController.returnThisList(
                                                        memberId: shipmentList[0].member ?? "",
                                                        list: confirmedShipmentList,
                                                        amount: total ?? '0',
                                                        code: _codeController.text,
                                                        receipt: receipt,
                                                        paymentMethodId: _currentSelectedPaymentMethod?.id);
                                                  }
                                                }
                                              } else {
                                                if (_formKey.currentState!
                                                        .validate() &&
                                                    priceCalculated &&
                                                    confirmedShipmentList
                                                        .isNotEmpty) {
                                                  if (_codeController
                                                          .text.length !=
                                                      6) {
                                                    //Please enter the code
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Please enter the code"
                                                              .tr()),
                                                      dismissDirection:
                                                          DismissDirection
                                                              .vertical,
                                                      duration:
                                                          Duration(seconds: 1),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ));
                                                  } else {
                                                    bulkPickupController.bulkPickupThisList(
                                                        memberId: shipmentList[0].member ?? "",
                                                        list: confirmedShipmentList,
                                                        amount: total ?? '0',
                                                        receipt: receipt,
                                                        msgCodee: _codeController.text,
                                                        paymentMethodId: _currentSelectedPaymentMethod?.id ?? "",
                                                        creditList: null); // creditList empty for now as it was in previous implementation
                                                  }
                                                }
                                              }
                                            },
                                            child: Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: primaryColor,
                                              ),
                                              child: Center(
                                                  child: widget.returnToClient
                                                      ? Text(
                                                          'Return to client'
                                                              .tr(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18))
                                                      : Text(
                                                          'Pickup'.tr(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        )),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (priceCalculated && total == "0")
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: ButtonTheme(
                                    height: 60,
                                    child: CustomButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: EdgeInsets.all(0),
                                      onPressed: () async {
                                        if (widget.returnToClient) {
                                          if (confirmedShipmentList
                                              .isNotEmpty) {
                                            bulkPickupController.returnThisList(
                                                memberId: shipmentList[0].member ?? "",
                                                list: confirmedShipmentList,
                                                code: _codeController.text,
                                                amount: total ?? '0',
                                                receipt: receipt,
                                                paymentMethodId: _currentSelectedPaymentMethod?.id);
                                          }
                                        } else {
                                          if (_formKey.currentState!
                                                  .validate() &&
                                              priceCalculated &&
                                              confirmedShipmentList
                                                  .isNotEmpty) {
                                            bulkPickupController.bulkPickupThisList(
                                                memberId: shipmentList[0].member ?? "",
                                                list: confirmedShipmentList,
                                                amount: total ?? '0',
                                                receipt: receipt,
                                                msgCodee: _codeController.text,
                                                paymentMethodId: _currentSelectedPaymentMethod?.id ?? "",
                                                creditList: null);
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: primaryColor,
                                        ),
                                        child: Center(
                                            child: widget.returnToClient
                                                ? Text('Return to client'.tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18))
                                                : Text(
                                                    'Pickup'.tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  )),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 10,
                              ),
                          ],
                        ),
                      )
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBodyWidget() {
    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: 150,
        rightHandSideColumnWidth: 1000,
        isFixedHeader: true,
        headerWidgets:
            EasyLocalization.of(context)!.currentLocale == Locale("en")
                ? _getTitleWidgetEn()
                : _getTitleWidgetAr(),
        leftSideItemBuilder:
            EasyLocalization.of(context)!.currentLocale == Locale("en")
                ? _generateFirstColumnRowEn
                : _generateFirstColumnRowAr,
        rightSideItemBuilder:
            EasyLocalization.of(context)!.currentLocale == Locale("en")
                ? _generateRightHandSideColumnRowEn
                : _generateRightHandSideColumnRowAr,
        itemCount: shipmentList.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
        rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
        verticalScrollbarStyle: const ScrollbarStyle(
          thumbColor: Colors.yellow,
          thickness: 4.0,
          radius: Radius.circular(5.0),
        ),
        horizontalScrollbarStyle: const ScrollbarStyle(
          thumbColor: Colors.red,
          thickness: 4.0,
          radius: Radius.circular(5.0),
        ),
        enablePullToRefresh: false,
        refreshIndicator: const WaterDropHeader(),
        refreshIndicatorHeight: 60,
        onRefresh: () async {
          // //Do sth
          // await Future.delayed(const Duration(milliseconds: 500));
          // _hdtRefreshController.refreshCompleted();
        },
        htdRefreshController: _hdtRefreshController,
      ),
      height: MediaQuery.of(context).size.height,
    );
  }

  List<Widget> _getTitleWidgetEn() {
    return [
      Container(
        width: 200,
        height: 56,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              // width: 5,
              // alignment: Alignment.centerLeft,
              child: Checkbox(
                  value: selectAll,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (e) {
                    setState(() {
                      selectAll = !selectAll;
                      priceCalculated = false;
                      receipt = "";
                      total = '0.0';
                      if (selectAll) {
                        confirmedShipmentList.clear();
                        shipmentList.forEach((element) {
                          if (!element.inValidPhones) {
                            element.selected = true;
                            element.accepted = true;
                            confirmedShipmentList.add(element);
                          }
                        });
                        // confirmedShipmentList.addAll(shipmentList);
                        // for (int i = 0; i < shipmentList.length; i++) {
                        //   shipmentList[i].selected = true;
                        //   shipmentList[i].accepted = true;
                        // }
                      } else {
                        confirmedShipmentList.clear();
                        for (int i = 0; i < shipmentList.length; i++) {
                          shipmentList[i].selected = false;
                          shipmentList[i].accepted = null;
                        }
                      }
                    });
                  }),
            ),
            Text(
              "Id".tr(),
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),

      _getTitleItemWidget('Packaging'.tr(), 150),
      _getTitleItemWidget('No of Cartoons'.tr(), 150),
      _getTitleItemWidget('Pieces'.tr(), 100),
      _getTitleItemWidget('Weight'.tr(), 100),
      _getTitleItemWidget('Height'.tr(), 100),
      _getTitleItemWidget('Width'.tr(), 100),
      _getTitleItemWidget('Length'.tr(), 100),
      _getTitleItemWidget('Edit'.tr(), 100),
      // _getTitleItemWidget('Remove', 100),
    ];
  }

  List<Widget> _getTitleWidgetAr() {
    return [
      Container(
        width: 200,
        height: 56,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Id".tr(),
              style: TextStyle(fontSize: 15),
            ),
            Container(
              // width: 5,
              // alignment: Alignment.centerLeft,
              child: Checkbox(
                  value: selectAll,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (e) {
                    setState(() {
                      selectAll = !selectAll;
                      priceCalculated = false;
                      receipt = "";
                      total = '0.0';
                      if (selectAll) {
                        confirmedShipmentList.clear();

                        shipmentList.forEach((element) {
                          if (!element.inValidPhones) {
                            element.selected = true;
                            element.accepted = true;
                            confirmedShipmentList.add(element);
                          }
                        });

                        // confirmedShipmentList.addAll(shipmentList);
                        // for (int i = 0; i < shipmentList.length; i++) {
                        //   shipmentList[i].selected = true;
                        //   shipmentList[i].accepted = true;
                        // }
                      } else {
                        confirmedShipmentList.clear();
                        for (int i = 0; i < shipmentList.length; i++) {
                          shipmentList[i].selected = false;
                          shipmentList[i].accepted = null;
                        }
                      }
                    });
                  }),
            ),
          ],
        ),
      ),
      _getTitleItemWidget('Edit'.tr(), 100),
      _getTitleItemWidget('Packaging'.tr(), 150),
      _getTitleItemWidget('No of Cartoons'.tr(), 100),
      _getTitleItemWidget('Pieces'.tr(), 100),
      _getTitleItemWidget('Weight'.tr(), 100),
      _getTitleItemWidget('Height'.tr(), 100),
      _getTitleItemWidget('Width'.tr(), 100),
      _getTitleItemWidget('Length'.tr(), 100),

      // _getTitleItemWidget('Remove', 100),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      width: width,
      height: 56,
      padding: EasyLocalization.of(context)!.currentLocale == Locale("en")
          ? EdgeInsets.fromLTRB(5, 0, 0, 0)
          : EdgeInsets.fromLTRB(0, 0, 5, 0),
      alignment: EasyLocalization.of(context)!.currentLocale == Locale("en")
          ? Alignment.centerLeft
          : Alignment.centerRight,
    );
  }

  Widget _generateFirstColumnRowEn(BuildContext context, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: Checkbox(
            value: shipmentList[index].selected,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (value) {
              setState(() {
                if (!shipmentList[index].inValidPhones) {
                  shipmentList[index].selected = !shipmentList[index].selected;
                  priceCalculated = false;
                  receipt = "";
                  total = '0.0';
                  if (shipmentList[index].selected) {
                    confirmedShipmentList.add(shipmentList[index]);
                    shipmentList[index].accepted = true;
                  } else {
                    confirmedShipmentList.remove(shipmentList[index]);
                  }
                }
              });
            },
          ),
          // width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          alignment: Alignment.center,
        ),
        Container(
          child: Text(
            shipmentList[index].id.toString(),
            style: TextStyle(
                color: shipmentList[index].inValidPhones
                    ? Colors.red
                    : Colors.black),
          ),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }

  Widget _generateFirstColumnRowAr(BuildContext context, int index) {
    return Container(
      width: 200,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: Text(
              shipmentList[index].id.toString(),
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black),
            ),
            // width: 100,
            height: 52,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: shipmentList[index].inValidPhones
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.grey.shade400),
                  )
                : Checkbox(
                    value: shipmentList[index].selected,
                    // checkColor: shipmentList[index].inValidPhones ? Colors.red : Colors.black,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) {
                      setState(() {
                        if (!shipmentList[index].inValidPhones) {
                          shipmentList[index].selected =
                              !shipmentList[index].selected;
                          priceCalculated = false;
                          receipt = "";
                          total = '0.0';
                          if (shipmentList[index].selected) {
                            confirmedShipmentList.add(shipmentList[index]);
                            shipmentList[index].accepted = true;
                          } else {
                            confirmedShipmentList.remove(shipmentList[index]);
                          }
                        }
                      });
                    },
                  ),
            // width: 100,
            height: 52,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  Widget _generateRightHandSideColumnRowEn(BuildContext context, int index) {
    String? packaging;

    for (int i = 0; i < (widget.resourcesData?.packaging?.length ?? 0); i++) {
      if (shipmentList[index].packaging ==
          widget.resourcesData?.packaging?[i].id) {
        packaging = widget.resourcesData?.packaging?[i].name;
      }
    }
    if (packaging == null) {
      packaging = widget.resourcesData?.packaging?.first.name;
    }
    return Row(
      children: <Widget>[
        Container(
          child: AutoSizeText(
            packaging ?? "",
            style: TextStyle(
                color: shipmentList[index].inValidPhones
                    ? Colors.red
                    : Colors.black),
          ),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].noOfCartoons ?? ""),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].quantity ?? "1"),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].weight.toString()),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].height.toString()),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].width.toString()),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].length.toString()),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          width: 100,
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Packaging? _currentSelectedPackaging = Packaging();

                    final TextEditingController _editWeightController =
                        TextEditingController();
                    final TextEditingController _editLengthController =
                        TextEditingController();
                    final TextEditingController _editWidthController =
                        TextEditingController();
                    final TextEditingController _editHeigthController =
                        TextEditingController();
                    final TextEditingController _editPiecesController =
                        TextEditingController();
                    int noOfCartons = 1, noOfPieces = 1;

                    setData() {
                      _editWeightController.text =
                          shipmentList[index].weight.toString();
                      _editWidthController.text =
                          shipmentList[index].width.toString();
                      _editHeigthController.text =
                          shipmentList[index].height.toString();
                      _editLengthController.text =
                          shipmentList[index].length.toString();
                      noOfCartons = int.tryParse(
                              shipmentList[index].noOfCartoons.toString()) ??
                          0;
                      noOfPieces = int.tryParse(
                              shipmentList[index].quantity.toString()) ??
                          0;

                      if (shipmentList[index].quantity != null) {
                        _editPiecesController.text =
                            shipmentList[index].quantity.toString();
                      } else {
                        _editPiecesController.text = "1";
                      }

                      for (int i = 0;
                          i < (widget.resourcesData?.packaging?.length ?? 0);
                          i++) {
                        if (shipmentList[index].packaging ==
                            widget.resourcesData?.packaging?[i].id) {
                          packaging = widget.resourcesData?.packaging?[i].name;

                          _currentSelectedPackaging =
                              widget.resourcesData?.packaging?[i];
                        }
                      }
                      if (_currentSelectedPackaging?.name == null) {
                        _currentSelectedPackaging =
                            widget.resourcesData?.packaging?.first;
                        packaging = widget.resourcesData?.packaging?.first.name;
                      }
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        final width = MediaQuery.of(context).size.width;
                        final height = MediaQuery.of(context).size.height;

                        setData();

                        return StatefulBuilder(builder: (context, setState2) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                new Text(
                                  "Id".tr(),
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                new Text(shipmentList[index].id.toString(),
                                    style: TextStyle(fontSize: 15)),
                              ],
                            ),
                            content: Container(
                                // height: height / 100 * 50,
                                child: SingleChildScrollView(
                              child: Column(children: [
                                TextField(
                                  keyboardType: TextInputType.number,
                                  autofocus: false,
                                  controller: _editWeightController,
                                  textAlign: TextAlign.left,
                                  decoration: kBulkPickupDialogue.copyWith(
                                      // border: InputBorder.none,
                                      labelText: "Weight".tr(),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      )),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: width,
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          controller: _editLengthController,
                                          textAlign: TextAlign.left,
                                          decoration:
                                              kBulkPickupDialogue.copyWith(
                                                  // border: InputBorder.none,
                                                  labelText: "Length".tr(),
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  )),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          controller: _editWidthController,
                                          textAlign: TextAlign.left,
                                          decoration:
                                              kBulkPickupDialogue.copyWith(
                                                  // border: InputBorder.none,
                                                  labelText: "Width".tr(),
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  )),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          controller: _editHeigthController,
                                          textAlign: TextAlign.left,
                                          decoration:
                                              kBulkPickupDialogue.copyWith(
                                                  // border: InputBorder.none,
                                                  labelText: "Height".tr(),
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                          child: Text("Number of Pieces".tr(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ))),
                                      CounterWidget(
                                        counter: (e) {
                                          noOfPieces = e;
                                        },
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.1),
                                        initialValue: noOfPieces,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Packaging>(
                                        items: widget.resourcesData?.packaging
                                            ?.map(
                                                (Packaging dropDownStringItem) {
                                          return DropdownMenuItem<Packaging>(
                                            value: dropDownStringItem,
                                            child: Text(
                                              dropDownStringItem.name ?? "",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (Packaging? newValue) {
                                          setState2(() {
                                            _currentSelectedPackaging =
                                                newValue;
                                            shipmentList[index].packaging =
                                                _currentSelectedPackaging!.id;
                                          });
                                        },
                                        value: _currentSelectedPackaging,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                            child: Text(
                                          "Number of Cartoons".tr(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xffCE5C5C)),
                                        )),
                                        CounterWidget(
                                          counter: (e) {
                                            noOfCartons = e;
                                          },
                                          acceptZero: true,
                                          backgroundColor: Color(0xffCE5C5C)
                                              .withOpacity(0.3),
                                          initialValue: noOfCartons,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                                Container(),
                                SizedBox(
                                  height: 10,
                                ),
                              ]),
                            )),
                            actions: <Widget>[
                              CustomButton(
                                child: new Text("Edit".tr(),
                                    style: TextStyle(
                                      color: Colors.blue,
                                    )),
                                onPressed: () {
                                  setState(() {
                                    shipmentList[index].weight =
                                        _editWeightController.text;
                                    shipmentList[index].width =
                                        _editWidthController.text;
                                    shipmentList[index].height =
                                        _editHeigthController.text;
                                    shipmentList[index].length =
                                        _editLengthController.text;
                                    shipmentList[index].quantity =
                                        noOfPieces.toString();
                                    shipmentList[index].noOfCartoons =
                                        noOfCartons.toString();
                                  });

                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                      },
                    );
                  },
                  child: Icon(Icons.edit)),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (shipmentList[index].selected) {
                      confirmedShipmentList.remove(shipmentList[index]);
                    }

                    shipmentList.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.clear,
                  color: Colors.red,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _generateRightHandSideColumnRowAr(BuildContext context, int index) {
    String? packaging;

    for (int i = 0; i < widget.resourcesData!.packaging!.length; i++) {
      if (shipmentList[index].packaging ==
          widget.resourcesData!.packaging![i].id) {
        packaging = widget.resourcesData!.packaging![i].name;
      }
    }

    return Row(
      children: <Widget>[
        Container(
          width: 100,
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (shipmentList[index].selected) {
                      confirmedShipmentList.remove(shipmentList[index]);
                    }

                    shipmentList.removeAt(index);
                  });
                },
                child: Icon(
                  Icons.clear,
                  color: Colors.red,
                  size: 14,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                  onTap: () {
                    Packaging? _currentSelectedPackaging = Packaging();

                    final TextEditingController _editWeightController =
                        TextEditingController();
                    final TextEditingController _editLengthController =
                        TextEditingController();
                    final TextEditingController _editWidthController =
                        TextEditingController();
                    final TextEditingController _editHeigthController =
                        TextEditingController();
                    final TextEditingController _editPiecesController =
                        TextEditingController();
                    int noOfCartons = 0, noOfPieces = 0;

                    setData() {
                      _editWeightController.text =
                          shipmentList[index].weight.toString();
                      _editWidthController.text =
                          shipmentList[index].width.toString();
                      _editHeigthController.text =
                          shipmentList[index].height.toString();
                      _editLengthController.text =
                          shipmentList[index].length.toString();
                      noOfCartons = int.tryParse(
                              shipmentList[index].noOfCartoons.toString()) ??
                          0;

                      noOfPieces = int.tryParse(
                              shipmentList[index].quantity.toString()) ??
                          0;

                      if (shipmentList[index].quantity != null) {
                        _editPiecesController.text =
                            shipmentList[index].quantity.toString();
                      } else {
                        _editPiecesController.text = "1";
                      }

                      for (int i = 0;
                          i < widget.resourcesData!.packaging!.length;
                          i++) {
                        if (shipmentList[index].packaging ==
                            widget.resourcesData!.packaging![i].id) {
                          packaging = widget.resourcesData!.packaging![i].name;
                          _currentSelectedPackaging =
                              widget.resourcesData!.packaging![i];
                        }
                      }
                      if (_currentSelectedPackaging?.name == null) {
                        packaging = widget.resourcesData!.packaging?.first.name;
                        _currentSelectedPackaging =
                            widget.resourcesData?.packaging?.first;
                        shipmentList[index].packaging =
                            widget.resourcesData?.packaging?.first.id;
                      }
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        final width = MediaQuery.of(context).size.width;
                        final height = MediaQuery.of(context).size.height;

                        setData();

                        return StatefulBuilder(builder: (context, setState2) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                new Text(
                                  "Id".tr(),
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                new Text(shipmentList[index].id.toString(),
                                    style: TextStyle(fontSize: 15)),
                              ],
                            ),
                            content: Container(
                                // height: height / 100 * 50,
                                child: SingleChildScrollView(
                              child: Column(children: [
                                TextField(
                                  keyboardType: TextInputType.number,
                                  autofocus: false,
                                  controller: _editWeightController,
                                  textAlign: TextAlign.left,
                                  decoration: kBulkPickupDialogue.copyWith(
                                      // border: InputBorder.none,
                                      labelText: "Weight".tr(),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      )),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: width,
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          controller: _editLengthController,
                                          textAlign: TextAlign.left,
                                          decoration:
                                              kBulkPickupDialogue.copyWith(
                                                  // border: InputBorder.none,
                                                  labelText: "Length".tr(),
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  )),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          controller: _editWidthController,
                                          textAlign: TextAlign.left,
                                          decoration:
                                              kBulkPickupDialogue.copyWith(
                                                  // border: InputBorder.none,
                                                  labelText: "Width".tr(),
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  )),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          controller: _editHeigthController,
                                          textAlign: TextAlign.left,
                                          decoration:
                                              kBulkPickupDialogue.copyWith(
                                                  // border: InputBorder.none,
                                                  labelText: "Height".tr(),
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text("Number of Pieces".tr(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                            )),
                                      ),
                                      CounterWidget(
                                        counter: (e) {
                                          noOfPieces = e;
                                        },
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.1),
                                        initialValue: noOfPieces,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Packaging>(
                                        items: widget.resourcesData!.packaging!
                                            .map(
                                                (Packaging dropDownStringItem) {
                                          return DropdownMenuItem<Packaging>(
                                            value: dropDownStringItem,
                                            child: Text(
                                              dropDownStringItem.name!,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (Packaging? newValue) {
                                          setState2(() {
                                            _currentSelectedPackaging =
                                                newValue;
                                            shipmentList[index].packaging =
                                                _currentSelectedPackaging!.id;
                                          });
                                        },
                                        value: _currentSelectedPackaging,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                            child: Text(
                                          "Number of Cartoons".tr(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xffCE5C5C)),
                                        )),
                                        CounterWidget(
                                          counter: (e) {
                                            noOfCartons = e;
                                          },
                                          acceptZero: true,
                                          backgroundColor: Color(0xffCE5C5C)
                                              .withOpacity(0.3),
                                          initialValue: noOfCartons,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ]),
                            )),
                            actions: <Widget>[
                              CustomButton(
                                child: new Text(
                                  "Edit".tr(),
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    shipmentList[index].weight =
                                        _editWeightController.text;
                                    shipmentList[index].width =
                                        _editWidthController.text;
                                    shipmentList[index].height =
                                        _editHeigthController.text;
                                    shipmentList[index].length =
                                        _editLengthController.text;
                                    shipmentList[index].quantity =
                                        noOfPieces.toString();
                                    shipmentList[index].noOfCartoons =
                                        noOfCartons.toString();
                                  });

                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                      },
                    );
                  },
                  child: Icon(Icons.edit)),
            ],
          ),
        ),
        Container(
          child: AutoSizeText(packaging ?? "",
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black)),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          alignment: Alignment.centerRight,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].noOfCartoons ?? "0",
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black)),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          alignment: Alignment.centerRight,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].quantity ?? "1",
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black)),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          alignment: Alignment.centerRight,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].weight.toString(),
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black)),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          alignment: Alignment.centerRight,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].height.toString(),
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black)),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          alignment: Alignment.centerRight,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].width.toString(),
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black)),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          alignment: Alignment.centerRight,
        ),
        Container(
          child: AutoSizeText(shipmentList[index].length.toString(),
              style: TextStyle(
                  color: shipmentList[index].inValidPhones
                      ? Colors.red
                      : Colors.black)),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }


  _floatingButton() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  showText = false;
                  showTextField = false;
                  showScanner = true;
                });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Camera scanning'.tr(),
                        style: TextStyle(color: primaryColor, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: primaryColor,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  showScanner = false;
                  showTextField = false;
                  showText = true;
                });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.barcodeScan,
                        size: 40,
                        color: primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Gun Scanning'.tr(),
                        style: TextStyle(color: primaryColor, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: primaryColor,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  showScanner = false;
                  showText = false;
                  showTextField = true;
                });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 40,
                        color: primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Manual entry'.tr(),
                        style: TextStyle(color: primaryColor, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: primaryColor,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  showScanner = false;
                  showText = false;
                });
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calculate,
                        size: 40,
                        color: primaryColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Calculate price'.tr(),
                        style: TextStyle(color: primaryColor, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
