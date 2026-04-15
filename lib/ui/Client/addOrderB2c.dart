import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_field/date_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// MIGRATION: import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/post_order_controller.dart';
import 'package:Fulgox/controllers/get_orders_controller.dart';
import 'package:get/get.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/memberBalanceModel.dart';
import 'package:Fulgox/data_providers/models/postOrderData.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/Client/AddingNewOrderSuccess.dart';
import 'package:Fulgox/ui/Client/paymentMethod_dialog.dart';
import 'package:Fulgox/ui/courier/captainDashboard.dart';
import 'package:Fulgox/ui/custom%20widgets/dialog.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/ui/custom%20widgets/customCheckBox.dart';
import 'package:Fulgox/ui/custom%20widgets/packageCard.dart';
import 'package:Fulgox/ui/custom%20widgets/packageCardB2C.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'MyOrders.dart';
import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/drawerClient.dart';

class MyCityModel {
  String? name;
  String? id;
  MyCityModel({this.name, this.id});
}

class AddOrderB2C extends StatefulWidget {
  ResourcesData? resourcesData;
  ProfileDataModel? dashboardDataModelNew;
  String packagingType;
  GetOrdersController? getOrdersController;
  bool fromHomeScreen = false;
  OrdersDataModelMix? ordersDataModel;
  AddOrderB2C(
      {this.resourcesData,
      this.dashboardDataModelNew,
      this.ordersDataModel,
      this.getOrdersController,
      this.fromHomeScreen = false,
      this.packagingType = "noPackaging"});
  @override
  _AddOrderB2CState createState() => _AddOrderB2CState();
}

class _AddOrderB2CState extends State<AddOrderB2C> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool showOrdersAdding = true;
  List<OrdersDataModelMix> ordersList = [];
  double? width, height;
  double? screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();

    ever(postOrderController.success, (bool success) {
      if (success) {
        final progress = ProgressHUD.of(context);
        progress?.dismiss();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  SuccessOrderScreen(
                    dashboardDataModel:
                        widget.dashboardDataModelNew,
                    resourcesData: widget.resourcesData,
                    fromHomeScreen: widget.fromHomeScreen,
                    getOrdersController: widget.getOrdersController,
                  )),
        );
      }
    });

    ever(postOrderController.editSuccess, (bool success) {
      if (success) {
        final progress = ProgressHUD.of(context);
        progress?.dismiss();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    MyOrdersScreen(
                      dashboardDataModel:
                          widget.dashboardDataModelNew,
                      resourcesData: widget.resourcesData,
                    )),
            (route) => false);
      }
    });

     ever(postOrderController.popLoading, (bool pop) {
        if(pop) {
             // Logic for popLoading? The original code had:
             // if (state is PopLoading) { Navigator.pop(context); }
             // But it was commented out in build method block?
             // Ah, line 161 in build method: // if (state is PopLoading) ...
             // Let's check if it's used.
        }
    });

    ever(postOrderController.isLoading, (bool loading) {
      final progress = ProgressHUD.of(context);
      if (loading) {
        progress?.show();
      } else {
        progress?.dismiss();
      }
    });

    ever(postOrderController.errorMessage, (String error) {
      if (error.isNotEmpty && !postOrderController.isLoading.value) {
        if (error == "TIMEOUT") {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return NetworkErrorView();
              });
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        } else if (error == "invalidToken") {
          GeneralHandler.handleInvalidToken(context);
        } else if (error == 'needUpdate') {
          GeneralHandler.handleNeedUpdateState(context);
        } else if (error == "general") {
          GeneralHandler.handleGeneralError(context);
        } else {
             if(postOrderController.errorList.isNotEmpty) {
                 _onWidgetDidBuild(context, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Container(
                          width: screenWidth,
                          height: screenHeight! * 0.1,
                          child: ListView.builder(
                            itemCount: postOrderController.errorList.length,
                            itemBuilder: (context, i) {
                              return Text(postOrderController.errorList[i].toString());
                            },
                          ),
                        ),
                      ),
                    );
                  });
             }
        }
      }
    });
  }

  final PostOrderController postOrderController = Get.put(PostOrderController());

  @override
  void dispose() {
    // postOrderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    screenWidth = size.width;
    screenHeight = size.height;
    return ProgressHUD(
      barrierEnabled: false,
      backgroundColor: Constants.blueColor,
      child: Scaffold(
          backgroundColor: Constants.clientBackgroundGrey,
          key: _drawerKey,
          body: Column(
            children: [
              widget.ordersDataModel == null
                  ? const ClientAppBar()
                  : Container(),
              Expanded(
                child: Container(
                  color: Constants.clientBackgroundGrey,
                  child: _buildAddOrderScreen(),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildAddOrderScreen() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ButtonTheme(
                      height: 50,
                      child: ElevatedButton(
                          child: Text(
                            'Add shipment'.tr(),
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              showOrdersAdding = true;
                            });
                          }),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: screenHeight! * 0.7,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ordersList.isNotEmpty
                          ? ListView.builder(
                              itemCount: ordersList.length,
                              itemBuilder: (context, i) {
                                return PackageCardB2C(
                                  ordersDataModelMix: ordersList[i],
                                  deleteBtnFun: () {
                                    setState(() {
                                      ordersList.removeAt(i);
                                    });
                                  },
                                  packagesList: ordersList,
                                  index: i,
                                );
                              })
                          : EmptyView(
                              text: 'Tap to add shipments'.tr(),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
              showOrdersAdding
                  ? B2cOrderCreation(
                      resourcesData: widget.resourcesData,
                      dashboardDataModelNew: SavedData.profileDataModel,
                      newOrder: (v) {
                        setState(() {
                          showOrdersAdding = false;
                          ordersList.add(v);
                        });
                      },
                      showAddingOrder: (v) {
                        setState(() {
                          showOrdersAdding = v;
                        });
                      },
                    )
                  : SizedBox(),
              ordersList.isNotEmpty ? _floatingButton() : SizedBox(),
            ],
          ),
        ),
        showOrdersAdding
            ? SizedBox()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ButtonTheme(
                  height: 50,
                  minWidth: screenWidth!,
                  child: ElevatedButton(
                      child: Text(
                        'Place the order'.tr(),
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () {
                        if (ordersList.isNotEmpty) {
                          postOrderController.addB2cOrder(ordersList: ordersList);
                        }
                      }),
                ),
              ),
      ],
    );
  }

  _floatingButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: FittedBox(
            child: Stack(
              alignment: Alignment(1.4, -1.5),
              children: [
                FloatingActionButton(
                  // Your actual Fab
                  onPressed: () {
                    setState(() {
                      showOrdersAdding = true;
                    });
                  },
                  child: Icon(MdiIcons.dropbox),
                ),
                Container(
                  // This is your Badge
                  child: Center(
                    // Here you can put whatever content you want inside your Badge
                    child: Text(ordersList.length.toString(),
                        style: TextStyle(color: Colors.white)),
                  ),
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(minHeight: 32, minWidth: 32),
                  decoration: BoxDecoration(
                    // This controls the shadow
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 1,
                          blurRadius: 5,
                          color: Colors.black.withAlpha(50))
                    ],
                    borderRadius: BorderRadius.circular(16),
                    color:
                        Constants.blueColor, // This would be color of the Badge
                  ),
                ),
              ],
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

class B2cOrdersList extends StatefulWidget {
  ResourcesData resourcesData;
  ProfileDataModel profileDataModel;
  List<OrdersDataModelMix> ordersList;

  B2cOrdersList(
      {required this.profileDataModel,
      required this.resourcesData,
      required this.ordersList});

  @override
  _B2cOrdersListState createState() => _B2cOrdersListState();
}

class _B2cOrdersListState extends State<B2cOrdersList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class B2cOrderCreation extends StatefulWidget {
  ResourcesData? resourcesData;
  OrdersDataModelMix? ordersDataModel;
  ProfileDataModel? dashboardDataModelNew;
  String? packagingType;
  final ValueChanged<OrdersDataModelMix> newOrder;
  final ValueChanged<bool> showAddingOrder;

  B2cOrderCreation(
      {this.dashboardDataModelNew,
      this.ordersDataModel,
      this.resourcesData,
      required this.newOrder,
      required this.showAddingOrder,
      this.packagingType});
  @override
  _B2cOrderCreationState createState() => _B2cOrderCreationState();
}

class _B2cOrderCreationState extends State<B2cOrderCreation> {
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _senderMapController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _receiverFloor = TextEditingController();
  final _receiverBuildingController = TextEditingController();
  final _receiverFlatController = TextEditingController();
  final searchBoxCityController = TextEditingController();
  final searchBoxZoneController = TextEditingController();
  final searchBoxCityRController = TextEditingController();
  final searchBoxZoneRController = TextEditingController();
  final _arCodeController = TextEditingController();
  final _enCodeController = TextEditingController();

  FocusNode senderNameFocus = FocusNode();
  FocusNode senderPhoneFocus = FocusNode();
  FocusNode senderCityFocus = FocusNode();
  FocusNode senderAddressFocus = FocusNode();
  FocusNode senderPickupTimeFocus = FocusNode();
  FocusNode receiverNameFocus = FocusNode();
  FocusNode receiverPhoneFocus = FocusNode();
  FocusNode receiverCityFocus = FocusNode();
  FocusNode receiverAddressFocus = FocusNode();
  FocusNode receiverBuildingFocus = FocusNode();
  FocusNode receiverFloorFocus = FocusNode();
  FocusNode receiverFlatFocus = FocusNode();
  FocusNode zoneFocus = FocusNode();
  FocusNode zoneFocusReceiver = FocusNode();

  ErCity? _currentCitySelected = ErCity();
  ErCity? _currentReceiverCitySelected = ErCity();
  Neighborhoods? _currentZone = Neighborhoods();
  Neighborhoods? _currentZoneReceiver = Neighborhoods();

  bool fragileCheckedValue = false;

  final _codController = TextEditingController();
  final _packageCommentController = TextEditingController();
  final _noteCommentController = TextEditingController();
  final _quantityController = TextEditingController();
  double codDoubleValue = 0;
  bool codCheckedValue = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  double? width, height;
  double? screenWidth, screenHeight;
  List<Packages> packagesList = [];
  double totalPrice = 0;
  PostOrderDataModel _postOrderDataModel = PostOrderDataModel();
  List<double> sumPrice = [];
  // LocationResult _pickedLocation;
  // MIGRATION: PickResult? _pickedLocation;
  bool locationSelected = false;
  bool locationSelectedReceiver = false;
  // LocationResult _delivePickedLocation;
  // MIGRATION: PickResult? _deliverPickedLocation;
  bool checkedValue2 = false;
  String? pickuplMaplLink;
  String? deliverMapLink;
  String? mapUrlSender;
  String? mapUrlReceiver;
  
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserRepository userRepository = UserRepository();
  ProfileDataModel dashboardDataModel = ProfileDataModel();
  Addresses? _currentSelectedAddress;
  Weight? _currentSelectedWeight;
  Packaging? _currentSelectedPackaging = Packaging();
  bool iamSender = true;
  List<ErCity> senderCities = [];
  List<ErCity> receiverCities = [];
  bool receiverPayCheckedValue = false;
  bool deductFromOfferCheckedValue = false;
  bool payAtPickupChecked = false;
  bool deductFromCod = false;
  String building = 'building';
  String floor = 'floor';
  String flat = 'flat';
  bool startValidation = false;
  bool missData = false;
  bool commonError = false;
  bool missData2 = false;
  bool showReceiverPay = true;
  Color addPackageDarkColor = Color(0xFFFAD824);
  Color addPackageLightColorColor = Color(0xFFFAD824);
  Color backgroundColor = Constants.clientBackgroundGrey;
  final _packageLengthController = TextEditingController();
  final _packageWidthController = TextEditingController();
  final _packageHeightController = TextEditingController();
  final _packageWeightController = TextEditingController();
  final _packageExtraController = TextEditingController();
  late int day = DateTime.now().day;
  late int month = DateTime.now().month;
  late int year = DateTime.now().year;
  // TimeOfDay? pickedTime = TimeOfDay.now();
  final initialTime = TimeOfDay.now();
  int hour = TimeOfDay.now().hour;
  int minute = TimeOfDay.now().minute;
  // String pickupTime = "" ;
  DateTime pickupTime = DateTime.now();
  late Packages edtitedPackage;
  bool unsupportedPackaging = false;

  bool showOrdersAdding = true;

  DateTime currentDate = DateTime.now();
  String? paymentMethod;

  PaymentMethods? paymentMethods;

  bool phoneValidation(String value) {
    if (value.length == 9 && value.characters.first == '5') {
      return true;
    }
    return false;
  }

  _onLoginButtonPressed() {
    startValidation = true;
    if (_formKey.currentState!.validate()) {
      if (paymentMethods == null) {
        ComFunctions.showToast(text: "Please select the payment method".tr());
        return;
      }
      building =
          _receiverBuildingController.text.isNotEmpty ? 'building'.tr() : '';
      flat = _receiverFlatController.text.isNotEmpty ? 'flat'.tr() : '';
      floor = _receiverFloor.text.isNotEmpty ? 'floor'.tr() : '';
      if ((receiverPayCheckedValue || _codController.text.isNotEmpty) &&
          _currentReceiverCitySelected?.cod == "0") {
        missData2 = true;
      } else {
        missData2 = false;
      }
      if (_currentReceiverCitySelected?.cod == "0" &&
          _currentSelectedPackaging?.id == "4") {
        unsupportedPackaging = true;
      } else {
        unsupportedPackaging = false;
      }
      if (missData2) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('Note !'.tr()),
                  content: Text(
                    'cash on delivery services is not available in this receiver city'
                        .tr(),
                    style: TextStyle(fontSize: 15),
                  ),
                  actions: [
                    ElevatedButton(
                      child: Text('ok'.tr()),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ]);
            });
      } else if (unsupportedPackaging) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('Note !'.tr()),
                  content: Text(
                    'The cold packaging is not supported for the selected receiver city'
                        .tr(),
                    style: TextStyle(fontSize: 15),
                  ),
                  actions: [
                    ElevatedButton(
                      child: Text('ok'.tr()),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ]);
            });
      } else {
        if (_currentCitySelected!.name == null || _currentZone!.name == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                width: screenWidth,
                height: screenHeight! * 0.1,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, i) {
                    return Text("Please select the sender city and zone".tr());
                  },
                ),
              ),
            ),
          );
        } else if (_currentReceiverCitySelected!.name == null ||
            _currentZoneReceiver!.name == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                width: screenWidth,
                height: screenHeight! * 0.1,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, i) {
                    return Text(
                        "Please select the receiver city and zone".tr());
                  },
                ),
              ),
            ),
          );
        } else {
          OrdersDataModelMix orderData = OrdersDataModelMix();
          // _postOrderDataModel.packages = packagesList;

          orderData.senderName = _senderNameController.text;
          orderData.senderPhone = _senderPhoneController.text;
          orderData.pickupNeighborhood = _currentZone?.id;
          orderData.pickupAddress = _senderAddressController.text;
          orderData.pickupMap = mapUrlSender;
          // _postOrderDataModel.pickupTime = _currentTimeSelected!.id;
          orderData.pickupTime = pickupTime.toString();
          orderData.receiverName = _receiverNameController.text;
          orderData.receiverPhone = _receiverPhoneController.text;
          orderData.deliverNeighborhood = _currentZoneReceiver?.id;
          orderData.deliverCity = _currentReceiverCitySelected?.id;
          orderData.pickupCity = _currentCitySelected?.id;
          if (_receiverAddressController.text.isEmpty &&
              _receiverBuildingController.text.isEmpty &&
              _receiverFloor.text.isEmpty &&
              _receiverFlatController.text.isEmpty) {
            orderData.deliverAddress = '';
          } else {
            orderData.deliverAddress =
                "${_receiverAddressController.text} $building ${_receiverBuildingController.text} $floor ${_receiverFloor.text} $flat ${_receiverFlatController.text}";
          }
          orderData.deliverMap = mapUrlReceiver;
          // _postOrderDataModel.deliverTime = "0";
          // editedOrderModel.deliverTime = "0";
          orderData.rc = receiverPayCheckedValue ? "1" : "0";
          orderData.deductFromCod = deductFromCod ? "1" : "0";

          orderData.packaging = _currentSelectedPackaging?.id;
          orderData.cod = codCheckedValue ? _codController.text : "0";
          orderData.fragile = fragileCheckedValue ? "1" : "0";
          orderData.quantity = _quantityController.text.isNotEmpty
              ? _quantityController.text
              : "1";
          orderData.comment = _packageCommentController.text;
          orderData.weight = _packageWeightController.text;
          orderData.length = _packageLengthController.text;
          orderData.width = _packageWidthController.text;
          orderData.height = _packageHeightController.text;
          orderData.note = _noteCommentController.text;
          orderData.payment_method = paymentMethods?.id;
          print('rc $receiverPayCheckedValue');
          print('rc ${orderData.rc}');
          print('late payment $deductFromCod');
          print('late payment ${orderData.deductFromCod}');

          setState(() {
            widget.newOrder(orderData);
          });
          if (widget.ordersDataModel != null) {
            Navigator.of(context).pop();
          }
        }

        // if(mapUrlSender == '' || locationSelected == false){
        //
        //   _onWidgetDidBuild(context, () {
        //     _drawerKey.currentState.showSnackBar(
        //       SnackBar(
        //         content: Text('please select the sender location on google map'.tr() , style: TextStyle(
        //             color: Colors.white
        //         ),),
        //         color: Colors.red,
        //       ),
        //     );
        //   });
        // }
        // else{
        //
        //
        //
        // }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            width: screenWidth,
            height: screenHeight! * 0.1,
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, i) {
                return Text("Some mandatory fields is empty".tr());
              },
            ),
          ),
        ),
      );
    }
  }

  restoreData() {
    setState(() {
      _senderNameController.text = widget.dashboardDataModelNew?.name ?? "";
      _senderPhoneController.text = widget.dashboardDataModelNew?.phone ?? "";
      if ((widget.dashboardDataModelNew?.addresses?.length ?? 0) > 0) {
        _currentSelectedAddress = widget.dashboardDataModelNew?.addresses?[0];
        for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0); i++) {
          for (int x = 0;
              x < (widget.resourcesData?.city?[i].neighborhoods?.length ?? 0);
              x++) {
            if (_currentSelectedAddress?.city ==
                widget.resourcesData?.city?[i].neighborhoods?[x].id) {
              _currentCitySelected = widget.resourcesData?.city?[i];
              _currentZone = widget.resourcesData?.city?[i].neighborhoods?[x];
            }
          }
        }
        _senderAddressController.text =
            widget.dashboardDataModelNew?.addresses?[0].description ?? "";

        if (widget.dashboardDataModelNew?.addresses?[0].map != '') {
          locationSelected = true;
          mapUrlSender = widget.dashboardDataModelNew?.addresses?[0].map;
        }
      }
    });
  }

  clearData() {
    _senderNameController.clear();
    _senderPhoneController.clear();
    _senderAddressController.clear();
    locationSelected = false;
    mapUrlSender = '';
    _currentCitySelected = ErCity();
    _currentZone = Neighborhoods();
  }

  resetGoogleMaps() {
    setState(() {
      mapUrlSender = '';
      locationSelected = false;
    });
  }

  setGoogleMaps(String? map) {
    setState(() {
      mapUrlSender = map;
      locationSelected = true;
    });
  }

  getAddress() async {
    if (widget.ordersDataModel == null) {
      if ((widget.dashboardDataModelNew?.addresses?.length ?? 0) > 0) {
        setState(() {
          _currentSelectedAddress = widget.dashboardDataModelNew?.addresses?[0];

          for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0); i++) {
            for (int x = 0;
                x < (widget.resourcesData?.city?[i].neighborhoods?.length ?? 0);
                x++) {
              if (_currentSelectedAddress?.city ==
                  widget.resourcesData?.city?[i].neighborhoods?[x].id) {
                _currentCitySelected = widget.resourcesData?.city?[i];
                _currentZone = widget.resourcesData!.city?[i].neighborhoods?[x];
              }
            }
          }

          _senderAddressController.text =
              widget.dashboardDataModelNew?.addresses?[0].description ?? "";
          if (widget.dashboardDataModelNew?.addresses?[0].map != '') {
            locationSelected = true;
            mapUrlSender = widget.dashboardDataModelNew?.addresses?[0].map;
          }
        });
      } else {}

      _senderNameController.text = widget.dashboardDataModelNew?.name ?? "";
      _senderPhoneController.text = widget.dashboardDataModelNew?.phone ?? "";
    }
  }

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
      });
    }
  }

  claculateTotalPrice() {
    if (widget.ordersDataModel == null) {
      if (packagesList.isEmpty) {
        totalPrice = 0;
      }
      double x = 0;
      for (int i = 0; i < sumPrice.length; i++) {
        x += sumPrice[i];
      }
      setState(() {
        totalPrice = x;
      });
    } else {
      setState(() {
        totalPrice = packagesList.first.price ?? 0.0;
      });
    }
  }

  getOrderData() async {
    setState(() {
      receiverPayCheckedValue = widget.ordersDataModel?.rc != "0" &&
              widget.ordersDataModel?.rc != "" &&
              widget.ordersDataModel?.rc != ""
          ? true
          : false;

      deductFromCod = widget.ordersDataModel?.deductFromCod != "0" &&
              widget.ordersDataModel?.deductFromCod != "" &&
              widget.ordersDataModel?.deductFromCod != ""
          ? true
          : false;

      codCheckedValue = widget.ordersDataModel?.cod != null &&
              widget.ordersDataModel?.cod != "" &&
              widget.ordersDataModel?.cod != "0"
          ? true
          : false;

      _codController.text = widget.ordersDataModel?.cod ?? "";

      List<ErCity> senderCities = [];
      List<ErCity> receiverCities = [];
      senderCities.addAll((widget.resourcesData?.city ?? [])
          .where((element) =>
              element.send == "1" && (element.neighborhoods?.length ?? 0) > 0)
          .toList());
      receiverCities.addAll((widget.resourcesData?.city ?? [])
          .where((element) =>
              element.receive == "1" && element.neighborhoods!.length > 0)
          .toList());

      for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0); i++) {
        for (int x = 0;
            x < (widget.resourcesData?.city?[i].neighborhoods?.length ?? 0);
            x++) {
          if (widget.ordersDataModel?.pickupNeighborhood ==
              widget.resourcesData?.city?[i].neighborhoods?[x].id) {
            _currentCitySelected = widget.resourcesData?.city?[i];
            _currentZone = widget.resourcesData?.city?[i].neighborhoods?[x];
          }
        }
      }

      for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0); i++) {
        for (int x = 0;
            x < (widget.resourcesData?.city?[i].neighborhoods?.length ?? 0);
            x++) {
          if (widget.ordersDataModel?.deliverNeighborhood ==
              widget.resourcesData?.city?[i].neighborhoods?[x].id) {
            _currentReceiverCitySelected = widget.resourcesData?.city?[i];
            _currentZoneReceiver =
                widget.resourcesData?.city?[i].neighborhoods?[x];
          }
        }
      }

      for (int i = 0; i < SavedData.resourcesData.packaging!.length; i++) {
        if (widget.ordersDataModel?.packaging ==
            SavedData.resourcesData.packaging![i].id) {
          _currentSelectedPackaging = SavedData.resourcesData.packaging![i];
        }
      }

      checkedValue2 = false;
      _senderNameController.text = widget.ordersDataModel?.senderName ?? "";
      _senderPhoneController.text = widget.ordersDataModel?.senderPhone ?? "";
      _senderAddressController.text =
          widget.ordersDataModel?.pickupAddress ?? "";
      if (widget.ordersDataModel?.pickupMap != null &&
          widget.ordersDataModel?.pickupMap != '') {
        locationSelected = true;
        mapUrlSender = widget.ordersDataModel?.pickupMap;
      }
      // for (int i = 0; i < widget.resourcesData!.times!.length; i++) {
      //   if (widget.ordersDataModel!.pickupTime ==
      //       widget.resourcesData!.times![i].id) {
      //     _currentTimeSelected = widget.resourcesData!.times![i];
      //   }
      // }
      if ((widget.ordersDataModel?.pickupTime.toString().length ?? 0) > 1) {
        // pickupTime = widget.ordersDataModel!.pickupTime.toString();
        try {
          pickupTime = DateTime.parse(
              widget.ordersDataModel?.pickupTime.toString() ?? "");
        } catch (e) {
          pickupTime = DateTime.now();
        }
      } else {
        pickupTime = DateTime.now();
      }
      _receiverNameController.text = widget.ordersDataModel?.receiverName ?? "";
      _receiverPhoneController.text =
          widget.ordersDataModel?.receiverPhone ?? "";
      _receiverAddressController.text =
          widget.ordersDataModel?.deliverAddress ?? "";
      if (widget.ordersDataModel?.deliverMap != null &&
          widget.ordersDataModel?.deliverMap != '') {
        locationSelectedReceiver = true;
        mapUrlReceiver = widget.ordersDataModel?.deliverMap;
      }

      fragileCheckedValue =
          widget.ordersDataModel?.fragile == "1" ? true : false;
      _quantityController.text = widget.ordersDataModel?.quantity ?? "";
      _packageCommentController.text = widget.ordersDataModel?.comment ?? "";
      _packageWeightController.text = widget.ordersDataModel?.weight ?? "";
      _packageHeightController.text = widget.ordersDataModel?.height ?? "";
      _packageWidthController.text = widget.ordersDataModel?.width ?? "";
      _packageLengthController.text = widget.ordersDataModel?.length ?? "";
      _noteCommentController.text = widget.ordersDataModel?.note ?? "";
    });
  }

  setThePackagingType() {
    try {
      switch (widget.packagingType) {
        case "noPackaging":
          {
            _currentSelectedPackaging = widget.resourcesData?.packaging?[0];
            addPackageDarkColor = Color(0xFFFAD824);
            addPackageLightColorColor = Color(0xFFFBE56E).withOpacity(0.1);
            backgroundColor = Constants.clientBackgroundGrey;
          }
          break;

        case "liquid":
          {
            _currentSelectedPackaging = widget.resourcesData?.packaging?[2];
            addPackageDarkColor = Color(0xFF66c93d);
            addPackageLightColorColor = Color(0xFF8ED770).withOpacity(0.1);
            backgroundColor = Color(0xFF66c93d).withOpacity(0.15);
          }
          break;
        case "frozen":
          {
            _currentSelectedPackaging = widget.resourcesData?.packaging?[1];
            addPackageDarkColor = Color(0xFF72a6f5);
            addPackageLightColorColor = Color(0xFFC6DBFB).withOpacity(0.1);
            backgroundColor = Color(0xFF72a6f5).withOpacity(0.15);
          }
          break;
        default:
          {
            _currentSelectedPackaging = widget.resourcesData?.packaging?[0];
            backgroundColor = Constants.clientBackgroundGrey;
          }
          break;
      }
    } catch (e) {
      print(e);
      _currentSelectedPackaging = widget.resourcesData?.packaging?[0];
      addPackageDarkColor = Color(0xFFFAD824);
      addPackageLightColorColor = Color(0xFFFBE56E).withOpacity(0.1);
      backgroundColor = Constants.clientBackgroundGrey;
    }
    if (_currentSelectedPackaging?.name == null) {
      _currentSelectedPackaging = widget.resourcesData?.packaging?[0];
    }
  }

  @override
  void initState() {
    pickupTime = DateTime.now();
    if (widget.ordersDataModel != null) {
      getOrderData();
    }
    try {
      setThePackagingType();
      senderCities.addAll((widget.resourcesData?.city ?? [])
          .where((element) =>
              element.send == "1" && element.neighborhoods!.length > 0)
          .toList());
      receiverCities.addAll((widget.resourcesData?.city ?? [])
          .where((element) =>
              element.receive == "1" && element.neighborhoods!.length > 0)
          .toList());
      getAddress();
    } catch (e) {
      // postOrderBloc.add(PostOrdersEventGenerateError());
    }
    super.initState();
  }

  @override
  void dispose() {
    senderNameFocus.dispose();
    senderPhoneFocus.dispose();
    senderCityFocus.dispose();
    senderAddressFocus.dispose();
    senderPickupTimeFocus.dispose();
    receiverNameFocus.dispose();
    receiverPhoneFocus.dispose();
    receiverCityFocus.dispose();
    receiverAddressFocus.dispose();
    receiverBuildingFocus.dispose();
    receiverFloorFocus.dispose();
    receiverFlatFocus.dispose();
    zoneFocus.dispose();
    zoneFocusReceiver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _enCodeController.text = '+966';
    _arCodeController.text = '966+';
    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    screenWidth = size.width;
    screenHeight = size.height;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: Colors.grey.withOpacity(0.7)),
          Container(
            color: Constants.clientBackgroundGrey,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    widget.ordersDataModel == null
                        ? Row(
                            children: [
                              InkWell(
                                  onTap: () {
                                    widget.showAddingOrder(false);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Add shipment".tr(),
                              )
                            ],
                          )
                        : SizedBox(
                            height: 30,
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'Sender Data'.tr(),
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Container(
                                      height: 1,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          checkedValue2 = !checkedValue2;
                                          if (checkedValue2) {
                                            clearData();
                                          } else {
                                            restoreData();
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 180,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: checkedValue2
                                                    ? Constants.blueColor
                                                    : Colors.grey)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                unselectedWidgetColor:
                                                    Constants.blueColor,
                                              ),
                                              child: SizedBox(
                                                  height: 20.0,
                                                  width: 20.0,
                                                  child: CustomCheckBox(
                                                    checkedColor:
                                                        Constants.blueColor,
                                                    unCheckedColor: Colors.grey,
                                                    backgroundColor:
                                                        Colors.white,
                                                    checked: checkedValue2,
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              'Unregistered info'.tr(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: checkedValue2
                                                      ? Constants.blueColor
                                                      : Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (widget.dashboardDataModelNew?.addresses
                                                  ?.length ??
                                              0) >
                                          0 &&
                                      !checkedValue2
                                  ? Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        height: screenHeight! * 0.06,
                                        width: screenWidth! * 0.94,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Constants.blueColor
                                                    .withOpacity(0.4)),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Row(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Center(
                                                  child: Text(
                                                    'My Addresses'.tr(),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87),
                                                  ),
                                                )),
                                            Expanded(
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child:
                                                    DropdownButton<Addresses>(
                                                  onTap: () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  items: widget
                                                      .dashboardDataModelNew
                                                      ?.addresses
                                                      ?.map((Addresses
                                                          dropDownStringItem) {
                                                    return DropdownMenuItem<
                                                        Addresses>(
                                                      value: dropDownStringItem,
                                                      child: AutoSizeText(
                                                        dropDownStringItem
                                                            .title!
                                                            .tr(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 13),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (Addresses? newValue) {
                                                    setState(() {
                                                      _currentSelectedAddress =
                                                          newValue;

                                                      checkedValue2 = false;
                                                      if (_currentSelectedAddress!
                                                              .map ==
                                                          '') {
                                                        resetGoogleMaps();
                                                      } else {
                                                        setGoogleMaps(
                                                            _currentSelectedAddress!
                                                                .map);
                                                      }
                                                      _senderAddressController
                                                              .text =
                                                          _currentSelectedAddress!
                                                              .description!;

                                                      for (int i = 0;
                                                          i <
                                                              (widget
                                                                      .resourcesData
                                                                      ?.city
                                                                      ?.length ??
                                                                  0);
                                                          i++) {
                                                        for (int x = 0;
                                                            x <
                                                                (widget
                                                                        .resourcesData!
                                                                        .city![
                                                                            i]
                                                                        .neighborhoods
                                                                        ?.length ??
                                                                    0);
                                                            x++) {
                                                          if (_currentSelectedAddress
                                                                  ?.city ==
                                                              widget
                                                                  .resourcesData
                                                                  ?.city![i]
                                                                  .neighborhoods?[
                                                                      x]
                                                                  .id) {
                                                            _currentCitySelected =
                                                                widget
                                                                    .resourcesData
                                                                    ?.city?[i];
                                                            _currentZone = widget
                                                                .resourcesData
                                                                ?.city?[i]
                                                                .neighborhoods![x];
                                                          }
                                                        }
                                                      }
                                                    });
                                                  },
                                                  value:
                                                      _currentSelectedAddress,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  : Container(),
                            ],
                          ),
                          buildSenderData(),
                          Row(
                            children: [
                              Text(
                                'Pickup Time'.tr(),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: DateTimeFormField(
                              decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Pickup time'.tr(),
                                suffixIcon: Icon(
                                  Icons.event_note,
                                  color: Constants.blueColor,
                                ),
                              ),
                              mode: DateTimeFieldPickerMode.dateAndTime,
                              dateFormat: DateFormat('yyyy-MM-dd hh:mm aaa'),
                              onChanged: (DateTime? value) {
                                pickupTime = value!;
                              },
                              onSaved: (value) {
                                pickupTime = value ?? DateTime.now();
                              },
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'Receiver Data'.tr(),
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Container(
                                      height: 1,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          EasyLocalization.of(context)!.locale == Locale('en')
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          readOnly: true,
                                          validator: (String? value) {
                                            if (_receiverPhoneController
                                                .text.isEmpty) {
                                              return '';
                                            }
                                            if (!phoneValidation(
                                                _receiverPhoneController
                                                    .text)) {
                                              return '';
                                            }
                                            return null;
                                          },
                                          textAlign: TextAlign.center,
                                          decoration:
                                              kTextFieldDecoration2.copyWith(
                                                  contentPadding:
                                                      EdgeInsets.all(0),
                                                  hintText: ''),
                                          controller: _enCodeController,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      // Expanded(
                                      //   flex: 3,
                                      //   child: TypeAheadFormField(
                                      //     getImmediateSuggestions: false ,
                                      //     hideOnEmpty: true,
                                      //     hideOnError: true,
                                      //     suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                      //         color: Constants.blueColor,
                                      //         borderRadius: BorderRadius.circular(12)
                                      //     ),
                                      //     textFieldConfiguration: TextFieldConfiguration(
                                      //         autofocus: false,
                                      //         decoration: kTextFieldDecoration2.copyWith(
                                      //           contentPadding: EdgeInsets.all(15),
                                      //           hintText: '5xx-xxx-xxx',),
                                      //         keyboardType: TextInputType.number,
                                      //         inputFormatters: [
                                      //           LengthLimitingTextInputFormatter(9),
                                      //           FilteringTextInputFormatter.digitsOnly
                                      //         ],
                                      //         controller: _receiverPhoneController
                                      //     ),
                                      //     validator: (String? value) {
                                      //       if (value!.isEmpty) {
                                      //         return 'Please enter your mobile'.tr();
                                      //       }
                                      //       if (!phoneValidation(value)) {
                                      //         return 'please enter a valid mobile number'
                                      //             .tr();
                                      //       }
                                      //       return null;
                                      //     },
                                      //     suggestionsCallback: (pattern) async {
                                      //       if(pattern.length > 3){
                                      //         return await EventsAPIs.getSuggestedAddress(pattern: pattern);

                                      //       }
                                      //       return [];
                                      //     },
                                      //     noItemsFoundBuilder:(BuildContext context){
                                      //       return SizedBox();
                                      //     },
                                      //     itemBuilder: (context, suggestion) {
                                      //       return Column(
                                      //         children: [
                                      //           ListTile(
                                      //               title: Text(((suggestion as Map)['receiverName'] ?? ""),style: TextStyle(color: Colors.white, ),
                                      //               subtitle: Text(suggestion['receiverPhone'] ?? "",style: TextStyle(color: Colors.white))
                                      //           ),
                                      //           Divider(color: Colors.white, thickness: 2,)
                                      //         ],
                                      //       );
                                      //     },
                                      //     onSuggestionSelected: (suggestion) {
                                      //       _receiverNameController.text = (suggestion as Map)['receiverName'] ;
                                      //       _receiverPhoneController.text = suggestion['receiverPhone'] ;
                                      //       for(int i = 0 ; i < receiverCities.length ; i ++){
                                      //         if(suggestion['deliverCity'] == receiverCities[i].id){
                                      //           _currentReceiverCitySelected = receiverCities[i] ;
                                      //         }
                                      //       }
                                      //       for(int i = 0 ; i < (_currentReceiverCitySelected?.neighborhoods?.length ?? 0) ; i ++){
                                      //         if(suggestion['deliverNeighborhood'] == _currentReceiverCitySelected?.neighborhoods?[i].id){
                                      //           _currentZoneReceiver = _currentReceiverCitySelected?.neighborhoods?[i] ;
                                      //         }
                                      //       }
                                      //       mapUrlReceiver = suggestion['deliverMap'] ;
                                      //       if(mapUrlReceiver != null && mapUrlReceiver != "" ){
                                      //         locationSelectedReceiver = true ;
                                      //       }else {
                                      //         locationSelectedReceiver = false ;
                                      //       }
                                      //       setState(() {});
                                      //     },

                                      //   ),
                                      //   // child: TextFormField(
                                      //   //   key: const ValueKey('receiverPhone'),
                                      //   //   focusNode: receiverPhoneFocus,
                                      //   //   keyboardType: TextInputType.number,
                                      //   //   onChanged: (e) {
                                      //   //     if (startValidation) {
                                      //   //       _formKey.currentState!.validate();
                                      //   //     }
                                      //   //   },
                                      //   //   validator: (String? value) {
                                      //   //     if (value!.isEmpty) {
                                      //   //       return 'Please enter your mobile'.tr();
                                      //   //     }
                                      //   //     if (!phoneValidation(value)) {
                                      //   //       return 'please enter a valid mobile number'
                                      //   //           .tr();
                                      //   //     }
                                      //   //     return null;
                                      //   //   },
                                      //   //   inputFormatters: [
                                      //   //     LengthLimitingTextInputFormatter(9),
                                      //   //     FilteringTextInputFormatter.digitsOnly
                                      //   //   ],
                                      //   //   decoration: kTextFieldDecoration2.copyWith(
                                      //   //     labelText: 'phone number'.tr(),
                                      //   //     hintText: '5xx-xxx-xxx',
                                      //   //     border: null,
                                      //   //     enabledBorder: OutlineInputBorder(
                                      //   //       borderSide: BorderSide(
                                      //   //           color: Colors.transparent, width: 0.5),
                                      //   //       borderRadius:
                                      //   //           BorderRadius.all(Radius.circular(12.0)),
                                      //   //     ),
                                      //   //     focusedBorder: OutlineInputBorder(
                                      //   //       borderSide:
                                      //   //           BorderSide(color: Colors.blue, width: 0.5),
                                      //   //       borderRadius:
                                      //   //           BorderRadius.all(Radius.circular(12.0)),
                                      //   //     ),
                                      //   //   ),
                                      //   //   controller: _receiverPhoneController,
                                      //   // ),
                                      // ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      // Expanded(
                                      //   flex: 3,
                                      //   child: TypeAheadFormField(
                                      //     getImmediateSuggestions: false ,
                                      //     hideOnEmpty: true,
                                      //     hideOnError: true,
                                      //     suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                      //         color: Constants.blueColor,
                                      //         borderRadius: BorderRadius.circular(12)
                                      //     ),
                                      //     textFieldConfiguration: TextFieldConfiguration(
                                      //         autofocus: false,
                                      //         decoration: kTextFieldDecoration2.copyWith(
                                      //           contentPadding: EdgeInsets.all(15),
                                      //           hintText: '5xx-xxx-xxx',),
                                      //         keyboardType: TextInputType.number,
                                      //         inputFormatters: [
                                      //           LengthLimitingTextInputFormatter(9),
                                      //           FilteringTextInputFormatter.digitsOnly
                                      //         ],
                                      //         controller: _receiverPhoneController
                                      //     ),
                                      //     validator: (String? value) {
                                      //       if (value!.isEmpty) {
                                      //         return 'Please enter your mobile'.tr();
                                      //       }
                                      //       if (!phoneValidation(value)) {
                                      //         return 'please enter a valid mobile number'
                                      //             .tr();
                                      //       }
                                      //       return null;
                                      //     },
                                      //     suggestionsCallback: (pattern) async {
                                      //       if(pattern.length > 3){
                                      //         return await EventsAPIs.getSuggestedAddress(pattern: pattern);

                                      //       }
                                      //       return [];
                                      //     },
                                      //     noItemsFoundBuilder:(BuildContext context){
                                      //       return SizedBox();
                                      //     },
                                      //     itemBuilder: (context, suggestion) {
                                      //       return Column(
                                      //         children: [
                                      //           ListTile(
                                      //               title: Text(((suggestion as Map)['receiverName'] ?? ""),style: TextStyle(color: Colors.white, ),
                                      //               subtitle: Text(suggestion['receiverPhone'] ?? "",style: TextStyle(color: Colors.white))
                                      //           ),
                                      //           Divider(color: Colors.white, thickness: 2,)
                                      //         ],
                                      //       );
                                      //     },
                                      //     onSuggestionSelected: (suggestion) {
                                      //       _receiverNameController.text = (suggestion as Map)['receiverName'] ;
                                      //       _receiverPhoneController.text = suggestion['receiverPhone'] ;
                                      //       for(int i = 0 ; i < receiverCities.length ; i ++){
                                      //         if(suggestion['deliverCity'] == receiverCities[i].id){
                                      //           _currentReceiverCitySelected = receiverCities[i] ;
                                      //         }
                                      //       }
                                      //       for(int i = 0 ; i < (_currentReceiverCitySelected?.neighborhoods?.length ?? 0) ; i ++){
                                      //         if(suggestion['deliverNeighborhood'] == _currentReceiverCitySelected?.neighborhoods?[i].id){
                                      //           _currentZoneReceiver = _currentReceiverCitySelected?.neighborhoods?[i] ;
                                      //         }
                                      //       }
                                      //       mapUrlReceiver = suggestion['deliverMap'] ;
                                      //       if(mapUrlReceiver != null && mapUrlReceiver != "" ){
                                      //         locationSelectedReceiver = true ;
                                      //       }else {
                                      //         locationSelectedReceiver = false ;
                                      //       }
                                      //       setState(() {});
                                      //     },

                                      //   ),
                                      //   // child: TextFormField(
                                      //   //   key: const ValueKey('receiverPhone'),
                                      //   //   focusNode: receiverPhoneFocus,
                                      //   //   keyboardType: TextInputType.number,
                                      //   //   onChanged: (e) {
                                      //   //     if (startValidation) {
                                      //   //       _formKey.currentState!.validate();
                                      //   //     }
                                      //   //   },
                                      //   //   validator: (String? value) {
                                      //   //     if (value!.isEmpty) {
                                      //   //       return 'Please enter your mobile'.tr();
                                      //   //     }
                                      //   //     if (!phoneValidation(value)) {
                                      //   //       return 'please enter a valid mobile number'
                                      //   //           .tr();
                                      //   //     }
                                      //   //     return null;
                                      //   //   },
                                      //   //   inputFormatters: [
                                      //   //     LengthLimitingTextInputFormatter(9),
                                      //   //     FilteringTextInputFormatter.digitsOnly
                                      //   //   ],
                                      //   //   decoration: kTextFieldDecoration2.copyWith(
                                      //   //     labelText: 'phone number'.tr(),
                                      //   //     hintText: '5xx-xxx-xxx',
                                      //   //     border: null,
                                      //   //     enabledBorder: OutlineInputBorder(
                                      //   //       borderSide: BorderSide(
                                      //   //           color: Colors.transparent, width: 0.5),
                                      //   //       borderRadius:
                                      //   //           BorderRadius.all(Radius.circular(12.0)),
                                      //   //     ),
                                      //   //     focusedBorder: OutlineInputBorder(
                                      //   //       borderSide:
                                      //   //           BorderSide(color: Colors.blue, width: 0.5),
                                      //   //       borderRadius:
                                      //   //           BorderRadius.all(Radius.circular(12.0)),
                                      //   //     ),
                                      //   //   ),
                                      //   //   controller: _receiverPhoneController,
                                      //   // ),
                                      // ),

                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          readOnly: true,
                                          validator: (String? value) {
                                            if (_receiverPhoneController
                                                .text.isEmpty) {
                                              return '';
                                            }
                                            if (!phoneValidation(
                                                _receiverPhoneController
                                                    .text)) {
                                              return '';
                                            }
                                            return null;
                                          },
                                          onChanged: (v) {
                                            _formKey.currentState!.validate();
                                          },
                                          textAlign: TextAlign.center,
                                          decoration:
                                              kTextFieldDecoration2.copyWith(
                                                  contentPadding:
                                                      EdgeInsets.all(0),
                                                  hintText: ''),
                                          controller: _arCodeController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              key: const ValueKey('receiverName'),
                              focusNode: receiverNameFocus,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(receiverPhoneFocus);
                              },
                              onChanged: (e) {
                                if (startValidation) {
                                  _formKey.currentState!.validate();
                                }
                              },
                              decoration: kTextFieldDecoration2.copyWith(
                                hintText: 'Full name'.tr(),
                              ),
                              controller: _receiverNameController,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'this field is required'.tr();
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            height: screenHeight! * 0.08,
                            width: screenWidth,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //         Padding(
                                //             padding:
                                //             EdgeInsets.symmetric(horizontal: 15),
                                //             child: Text(
                                //               'City'.tr(),
                                //               style: TextStyle(
                                //                   fontSize: 14, color: Colors.black87),
                                //             )),
                                //         receiverCities.length > 0
                                //             ?     Expanded(
                                //           child: DropdownSearch<ErCity?>(
                                //             key: const ValueKey('receiverCity'),

                                //             // dropdownSearchDecoration: // FIXME: API changed to dropdownDecoratorProps kTextFieldDecoration2.copyWith(
                                //                 hintText: ""
                                //             ),
                                //             searchBoxDecoration: kTextFieldDecoration.copyWith(
                                //                 hintText: "City name ..".tr(),
                                //                 suffixIcon: Icon(Icons.search)
                                //             ),
                                //             label: "",
                                //             items: receiverCities,
                                //             searchBoxController: searchBoxCityRController,
                                //             maxHeight: screenHeight!*0.8,
                                //             showSearchBox: true,
                                //             selectedItem: _currentReceiverCitySelected ,
                                //             itemAsString: (ErCity? u) => u!.name ?? "",
                                //             emptyBuilder: (context , string){
                                //               return Center(child: Text('No results'.tr()));
                                //             },
                                //             // mode: Mode.bottomSheet // FIXME: API changed ,
                                //             enabled: true,
                                //             onChanged: (value){

                                //               setState(() {
                                //                 _currentReceiverCitySelected = value;
                                //                 _currentZoneReceiver = Neighborhoods();
                                //                 searchBoxCityRController.clear();

                                //               });

                                //             },
                                //             clearButton: Icon(Icons.close),
                                //           ),
                                // ]))
                                //             : Container(),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: screenHeight! * 0.08,
                            width: screenWidth,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text(
                                    'Neighborhood'.tr(),
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                                // senderCities.length > 0
                                //     ? Expanded(
                                //   child: DropdownSearch<Neighborhoods?>(
                                //     // dropdownSearchDecoration: // FIXME: API changed to dropdownDecoratorProps kTextFieldDecoration2.copyWith(
                                //         hintText: ""
                                //     ),
                                //     searchBoxDecoration: kTextFieldDecoration.copyWith(
                                //         hintText: "Neighborhood name..".tr(),
                                //         suffixIcon: Icon(Icons.search)
                                //     ),
                                //     label: "",
                                //     maxHeight: screenHeight!*0.8,
                                //     items: _currentReceiverCitySelected!.neighborhoods,
                                //     searchBoxController: searchBoxZoneRController,
                                //     showSearchBox: true,
                                //     selectedItem: _currentZoneReceiver,
                                //     itemAsString: (Neighborhoods? u) => u!.name?? "",
                                //     emptyBuilder: (context , string){
                                //       return Center(child: Text('No results'.tr()));
                                //     },
                                //     // mode: Mode.bottomSheet // FIXME: API changed ,
                                //     enabled: true,
                                //     onChanged: (value){
                                //       setState(() {
                                //         _currentZoneReceiver = value;
                                //         searchBoxZoneRController.clear();
                                //       });
                                //     },
                                //     clearButton: Icon(Icons.close),
                                //   ),
                                // ) : Container(),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            textBaseline: TextBaseline.ideographic,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'Optional information'.tr(),
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Container(
                                      height: 1,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          locationSelectedReceiver
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        ComFunctions.launchURL(mapUrlReceiver!);
                                      },
                                      child: Container(
                                        width: screenWidth! * 0.7,
                                        height: screenHeight! * 0.06,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Color(0xFF56D340),
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Image.asset(
                                                "assets/images/GOOGLE MAP ICON.png",

                                                // height: 18.0,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Saved Location'.tr(),
                                              style: TextStyle(
                                                color: Color(0xFF56D340),
                                                fontSize: 17,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        icon: Icon(
                                          Icons.delete_forever_outlined,
                                          color: Color(0xFFF4693F),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            locationSelectedReceiver = false;
                                            _receiverAddressController.clear();
                                            mapUrlReceiver = '';
                                          });
                                        })
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => PlacePicker(
                                    //       apiKey: Constants
                                    //           .googleMabiApiKey, // Put YOUR OWN KEY here.
                                    //       onPlacePicked: (result) {
                                    //         Navigator.of(context).pop();
                                    //       },
                                    //       // initialPosition: LatLng(Constants.latitude, Constants.longitude),
                                    //       initialPosition: LatLng(21.4858, 39.1925),
                                    //       strictbounds: true,
                                    //       onGeocodingSearchFailed: (e) {
                                    //         print('FAILED FAILED $e');
                                    //       },
                                    //       enableMapTypeButton: false,
                                    //       autocompleteRadius: 800000,
                                    //       selectInitialPosition: true,
                                    //       searchForInitialValue: false,
                                    //       useCurrentLocation: true,
                                    //       onAutoCompleteFailed: (e) {
                                    //         print("Auto complete failed $e");
                                    //       },
                                    //       autocompleteLanguage: "ar",
                                    //       selectedPlaceWidgetBuilder:
                                    //           (_, selectedPlace, state, isSearchBarFocused) {
                                    //         return isSearchBarFocused
                                    //             ? Container()
                                    //             : FloatingCard(
                                    //           bottomPosition:
                                    //           40.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                    //           leftPosition: 10.0,
                                    //           rightPosition: 10.0,
                                    //           width: 500,
                                    //           elevation: 5,
                                    //           borderRadius: BorderRadius.circular(12.0),
                                    //           child: Padding(
                                    //             padding: EdgeInsets.only(
                                    //                 top: 10, bottom: 10),
                                    //             child: selectedPlace != null
                                    //                 ? Column(
                                    //               mainAxisAlignment:
                                    //               MainAxisAlignment.center,
                                    //               children: [
                                    //                 Padding(
                                    //                   padding:
                                    //                   const EdgeInsets.all(
                                    //                       2.0),
                                    //                   child: Text(
                                    //                     selectedPlace
                                    //                         .formattedAddress!,
                                    //                     style: TextStyle(
                                    //                         fontSize: 18),
                                    //                   ),
                                    //                 ),
                                    //                 SizedBox(height: 10),
                                    //                 ElevatedButton(
                                    //                   child: Text('Save'.tr()),
                                    //                   onPressed: () {
                                    //                     setState(() {
                                    //                       _deliverPickedLocation =
                                    //                           selectedPlace;
                                    //                       _receiverAddressController
                                    //                           .text =
                                    //                           _deliverPickedLocation!
                                    //                               .formattedAddress
                                    //                               .toString();

                                    //                       locationSelectedReceiver =
                                    //                       true;

                                    //                       mapUrlReceiver =
                                    //                       'https://www.google.com/maps/search/?api=1&query=${_deliverPickedLocation!.geometry!.location.lat},${_deliverPickedLocation!.geometry!.location.lng}';
                                    //                     });
                                    //                     Navigator.of(context)
                                    //                         .pop();
                                    //                   },
                                    //                 ),
                                    //               ],
                                    //             )
                                    //                 : Center(
                                    //                 child:
                                    //                 CustomLoading()),
                                    //           ),
                                    //         );
                                    //       },
                                    //       centerForSearching: Constants.sauidArabia,
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  child: Container(
                                    width: screenWidth,
                                    height: screenHeight! * 0.06,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.grey, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Image.asset(
                                            "assets/images/GOOGLE MAP ICON.png",
                                            // height: 18.0,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Position on Google Maps'.tr(),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 17,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                          SizedBox(
                            height: 15,
                          ),
                          _receiverAddressController.text.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Container(
                                      width: screenWidth,
                                      height: screenHeight! * 0.06,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: AutoSizeText(
                                          "${_receiverAddressController.text}",
                                          maxLines: 3,
                                        ),
                                      )),
                                )
                              : Container(),
                          widget.ordersDataModel == null
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        key: const ValueKey('receiverBuilding'),
                                        focusNode: receiverBuildingFocus,
                                        onFieldSubmitted: (v) {
                                          FocusScope.of(context)
                                              .requestFocus(receiverFloorFocus);
                                        },
                                        controller: _receiverBuildingController,
                                        decoration:
                                            kTextFieldDecoration2.copyWith(
                                                hintText:
                                                    'Building optional'.tr(),
                                                hintStyle:
                                                    TextStyle(fontSize: 11)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        key: const ValueKey('receiverFloor'),
                                        focusNode: receiverFloorFocus,
                                        onFieldSubmitted: (v) {
                                          FocusScope.of(context)
                                              .requestFocus(receiverFlatFocus);
                                        },
                                        controller: _receiverFloor,
                                        decoration:
                                            kTextFieldDecoration2.copyWith(
                                                hintText: 'Floor optional'.tr(),
                                                hintStyle:
                                                    TextStyle(fontSize: 11)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        key: const ValueKey('receiverFlat'),
                                        focusNode: receiverFlatFocus,
                                        controller: _receiverFlatController,
                                        decoration:
                                            kTextFieldDecoration2.copyWith(
                                                hintText: 'Flat optional'.tr(),
                                                hintStyle:
                                                    TextStyle(fontSize: 11)),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    'Shipment details'.tr(),
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Container(
                                      height: 1,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      fragileCheckedValue =
                                          !fragileCheckedValue;
                                    });
                                  },
                                  child: Container(
                                    width: width,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: fragileCheckedValue
                                                ? Constants.blueColor
                                                : Colors.grey)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  unselectedWidgetColor:
                                                      Constants.blueColor,
                                                ),
                                                child: SizedBox(
                                                    height: 20.0,
                                                    width: 20.0,
                                                    child: CustomCheckBox(
                                                      checkedColor:
                                                          Constants.blueColor,
                                                      unCheckedColor:
                                                          Colors.grey,
                                                      backgroundColor:
                                                          Colors.white,
                                                      checked:
                                                          fragileCheckedValue,
                                                    )),
                                              ),
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Text(
                                                'fragile'.tr(),
                                                style: TextStyle(
                                                    fontSize: width! * 0.03,
                                                    color: fragileCheckedValue
                                                        ? Constants.blueColor
                                                        : Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: SvgPicture.asset(
                                            "assets/images/fragile.svg",
                                            width: 25,
                                            height: 25,
                                            color: fragileCheckedValue
                                                ? null
                                                : Colors.grey,
                                            placeholderBuilder: (context) =>
                                                CustomLoading(),

                                            // height: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Container(
                              width: width,
                              height: 45,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Constants.blueColor)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      'Packaging'.tr(),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  SavedData.resourcesData.packaging!.length > 0
                                      ? Expanded(
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<Packaging>(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              items: SavedData
                                                  .resourcesData.packaging
                                                  ?.map((Packaging
                                                      dropDownStringItem) {
                                                return DropdownMenuItem<
                                                    Packaging>(
                                                  key: const ValueKey(
                                                      'packaging'),
                                                  value: dropDownStringItem,
                                                  child: Text(
                                                    dropDownStringItem.name ??
                                                        "",
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 14),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (Packaging? newValue) {
                                                setState(() {
                                                  _currentSelectedPackaging =
                                                      newValue!;
                                                  try {
                                                    double price = Dialogs.CalcPackagePrice(
                                                        resourcesData: SavedData
                                                            .resourcesData,
                                                        senderCity:
                                                            _currentCitySelected
                                                                ?.id,
                                                        deliverCity:
                                                            _currentReceiverCitySelected
                                                                ?.id,
                                                        packagingId:
                                                            _currentSelectedPackaging!
                                                                .id);
                                                  } catch (e) {}
                                                });
                                              },
                                              value: _currentSelectedPackaging,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                          _currentReceiverCitySelected?.cod == "1" ||
                                  codCheckedValue
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: InkWell(
                                          key: const ValueKey('cod'),
                                          onTap: () {
                                            setState(() {
                                              codCheckedValue =
                                                  !codCheckedValue;
                                              if (!codCheckedValue) {
                                                _codController.clear();
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: width,
                                            height: 45,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: codCheckedValue
                                                    ? BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(8),
                                                        topLeft:
                                                            Radius.circular(8))
                                                    : BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: codCheckedValue
                                                        ? Constants.blueColor
                                                        : Colors.grey)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Theme(
                                                            data: Theme.of(
                                                                    context)
                                                                .copyWith(
                                                              unselectedWidgetColor:
                                                                  Constants
                                                                      .blueColor,
                                                            ),
                                                            child: SizedBox(
                                                                height: 20.0,
                                                                width: 20.0,
                                                                child:
                                                                    CustomCheckBox(
                                                                  checkedColor:
                                                                      Constants
                                                                          .blueColor,
                                                                  unCheckedColor:
                                                                      Colors
                                                                          .grey,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  checked:
                                                                      codCheckedValue,
                                                                )),
                                                          ),
                                                          SizedBox(
                                                            width: 12,
                                                          ),
                                                          Text(
                                                            'Cash on delivery'
                                                                .tr(),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: codCheckedValue
                                                                    ? Constants
                                                                        .blueColor
                                                                    : Colors
                                                                        .grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: SvgPicture.asset(
                                                        "assets/images/cash-payment.svg",
                                                        width: 25,
                                                        height: 25,
                                                        color: codCheckedValue
                                                            ? null
                                                            : Colors.grey,
                                                        placeholderBuilder:
                                                            (context) =>
                                                                CustomLoading(),

                                                        // height: 18.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      (codCheckedValue &&
                                                  _currentReceiverCitySelected
                                                          ?.cod ==
                                                      "1") ||
                                              codCheckedValue
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  key: const ValueKey(
                                                      'codValue'),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true),
                                                  decoration:
                                                      kTextFieldDecoration
                                                          .copyWith(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      8.0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8.0)),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.15),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      8.0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8.0)),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Constants
                                                              .blueColor,
                                                          width: 1.15),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      8.0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8.0)),
                                                    ),
                                                    prefixIcon: Icon(
                                                      MdiIcons.cash,
                                                      color: Color(0xFF414141),
                                                      size: 20,
                                                    ),
                                                    hintText: 'value'.tr(),
                                                    hintStyle: TextStyle(
                                                        fontSize:
                                                            width! * 0.03),
                                                  ),
                                                  validator: (String? value) {
                                                    if (value!.isEmpty) {
                                                      return "";
                                                    }
                                                    return null;
                                                  },
                                                  controller: _codController,
                                                  onFieldSubmitted: (value) {
                                                    try {
                                                      setState(() {
                                                        codDoubleValue =
                                                            double.parse(value);
                                                      });
                                                    } catch (e) {}
                                                  },
                                                  onChanged: (value) {
                                                    try {
                                                      setState(() {
                                                        codDoubleValue =
                                                            double.parse(value);
                                                      });
                                                    } catch (e) {}
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'This value that will get back to you after delivery'
                                                      .tr(),
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  "Pleas do not add the delivery cost on this value just if the the delivery cost on you"
                                                      .tr(),
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ))
                              : Container(),
                          SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              decoration: kTextFieldDecoration.copyWith(
                                prefixIcon: Icon(
                                  MdiIcons.counter,
                                  color: Color(0xFF414141),
                                  size: 20,
                                ),
                                hintText: 'no. of pieces'.tr(),
                                hintStyle: TextStyle(fontSize: width! * 0.03),
                              ),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return ''.tr();
                                }
                                return null;
                              },
                              controller: _quantityController,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: TextFormField(
                              decoration: kTextFieldDecoration.copyWith(
                                prefixIcon: Icon(
                                  MdiIcons.comment,
                                  color: Color(0xFF414141),
                                  size: 20,
                                ),
                                hintText: 'parcel details'.tr(),
                                hintStyle: TextStyle(fontSize: width! * 0.03),
                              ),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return ''.tr();
                                }
                                return null;
                              },
                              controller: _packageCommentController,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _packageWeightController,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'Please enter the weight'.tr();
                                }
                                return null;
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                labelText: 'Weight ( Kg )'.tr(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            child: Text('Measures (cm)'.tr()),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: kTextFieldDecoration.copyWith(
                                        labelText: 'length'.tr()),
                                    onFieldSubmitted: (e) {
                                      setState(() {});
                                    },
                                    onChanged: (e) {
                                      setState(() {});
                                    },
                                    controller: _packageLengthController,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: kTextFieldDecoration.copyWith(
                                        labelText: 'width'.tr()),
                                    onFieldSubmitted: (e) {
                                      setState(() {});
                                    },
                                    onChanged: (e) {
                                      setState(() {});
                                    },
                                    controller: _packageWidthController,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration: kTextFieldDecoration.copyWith(
                                        labelText: 'height'.tr()),
                                    onFieldSubmitted: (e) {
                                      setState(() {});
                                    },
                                    onChanged: (e) {
                                      setState(() {});
                                    },
                                    controller: _packageHeightController,
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
                                horizontal: 10, vertical: 0),
                            child: TextFormField(
                              controller: _noteCommentController,
                              decoration: kTextFieldDecoration.copyWith(
                                prefixIcon: Icon(
                                  MdiIcons.comment,
                                  color: Color(0xFF414141),
                                  size: 20,
                                ),
                                hintText: 'notes'.tr(),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              _paymentMethodDialog(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Constants.blueColor, width: 2),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    paymentMethods?.name ??
                                        "Choose payment method".tr(),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          // SizedBox(height: 20,),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: backgroundColor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                widget.showAddingOrder(false);
                                if (widget.ordersDataModel != null) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                // width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: widget.ordersDataModel == null
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Shipments list'.tr(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Back'.tr(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _onLoginButtonPressed();
                              },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Constants.blueColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: widget.ordersDataModel == null
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Add shipment'.tr(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Edit shipment'.tr(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            // ButtonTheme(
                            //   height: 50,
                            //   minWidth: 40,
                            //   child: ElevatedButton(
                            //       padding: EdgeInsets.all(8),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12.0),
                            //       ),
                            //       color: Colors.green,
                            //       foregroundColor: Colors.white,
                            //       child: widget.ordersDataModel == null ?  Text(
                            //         'Shipments list'.tr(),
                            //         style: TextStyle(
                            //           fontSize: 17,
                            //         ),
                            //       ) :  Text(
                            //         'Back'.tr(),
                            //         style: TextStyle(
                            //           fontSize: 17,
                            //         ),
                            //       ),
                            //       onPressed: () {
                            //         widget.showAddingOrder(false);
                            //         if( widget.ordersDataModel != null){
                            //           Navigator.of(context).pop();
                            //         }
                            //       }),
                            // ),
                            // ButtonTheme(
                            //   height: 50,
                            //   minWidth: 40,
                            //   child: ElevatedButton(
                            //       padding: EdgeInsets.all(8),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12.0),
                            //       ),
                            //       color : Constants.blueColor,
                            //       foregroundColor: Colors.white,
                            //       child: widget.ordersDataModel == null ? Text(
                            //         'Add shipment'.tr(),
                            //         style: TextStyle(
                            //           fontSize: 17,
                            //         ),
                            //       ) : Text(
                            //         'Edit shipment'.tr(),
                            //         style: TextStyle(
                            //           fontSize: 17,
                            //         ),
                            //       ),
                            //       onPressed: () {
                            //         _onLoginButtonPressed();
                            //       }),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSenderData() {
    return Column(
      children: [
        SizedBox(
          width: 15,
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                focusNode: senderNameFocus,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(senderPhoneFocus);
                },
                decoration: kTextFieldDecoration2.copyWith(
                  hintText: 'Full name'.tr(),
                ),
                validator: (String? value) {
                  if (_senderNameController.text.isEmpty) {
                    return 'this field is required'.tr();
                  } else {
                    return null;
                  }
                },
                onChanged: (e) {
                  if (startValidation) {
                    _formKey.currentState!.validate();
                  }
                },
                controller: _senderNameController,
              ),
            ),
            EasyLocalization.of(context)!.locale == Locale('en')
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            readOnly: true,
                            validator: (String? value) {
                              if (_senderPhoneController.text.isEmpty) {
                                return '';
                              }
                              if (!phoneValidation(
                                  _senderPhoneController.text)) {
                                return '';
                              }
                              return null;
                            },
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration2.copyWith(
                                contentPadding: EdgeInsets.all(0),
                                hintText: ''),
                            controller: _enCodeController,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            focusNode: senderPhoneFocus,
                            onChanged: (e) {
                              if (startValidation) {
                                _formKey.currentState!.validate();
                              }
                            },
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Please enter your mobile'.tr();
                              }
                              if (!phoneValidation(value)) {
                                return 'please enter a valid mobile number'
                                    .tr();
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(9),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: kTextFieldDecoration2.copyWith(
                              labelText: 'phone number'.tr(),
                              hintText: '5xx-xxx-xxx',
                              border: null,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Constants.blueColor, width: .5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              ),
                            ),
                            controller: _senderPhoneController,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            key: const ValueKey('phoneLogin'),
                            focusNode: senderPhoneFocus,
                            keyboardType: TextInputType.number,
                            onChanged: (e) {
                              if (startValidation) {
                                _formKey.currentState!.validate();
                              }
                            },
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Please enter your mobile'.tr();
                              }
                              if (!phoneValidation(value)) {
                                return 'please enter a valid mobile number'
                                    .tr();
                              }
                              return null;
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(9),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: kTextFieldDecoration2.copyWith(
                              labelText: 'phone number'.tr(),
                              hintText: '5xx-xxx-xxx',
                              border: null,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 0.50),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Constants.blueColor, width: .50),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                              ),
                            ),
                            controller: _senderPhoneController,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            readOnly: true,
                            validator: (String? value) {
                              if (_senderPhoneController.text.isEmpty) {
                                return '';
                              }
                              if (!phoneValidation(
                                  _senderPhoneController.text)) {
                                return '';
                              }
                              return null;
                            },
                            onChanged: (v) {
                              _formKey.currentState!.validate();
                            },
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration2.copyWith(
                                contentPadding: EdgeInsets.all(0),
                                hintText: ''),
                            controller: _arCodeController,
                          ),
                        ),
                      ],
                    ),
                  ),
            Container(
              height: screenHeight! * 0.08,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'City'.tr(),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      )),
                  // senderCities.length > 0
                  //     ?      Expanded(
                  //   child: DropdownSearch<ErCity?>(
                  //     // dropdownSearchDecoration: // FIXME: API changed to dropdownDecoratorProps kTextFieldDecoration2.copyWith(
                  //         hintText: ""
                  //     ),
                  //     searchBoxDecoration: kTextFieldDecoration.copyWith(
                  //         hintText: "City name ..".tr(),
                  //         suffixIcon: Icon(Icons.search)
                  //     ),
                  //     label: "",
                  //     items: senderCities,
                  //     maxHeight: screenHeight!*0.8,
                  //     searchBoxController: searchBoxCityController,

                  //     showSearchBox: true,
                  //     selectedItem: _currentCitySelected,
                  //     itemAsString: (ErCity? u) => u!.name ?? "",
                  //     emptyBuilder: (context , string){
                  //       return Center(child: Text('No results'.tr()));
                  //     },
                  //     // mode: Mode.bottomSheet // FIXME: API changed ,
                  //     enabled: true,
                  //     onChanged: (value){
                  //       setState(() {
                  //         _currentCitySelected = value;
                  //         _currentZone = Neighborhoods();
                  //       });
                  //     },
                  //     clearButton: Icon(Icons.close),
                  //   ),
                  // )
                  //     : Container(),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: screenHeight! * 0.08,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Neighborhood'.tr(),
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  // senderCities.length > 0
                  //     ?
                  // Expanded(
                  //   child: DropdownSearch<Neighborhoods?>(
                  //     // dropdownSearchDecoration: // FIXME: API changed to dropdownDecoratorProps kTextFieldDecoration2.copyWith(
                  //         ),

                  //     // mode: Mode.bottomSheet // FIXME: API changed ,
                  //     enabled: true,
                  //     onChanged: (value){
                  //     setState(() {
                  //       _currentZone = value;
                  //       searchBoxZoneController.clear();
                  //     });
                  //     },
                  //     clearButton: Icon(Icons.close),
                  //   ):Container()]),
                  // )

                  // Expanded(
                  //   child: DropdownSearch<Neighborhoods?>(
                  //     // dropdownSearchDecoration: // FIXME: API changed to dropdownDecoratorProps
                  //     kTextFieldDecoration2.copyWith(
                  //         hintText: ""),
                  //     searchBoxDecoration:
                  //     kTextFieldDecoration.copyWith(
                  //         hintText:
                  //         "Neighborhood name.."
                  //             .tr(),
                  //         suffixIcon:
                  //         Icon(Icons.search)),
                  //     label: "",
                  //     maxHeight: screenHeight! * 0.8,
                  //     items: _currentCitySelected!
                  //         .neighborhoods ??
                  //         [],
                  //     searchBoxController:
                  //     searchBoxZoneController,
                  //     showSearchBox: true,
                  //     selectedItem: _currentZone,
                  //     itemAsString: (Neighborhoods? u) =>
                  //     u!.name ?? "",
                  //     emptyBuilder: (context, string) {
                  //       return Center(
                  //           child: Text('No results'.tr()));
                  //     },
                  //     mode: Mode.bottomSheet,
                  //     enabled: true,
                  //     onChanged: (value) {
                  //       ;
                  //       setState(() {
                  //         _currentZone = value;
                  //         searchBoxZoneController.clear();
                  //       });
                  //     },
                  //     clearButton: Icon(Icons.close),
                  //   ),
                  // )
                  //   : Container(),
                  // Expanded(
                  //   child: DropdownButtonHideUnderline(
                  //
                  //     child: DropdownButtonFormField<Neighborhoods>(
                  //       decoration: InputDecoration.collapsed(hintText: ''),
                  //       focusNode: zoneFocus,
                  //       items: _currentCitySelected.neighborhoods
                  //           .map((Neighborhoods dropDownStringItem) {
                  //         return DropdownMenuItem<Neighborhoods>(
                  //           value: dropDownStringItem,
                  //           child: Container(
                  //             width: screenWidth*0.5,
                  //             child: AutoSizeText(
                  //               dropDownStringItem.name,
                  //               style: TextStyle(
                  //                   color: Colors.black87, fontSize: 15),
                  //             ),
                  //           ),
                  //         );
                  //       }).toList(),
                  //       onChanged: (Neighborhoods newValue) {
                  //         setState(() {
                  //           _currentZone = newValue;
                  //         });
                  //       },
                  //       value: _currentZone,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),

            locationSelected
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ComFunctions.launchURL(mapUrlSender!);
                        },
                        child: Container(
                          width: screenWidth! * 0.7,
                          height: screenHeight! * 0.06,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Color(0xFF56D340), width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                  "assets/images/GOOGLE MAP ICON.png",
                                  // height: 18.0,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Saved Location'.tr(),
                                style: TextStyle(
                                  color: Color(0xFF56D340),
                                  fontSize: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.delete_forever_outlined,
                            color: Color(0xFFF4693F),
                          ),
                          onPressed: () {
                            setState(() {
                              locationSelected = false;
                              mapUrlSender = '';
                              _senderAddressController.clear();
                            });
                          })
                    ],
                  )
                : GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PlacePicker(
                      //       apiKey: Constants
                      //           .googleMabiApiKey, // Put YOUR OWN KEY here.
                      //       onPlacePicked: (result) {
                      //         Navigator.of(context).pop();
                      //       },
                      //       // initialPosition: LatLng(Constants.latitude, Constants.longitude),
                      //       initialPosition:
                      //       LatLng(21.4858, 39.1925),
                      //       strictbounds: true,
                      //       onGeocodingSearchFailed: (e) {
                      //         print('FAILED FAILED $e');
                      //       },
                      //       enableMapTypeButton: false,
                      //       autocompleteRadius: 800000,
                      //       selectInitialPosition: true,
                      //       searchForInitialValue: false,
                      //       useCurrentLocation: true,
                      //       onAutoCompleteFailed: (e) {
                      //         print("Auto complete failed $e");
                      //       },
                      //       autocompleteLanguage: "ar",
                      //       selectedPlaceWidgetBuilder: (_,
                      //           selectedPlace,
                      //           state,
                      //           isSearchBarFocused) {
                      //         return isSearchBarFocused
                      //             ? Container()
                      //             : FloatingCard(
                      //           bottomPosition:
                      //           40.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                      //           leftPosition: 10.0,
                      //           rightPosition: 10.0,
                      //           width: 500,
                      //           elevation: 5,
                      //           borderRadius:
                      //           BorderRadius.circular(
                      //               12.0),
                      //           child: Padding(
                      //             padding: EdgeInsets.only(
                      //                 top: 10, bottom: 10),
                      //             child: selectedPlace !=
                      //                 null
                      //                 ? Column(
                      //               mainAxisAlignment:
                      //               MainAxisAlignment
                      //                   .center,
                      //               children: [
                      //                 Padding(
                      //                   padding:
                      //                   const EdgeInsets
                      //                       .all(
                      //                       2.0),
                      //                   child: Text(
                      //                     selectedPlace
                      //                         .formattedAddress!,
                      //                     style: TextStyle(
                      //                         fontSize:
                      //                         18),
                      //                   ),
                      //                 ),
                      //                 SizedBox(
                      //                     height: 10),
                      //                 ElevatedButton(
                      //                   child: Text(
                      //                       'Save'
                      //                           .tr()),
                      //                   onPressed:
                      //                       () {
                      //                     setState(
                      //                             () {
                      //                           _pickedLocation =
                      //                               selectedPlace;
                      //                           _senderAddressController
                      //                               .text =
                      //                               _pickedLocation!
                      //                                   .formattedAddress
                      //                                   .toString();

                      //                           locationSelected =
                      //                           true;

                      //                           mapUrlSender =
                      //                           'https://www.google.com/maps/search/?api=1&query=${_pickedLocation!.geometry!.location.lat},${_pickedLocation!.geometry!.location.lng}';
                      //                         });
                      //                     Navigator.of(
                      //                         context)
                      //                         .pop();
                      //                   },
                      //                 ),
                      //               ],
                      //             )
                      //                 : Center(
                      //                 child:
                      //                 CustomLoading()),
                      //           ),
                      //         );
                      //       },
                      //       centerForSearching:
                      //       Constants.sauidArabia,
                      //     ),
                      //   ),
                      // );
                    },
                    child: Container(
                      width: screenWidth,
                      height: screenHeight! * 0.06,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Image.asset(
                              "assets/images/GOOGLE MAP ICON.png",
                              // height: 18.0,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Position on Google Maps'.tr(),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: () async {
//                               FocusScope.of(context).unfocus();
//                               LocationResult result = await showLocationPicker(
//                                 context,
//                                 Constants.googleMabiApiKey,
//                                 automaticallyAnimateToCurrentLocation: false,
//                                 initialCenter: LatLng( _pickedLocation.latLng.latitude ?? 21.4858,_pickedLocation.latLng.longitude ?? 39.1925),
//                                 hintText: EasyLocalization.of(context).locale == Locale("en") ? "search" : "البحث",
//                                 language:EasyLocalization.of(context).locale == Locale("en") ? "en" : 'ar',
// //                      mapStylePath: 'assets/mapStyle.json',
//                                 myLocationButtonEnabled: true,
//                                 // requiredGPS: true,
//                                 layersButtonEnabled: true,
//                                 countries: ['SA'],
//
// //                      resultCardAlignment: Alignment.bottomCenter,
//                                 desiredAccuracy: LocationAccuracy.best,
//                               );
//                               print("result = $result");
//                               setState(() {
//                                 if(result != null){
//                                   _pickedLocation = result;
//                                   locationSelected = true ;
//                                   if(_senderAddressController.text.isEmpty){
//                                     _senderAddressController.text = result.address ;
//
//                                   }
//
//                                   mapUrlSender = 'https://www.google.com/maps/search/?api=1&query=${_pickedLocation.latLng.latitude},${_pickedLocation.latLng.longitude}';
//
//                                 }
//
//
//                               });
//                             },
//                             child: Container(
//                               width: screenWidth*0.7,
//                               height: screenHeight * 0.06,
//                               decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   border: Border.all(color: Color(0xFF56D340), width: 2),
//                                   borderRadius: BorderRadius.circular(12)),
//                               child: Row(
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 10),
//                                     child: SvgPicture.asset(
//                                       "assets/images/google-maps.svg",
//                                       placeholderBuilder: (context) =>
//                                           CustomLoading(),
//                                       // height: 18.0,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 5,
//                                   ),
//                                   Text(
//                                     'Saved Location'.tr(),
//                                     style: TextStyle(
//                                       color: Color(0xFF56D340),
//                                       fontSize: 17,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                           IconButton(icon: Icon(Icons.delete_forever_outlined , color: Color(0xFFF4693F),), onPressed: (){
//                             setState(() {
//                               // _senderAddressController.clear() ;
//                               mapUrlSender = '' ;
//                               locationSelected = false ;
//                             });
//
//                           })
//                         ],
//                       ) :
//                       GestureDetector(
//                         onTap: () async {
//                           FocusScope.of(context).unfocus();
//                           LocationResult result = await showLocationPicker(
//                             context,
//                             Constants.googleMabiApiKey,
//                             automaticallyAnimateToCurrentLocation: true,
//                             initialCenter: LatLng(21.4858, 39.1925),
//                             hintText: EasyLocalization.of(context).locale == Locale("en") ? "search" : "البحث",
//                             language:EasyLocalization.of(context).locale == Locale("en") ? "en" : 'ar',
// //                      mapStylePath: 'assets/mapStyle.json',
//                             myLocationButtonEnabled: true,
//                             // requiredGPS: true,
//                             layersButtonEnabled: true,
//                             countries: ['SA'],
//
// //                      resultCardAlignment: Alignment.bottomCenter,
//                             desiredAccuracy: LocationAccuracy.best,
//                           );
//                           print("result = $result");
//                           setState(() {
//                             if(result != null){
//                               _pickedLocation = result;
//                               locationSelected = true ;
//                               if(_senderAddressController.text.isEmpty){
//                                 _senderAddressController.text = result.address ;
//
//                               }
//
//                               mapUrlSender = 'https://www.google.com/maps/search/?api=1&query=${_pickedLocation.latLng.latitude},${_pickedLocation.latLng.longitude}';
//
//                             }
//
//
//                           });
//                         },
//                         child: Container(
//                           width: screenWidth,
//                           height: screenHeight * 0.06,
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               border: Border.all(color: Colors.grey, width: 2),
//                               borderRadius: BorderRadius.circular(12)),
//                           child: Row(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 10),
//                                 child: SvgPicture.asset(
//                                   "assets/images/google-maps.svg",
//                                   placeholderBuilder: (context) =>
//                                       CustomLoading(),
//                                   // height: 18.0,
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 5,
//                               ),
//                               Text(
//                                 'Position on Google Maps'.tr(),
//                                 style: TextStyle(
//                                   color: Colors.black87,
//                                   fontSize: 17,
//                                 ),
//                               ),
//                               // SizedBox(
//                               //   width: 2,
//                               // ),
//                               // Text(
//                               //   '(required)'.tr(),
//                               //   style: TextStyle(
//                               //     color: Color(0xFFF4693F),
//                               //     fontSize: 11,
//                               //   ),
//                               // ),
//                             ],
//                           ),
//                         ),
//                       ),
            SizedBox(
              height: 10,
            ),
            // Padding(
            //   padding: EdgeInsets.only(bottom: 10),
            //   child: TextFormField(
            //     focusNode: senderAddressFocus,
            //     onFieldSubmitted:(v) {
            //       FocusScope.of(context).unfocus();
            //     },
            //     decoration:
            //     kTextFieldDecoration2.copyWith(hintText: 'Address'.tr()),
            //     controller: _senderAddressController,
            //     // validator: (String value) {
            //     //   if (value.isEmpty) {
            //     //     return 'this field is required';
            //     //   }
            //     //   return null;
            //     // },
            //   ),
            // ),
            _senderAddressController.text.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Container(
                        width: screenWidth,
                        height: screenHeight! * 0.06,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AutoSizeText(
                            "${_senderAddressController.text}",
                            maxLines: 3,
                          ),
                        )),
                  )
                : Container(),
          ],
        ),
      ],
    );
  }

  _paymentMethodDialog(BuildContext context) {
    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return PaymentMethodDialog(
            paymentMethod: (selectedMethod) {
              setState(() {
                paymentMethods = selectedMethod;
              });
            },
          );
        });
  }
}
