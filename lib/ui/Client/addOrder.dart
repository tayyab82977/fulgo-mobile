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
import 'package:Fulgox/ui/custom%20widgets/dialog.dart';
import 'package:Fulgox/ui/custom%20widgets/home_button.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/ui/custom%20widgets/customCheckBox.dart';
import 'package:Fulgox/ui/custom%20widgets/packageCard.dart';
import 'package:Fulgox/ui/common/dashboard.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'MyOrders.dart';
import 'dart:ui' as ui;
import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/drawerClient.dart';

class MyCityModel {
  String? name;
  String? id;
  MyCityModel({this.name, this.id});
}

class AddOrder extends StatefulWidget {
  ResourcesData? resourcesData;
  ProfileDataModel? dashboardDataModelNew;
  String packagingType;
  GetOrdersController? getOrdersController ;
  OrdersDataModelMix? ordersDataModel ;
  bool fromHomeScreen = false ;
  AddOrder(
      {this.resourcesData,
      this.dashboardDataModelNew,
      this.ordersDataModel,
      this.getOrdersController,
      this.fromHomeScreen = false,
      this.packagingType = "noPackaging"});
  @override
  _AddOrderState createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
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
  Cancellation? _currentTimeSelected = Cancellation();
  Neighborhoods? _currentZone = Neighborhoods();
  Neighborhoods? _currentZoneReceiver = Neighborhoods();

  double? width, height;
  double? screenWidth, screenHeight;
  List<Packages> packagesList = [];
  final PostOrderController postOrderController = Get.put(PostOrderController());
  double totalPrice = 0;
  PostOrderDataModel _postOrderDataModel = PostOrderDataModel();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
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
  bool useWallet = false;
  bool usePackageOffer = false;
  PaymentMethods? paymentMethod ;
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

  late int day = DateTime.now().day;
  late int month = DateTime.now().month;
  late int year = DateTime.now().year;
  // TimeOfDay? pickedTime = TimeOfDay.now();
  final initialTime = TimeOfDay.now();
  int hour = TimeOfDay.now().hour;
  int minute = TimeOfDay.now().minute;
  // String pickupTime = "" ;
  DateTime pickupTime = DateTime.now() ;
  late Packages edtitedPackage ;
  bool unsupportedPackaging = false ;

  DateTime currentDate = DateTime.now();
  setThePackagingType() {
    try {
      switch (widget.packagingType) {
        case "noPackaging":
          {
            _currentSelectedPackaging = widget.resourcesData?.packaging?[0];
            // addPackageDarkColor = Color(0xFFFAD824);
            addPackageDarkColor = Color(0xff736b51);
            // addPackageLightColorColor = Color(0xFFFBE56E).withOpacity(0.1);
            addPackageLightColorColor = Color(0xff736b51).withOpacity(0.1);
            backgroundColor = Color(0xFFd3c9ab) ;
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
    if (_currentSelectedPackaging?.name == null){
      _currentSelectedPackaging = widget.resourcesData?.packaging?[0];

    }
  }

  bool phoneValidation(String value) {
    if (value.length == 9 && value.characters.first == '5') {
      return true;
    }
    return false;
  }

  _onLoginButtonPressed() {
    startValidation = true;
    if (_formKey.currentState!.validate()) {
      if (_formKey.currentState!.validate()) {
        if (paymentMethod == null) {
          ComFunctions.showToast(text: "Please select the payment method".tr());
          return;
        }
      }
      building =
          _receiverBuildingController.text.isNotEmpty ? 'building'.tr() : '';
      flat = _receiverFlatController.text.isNotEmpty ? 'flat'.tr() : '';
      floor = _receiverFloor.text.isNotEmpty ? 'floor'.tr() : '';
      if (receiverPayCheckedValue) {
        packagesList.forEach((element) {
          if (element.deductFromCod == "1") {
            missData2 = true;
          } else {
            missData2 = false;
          }
        });
      } else {
        missData2 = false;
      }
      if(_currentReceiverCitySelected?.cod == "0"){

       for(int x = 0 ; x < packagesList.length ; x++){
         if(packagesList[x].packaging == "4" || packagesList[x].packaging == "6"){
           unsupportedPackaging = true;
           x = packagesList.length ;
         }else{
           unsupportedPackaging =  false;
         }
       }


      }else{
        unsupportedPackaging = false;

      }
      if (missData2) {
        ComFunctions.showToast(
            color: Colors.red,
            text:
                'You can check to pay for shipping from the goods price or make receiver pay for it'
                    .tr());
      }

      else if(unsupportedPackaging){
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
      }

      else {
        if (locationSelected == false ||
            mapUrlSender == '' ||
            mapUrlSender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please Select Your Pick Location'.tr(),
                style: TextStyle(color: Colors.white,
              ),
            ),
          ));
        } else {
          if (packagesList.length == 0) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text('Pleas Add your packages'.tr()),
                      actions: [
                        ElevatedButton(
                          child: Text('ok'.tr()),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ]);
                });
          }
          else {
            List<Packages> packagesWithCod = [];
            List<Packages> packagesWithoutCod = [];
            packagesWithCod.addAll(packagesList.where((element) =>
                element.cod != '' &&
                element.cod != null &&
                element.cod != '0'));
            packagesWithoutCod.addAll(packagesList.where((element) =>
                element.cod != '' &&
                element.cod != null &&
                element.cod != '0'));

            if ((packagesWithCod.isNotEmpty || receiverPayCheckedValue) && _currentReceiverCitySelected!.cod == "0") {
              missData = true;
            } else {
              missData = false;
            }
            if (missData) {
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
                              // _currentReceiverCitySelected = newValue;
                              // _currentZoneReceiver = _currentReceiverCitySelected.neighborhoods.first;
                              // packagesList.clear();
                              Navigator.pop(context);
                            },
                          ),
                        ]);
                  });
            } else {
              OrdersDataModelMix editedOrderModel = OrdersDataModelMix();
              _postOrderDataModel.packages = packagesList;
              _postOrderDataModel.senderName = _senderNameController.text;
              _postOrderDataModel.senderPhone = _senderPhoneController.text;
              _postOrderDataModel.pickupNeighborhood = _currentZone?.id;
              _postOrderDataModel.pickupAddress = _senderAddressController.text;
              _postOrderDataModel.pickupMap = mapUrlSender;
              // _postOrderDataModel.pickupTime = _currentTimeSelected!.id;
              _postOrderDataModel.pickupTime = pickupTime.toString() ;
              _postOrderDataModel.receiverName = _receiverNameController.text;
              _postOrderDataModel.receiverPhone = _receiverPhoneController.text;
              _postOrderDataModel.deliverNeighborhood = _currentZoneReceiver?.id;
              _postOrderDataModel.deliverCity = _currentReceiverCitySelected?.id;
              _postOrderDataModel.payment_method = paymentMethod?.id;

              _postOrderDataModel.pickupCity = _currentCitySelected?.id;
              if (_receiverAddressController.text.isEmpty &&
                  _receiverBuildingController.text.isEmpty &&
                  _receiverFloor.text.isEmpty &&
                  _receiverFlatController.text.isEmpty) {
                _postOrderDataModel.deliverAddress = '';
              } else {
                _postOrderDataModel.deliverAddress =
                    "${_receiverAddressController.text} $building ${_receiverBuildingController.text} $floor ${_receiverFloor.text} $flat ${_receiverFlatController.text}";
              }
              _postOrderDataModel.deliverMap = mapUrlReceiver;
              // _postOrderDataModel.deliverTime = "0";
              // editedOrderModel.deliverTime = "0";
              if(widget.dashboardDataModelNew?.amount < totalPrice){
                deductFromCod = false ;
              }
              _postOrderDataModel.rc = receiverPayCheckedValue ? "1" : "0";
              _postOrderDataModel.deductFromCod = deductFromCod ? "1" : "0";

              if(widget.ordersDataModel == null){
                postOrderController.postNewOrder(postOrder: _postOrderDataModel);
              }else {
                editedOrderModel.width = '0';
                editedOrderModel.height = '0';
                editedOrderModel.length = '0';
                editedOrderModel.weight = '1';
                editedOrderModel.id = widget.ordersDataModel?.id ;
                editedOrderModel.senderName = _senderNameController.text;
                editedOrderModel.senderPhone = _senderPhoneController.text;
                editedOrderModel.pickupNeighborhood = _currentZone?.id;
                editedOrderModel.pickupAddress = _senderAddressController.text;
                editedOrderModel.pickupMap = mapUrlSender;
                editedOrderModel.pickupTime = pickupTime.toString() ;
                editedOrderModel.receiverName = _receiverNameController.text;
                editedOrderModel.receiverPhone = _receiverPhoneController.text;
                editedOrderModel.deliverNeighborhood = _currentZoneReceiver?.id;
                editedOrderModel.deliverCity = _currentReceiverCitySelected?.id;
                editedOrderModel.pickupCity = _currentCitySelected?.id;
                editedOrderModel.payment_method = paymentMethod?.id;
                editedOrderModel.deliverAddress = _receiverAddressController.text ;
                editedOrderModel.deliverMap = mapUrlReceiver;
                editedOrderModel.rc = receiverPayCheckedValue ? "1" : "0";
                editedOrderModel.deductFromCod = deductFromCod ? "1" : "0";
                editedOrderModel.fragile = packagesList.first.fragile ;
                editedOrderModel.packaging = packagesList.first.packaging ;
                editedOrderModel.cod = packagesList.first.cod ;
                editedOrderModel.quantity = packagesList.first.quantity ;
                editedOrderModel.comment = packagesList.first.comment ;
                postOrderController.editOrder(ordersDataModelMix: editedOrderModel);
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
        }
      }
    } else {
      _onWidgetDidBuild(context, () {
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
            backgroundColor: Colors.red,
          ),
        );
      });
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
    if(widget.ordersDataModel == null){
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
          widget.dashboardDataModelNew?.addresses?[0].description ?? "" ;
          if (widget.dashboardDataModelNew?.addresses?[0].map != '') {
            locationSelected = true;
            mapUrlSender = widget.dashboardDataModelNew?.addresses?[0].map;
          }
        });
      } else {
      }

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
    if(widget.ordersDataModel == null){
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
    }else {
      setState(() {
        totalPrice = packagesList.first.price ?? 0.0 ;

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



      // totalPrice  =  Dialogs.CalcPackagePrice(
      //   senderCity: widget.ordersDataModel?.pickupCity ,
      //   deliverCity: widget.ordersDataModel?.deliverCity ,
      //   weightId: widget.ordersDataModel?.weight ,
      //   packagingId: widget.ordersDataModel?.packaging ,
      //   resourcesData: widget.resourcesData
      //
      // );

      edtitedPackage = Packages(
        fragile: widget.ordersDataModel?.fragile ,
        packaging: widget.ordersDataModel?.packaging,
        quantity: widget.ordersDataModel?.quantity,
        cod: widget.ordersDataModel?.cod,
        comment: widget.ordersDataModel?.comment,
        price: totalPrice

      );
      packagesList.add(edtitedPackage);
      sumPrice.add(totalPrice);

      List<ErCity> senderCities = [];
      List<ErCity> receiverCities = [];
      senderCities.addAll((widget.resourcesData?.city ?? []).where((element) =>
      element.send == "1" && (element.neighborhoods?.length ?? 0) > 0)
          .toList());
      receiverCities.addAll((widget.resourcesData?.city ?? [] ).where((element) => element.receive == "1" && element.neighborhoods!.length > 0).toList());

      for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0); i++) {
        for (int x = 0;
        x < (widget.resourcesData?.city?[i].neighborhoods?.length ?? 0); x++) {
          if (widget.ordersDataModel?.pickupNeighborhood == widget.resourcesData?.city?[i].neighborhoods?[x].id) {
            _currentCitySelected = widget.resourcesData?.city?[i];
            _currentZone = widget.resourcesData?.city?[i].neighborhoods?[x];
          }
        }
      }

      for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0); i++) {
        for (int x = 0;
        x < (widget.resourcesData?.city?[i].neighborhoods?.length ?? 0); x++) {
          if (widget.ordersDataModel?.deliverNeighborhood == widget.resourcesData?.city?[i].neighborhoods?[x].id) {
            _currentReceiverCitySelected = widget.resourcesData?.city?[i];
            _currentZoneReceiver = widget.resourcesData?.city?[i].neighborhoods?[x];
          }
        }
      }

      checkedValue2 = false;
      _senderNameController.text = widget.ordersDataModel?.senderName ?? "";
      _senderPhoneController.text = widget.ordersDataModel?.senderPhone ?? "";
      _senderAddressController.text = widget.ordersDataModel?.pickupAddress ?? "";
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
      if((widget.ordersDataModel?.pickupTime.toString().length ?? 0) > 1){

        // pickupTime = widget.ordersDataModel!.pickupTime.toString();
        try{
          pickupTime = DateTime.parse(widget.ordersDataModel?.pickupTime.toString() ?? "");

        }catch(e){
          pickupTime = DateTime.now() ;
        }

      }else {
        pickupTime = DateTime.now() ;
      }
      _receiverNameController.text = widget.ordersDataModel?.receiverName ?? "";
      _receiverPhoneController.text = widget.ordersDataModel?.receiverPhone ?? "";
      _receiverAddressController.text = widget.ordersDataModel?.deliverAddress ?? "";
      if (widget.ordersDataModel?.deliverMap != null &&
          widget.ordersDataModel?.deliverMap != '') {
        locationSelectedReceiver = true;
        mapUrlReceiver = widget.ordersDataModel?.deliverMap;
      }



    });
    for (int i = 0; i < (SavedData.resourcesData.payment_method?.length ?? 0); i++){
      if(widget.ordersDataModel?.payment_method == SavedData.resourcesData.payment_method?[i].id){
        paymentMethod = SavedData.resourcesData.payment_method?[i];
      }
    }
  }


  @override
  void initState() {
    pickupTime = DateTime.now() ;
    if(widget.ordersDataModel != null){
      getOrderData();
    }
    try {
      setThePackagingType();
      senderCities.addAll((widget.resourcesData?.city ?? []).where((element) => element.send == "1" && element.neighborhoods!.length > 0).toList());
      receiverCities.addAll((widget.resourcesData?.city ?? []).where((element) => element.receive == "1" && element.neighborhoods!.length > 0).toList());
      getAddress();
    } catch (e) {
      // postOrderBloc.add(PostOrdersEventGenerateError());
    }

    ever(postOrderController.success, (bool success) {
      if (success) {
        final progress = ProgressHUD.of(context);
        progress?.dismiss();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  SuccessOrderScreen(
                    dashboardDataModel: widget.dashboardDataModelNew,
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
        // isLoading check to avoid dismissing too early or conflict
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
                    backgroundColor: Colors.red,
                  ),
                );
              });
           }
        }
      }
    });

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
    // postOrderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _enCodeController.text = '+966';
    _arCodeController.text = '966+';
    try{
      claculateTotalPrice();

    }catch(e){

    }

    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    screenWidth = size.width;
    screenHeight = size.height;
    return ProgressHUD(
      barrierEnabled: false,
        backgroundColor: Constants.blueColor,
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _drawerKey,
          body: Container(
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Expanded(
                    flex:6,
                    child: Column(
                      children: [
                     widget.ordersDataModel == null ?
                     Padding(
                       padding: const EdgeInsets.only(top: 30 , left: 10 , right: 10),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           EasyLocalization.of(context)!.locale == Locale('en') ?
                           GestureDetector(
                             onTap: (){
                               Navigator.pushAndRemoveUntil(
                                 context,
                                 MaterialPageRoute(
                                   builder: (BuildContext context) => ResourcesScreen(
                                   ),
                                 ),
                                     (route) => false,
                               );
                             },
                             child: Hero(
                               tag: 'appLogo',
                               child: Image.asset('assets/images/appstore.png',
                                 width: screenWidth!*0.22,
                                 height: screenHeight!*0.1,
                                 colorBlendMode: BlendMode.darken,
                                 // fit: BoxFit.fitWidth,
                               ),
                             ),
                           ) :
                           GestureDetector(
                             onTap: (){
                               Navigator.pushAndRemoveUntil(
                                 context,
                                 MaterialPageRoute(
                                   builder: (BuildContext context) => ResourcesScreen(
                                   ),
                                 ),
                                     (route) => false,
                               );
                             },
                             child: Hero(
                               tag: 'appLogo',
                               child: Image.asset('assets/images/logo-ar.png',
                                 width: screenWidth!*0.22,
                                 height: 50,
                                 colorBlendMode: BlendMode.darken,
                                 // fit: BoxFit.fitWidth,
                               ),
                             ),
                           ),


                           Column(
                             children: [
                               SizedBox(height: screenHeight!*0.02,),
                               widget.packagingType == "liquid" ?
                               Image.asset("assets/images/OIL.png" , height: 80 ,) : widget.packagingType == "frozen" ?
                               Image.asset("assets/images/refrigerated.png" , height: 70 ,) : Image.asset("assets/images/CARTON.png" , height: 80 ,)

                             ],
                           )

                         ],
                       ),
                     )
                         : Container(),
                      widget.ordersDataModel == null ?
                      Padding(
                          padding: EdgeInsets.only(
                              right: screenWidth! * 0.03,
                              left: screenWidth! * 0.03,
                          ),child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios , size: 16, color: addPackageDarkColor,),
                                Text("Back".tr() , style: TextStyle(color: addPackageDarkColor , fontSize: 16),)
                              ],
                            ),
                          ),
                        ) : SizedBox(),
                        Expanded(
                          child: SingleChildScrollView(
                            key: const ValueKey("addOrderScroll"),
                            child: Column(
                              children: [
                             widget.ordersDataModel == null ?
                             SizedBox():  Padding(
                               padding: EdgeInsets.only(
                                   right: screenWidth! * 0.03,
                                   left: screenWidth! * 0.03,
                                   top: screenHeight! * 0.05
                               ),
                               child: Row(
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
                                                     'Shipment id :'.tr(),
                                                     style: TextStyle(fontSize: 12),
                                                   ),
                                                   SizedBox(
                                                     width: 5,
                                                   ),
                                                   Text(
                                                     widget.ordersDataModel!.id!,
                                                     style: TextStyle(fontSize: 12),
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
                             ),

                                SizedBox(
                                  height: screenHeight! * 0.04,
                                ),
                                _buildAddOrderScreen(context),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: HomeButton()),

                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildAddOrderScreen(context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth! * 0.03,
      ),
      child: Form(
        key: _formKey,
        child: Column(
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
             widget.ordersDataModel == null ?   Padding(
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
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: checkedValue2
                                      ? Color(0xFF4C8FF8)
                                      : Colors.grey)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Color(0xFF4C8FF8),
                                ),
                                child: SizedBox(
                                    height: 20.0,
                                    width: 20.0,
                                    child: CustomCheckBox(
                                      checkedColor: Color(0xFF4C8FF8),
                                      unCheckedColor: Colors.grey,
                                      backgroundColor: Colors.white,
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
                                        ? Color(0xFF4C8FF8)
                                        : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )) : Container(),
              ],
            ),
            (widget.dashboardDataModelNew?.addresses?.length ?? 0) > 0 &&
                !checkedValue2
                ? Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  height: screenHeight! * 0.06,
                  width: screenWidth,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Text(
                              'My Addresses'.tr(),
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          )),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Addresses>(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                            },
                            items: widget.dashboardDataModelNew?.addresses?.map((Addresses dropDownStringItem) {
                              return DropdownMenuItem<Addresses>(
                                value: dropDownStringItem,
                                child: AutoSizeText(
                                  dropDownStringItem.title!.tr(),
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (Addresses? newValue) {
                              setState(() {
                                _currentSelectedAddress = newValue;

                                checkedValue2 = false;
                                if (_currentSelectedAddress!.map ==
                                    '') {
                                  resetGoogleMaps();
                                } else {
                                  setGoogleMaps(
                                      _currentSelectedAddress!.map);
                                }
                                _senderAddressController.text =
                                _currentSelectedAddress!
                                    .description!;

                                for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0);
                                i++) {
                                  for (int x = 0;
                                  x < (widget.resourcesData!.city![i].neighborhoods?.length ?? 0);
                                  x++) {
                                    if (_currentSelectedAddress?.city ==
                                        widget.resourcesData?.city![i]
                                            .neighborhoods?[x].id) {
                                      _currentCitySelected = widget
                                          .resourcesData?.city?[i];
                                      _currentZone = widget.resourcesData?.city?[i].neighborhoods![x];
                                    }
                                  }
                                }
                              });
                            },
                            value: _currentSelectedAddress,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
                : Container(),
             widget.ordersDataModel == null ?
              !checkedValue2 && (widget.dashboardDataModelNew?.addresses?.length ?? 0) > 0 ?
                 Container()
                : buildSenderData() : buildSenderData() ,
            Row(
              children: [
                Text(
                  'Pickup Time'.tr(),
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            DateTimeFormField(
             decoration: kTextFieldDecoration.copyWith(
               hintText: 'Pickup time'.tr(),
               suffixIcon: Icon(Icons.event_note, color: Constants.blueColor,),

             ),
             mode: DateTimeFieldPickerMode.dateAndTime,
             dateFormat:DateFormat('yyyy-MM-dd hh:mm aaa') ,
             onChanged: (DateTime? value) {
               pickupTime = value! ;
             },
              onSaved: (value) {
                pickupTime = value ?? DateTime.now() ;
              },
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
                        if (_receiverPhoneController.text.isEmpty) {
                          return '';
                        }
                        if (!phoneValidation(
                            _receiverPhoneController.text)) {
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
                  //             contentPadding: EdgeInsets.all(15),
                  //             hintText: '5xx-xxx-xxx',
                  //         ),
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
                  //       color: Constants.blueColor,
                  //       borderRadius: BorderRadius.circular(12)
                  //     ),
                  //     textFieldConfiguration: TextFieldConfiguration(
                  //         autofocus: false,
                  //         decoration: kTextFieldDecoration2.copyWith(
                  //             contentPadding: EdgeInsets.all(15),
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
                        if (_receiverPhoneController.text.isEmpty) {
                          return '';
                        }
                        if (!phoneValidation(
                            _receiverPhoneController.text)) {
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

            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                key: const ValueKey('receiverName'),
                focusNode: receiverNameFocus,
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(receiverPhoneFocus);
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


            Column(
              children: [
                Container(
                  height: screenHeight! * 0.08,
                  width: screenWidth,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'City'.tr(),
                            style: TextStyle(
                                fontSize: 14, color: Colors.black87),
                          )),
                      // receiverCities.length > 0
                      //     ?     Expanded(
                      //   child: DropdownSearch<ErCity?>(
                      //     key: const ValueKey('receiverCity'),

                      //     // dropdownSearchDecoration: // FIXME: API changed to dropdownDecoratorProps kTextFieldDecoration2.copyWith(
                      //         hintText: ""
                      //     ),
                      //     searchBoxDecoration: kTextFieldDecoration.copyWith(
                      //         hintText: "City name ..".tr(),
                      //         suffixIcon: Icon(Icons.search)
                      //     ),
                      //     label: "",
                      //     items: receiverCities,
                      //     searchBoxController: searchBoxCityRController,
                      //     maxHeight: screenHeight!*0.8,
                      //     showSearchBox: true,
                      //     selectedItem: _currentReceiverCitySelected ,
                      //     itemAsString: (ErCity? u) => u!.name ?? "",
                      //     emptyBuilder: (context , string){
                      //       return Center(child: Text('No results'.tr()));
                      //     },
                      //     // mode: Mode.bottomSheet // FIXME: API changed ,
                      //     enabled: true,
                      //     onChanged: (value){

                      //       setState(() {
                      //         _currentReceiverCitySelected = value;
                      //         _currentZoneReceiver = Neighborhoods();
                      //         searchBoxCityRController.clear();

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
                      //     ?     Expanded(
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
                      // )
                      //     : Container(),
                    ],
                  ),
                ),
              ],
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  color: Color(0xFF56D340), width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Image.asset(
                                  "assets/images/GOOGLE MAP ICON.png",
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
                      //                 bottomPosition:
                      //                     40.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                      //                 leftPosition: 10.0,
                      //                 rightPosition: 10.0,
                      //                 width: 500,
                      //                 elevation: 5,
                      //                 borderRadius: BorderRadius.circular(12.0),
                      //                 child: Padding(
                      //                   padding: EdgeInsets.only(
                      //                       top: 10, bottom: 10),
                      //                   child: selectedPlace != null
                      //                       ? Column(
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.center,
                      //                           children: [
                      //                             Padding(
                      //                               padding:
                      //                                   const EdgeInsets.all(
                      //                                       2.0),
                      //                               child: Text(
                      //                                 selectedPlace
                      //                                     .formattedAddress!,
                      //                                 style: TextStyle(
                      //                                     fontSize: 18),
                      //                               ),
                      //                             ),
                      //                             SizedBox(height: 10),
                      //                             ElevatedButton(
                      //                               child: Text('Save'.tr()),
                      //                               onPressed: () {
                      //                                 setState(() {
                      //                                   _deliverPickedLocation =
                      //                                       selectedPlace;
                      //                                   _receiverAddressController
                      //                                           .text =
                      //                                       _deliverPickedLocation!
                      //                                           .formattedAddress
                      //                                           .toString();

                      //                                   locationSelectedReceiver =
                      //                                       true;

                      //                                   mapUrlReceiver =
                      //                                       'https://www.google.com/maps/search/?api=1&query=${_deliverPickedLocation!.geometry!.location.lat},${_deliverPickedLocation!.geometry!.location.lng}';
                      //                                 });
                      //                                 Navigator.of(context)
                      //                                     .pop();
                      //                               },
                      //                             ),
                      //                           ],
                      //                         )
                      //                       : Center(
                      //                           child:
                      //                               CustomLoading()),
                      //                 ),
                      //               );
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
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AutoSizeText(
                            "${_receiverAddressController.text}",
                            maxLines: 3,
                          ),
                        )),
                  )
                : Container(),
         widget.ordersDataModel == null ? Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('receiverBuilding'),
                    focusNode: receiverBuildingFocus,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(receiverFloorFocus);
                    },
                    controller: _receiverBuildingController,
                    decoration: kTextFieldDecoration2.copyWith(
                        hintText: 'Building optional'.tr(),
                        hintStyle: TextStyle(fontSize: 11)),
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
                      FocusScope.of(context).requestFocus(receiverFlatFocus);
                    },
                    controller: _receiverFloor,
                    decoration: kTextFieldDecoration2.copyWith(
                        hintText: 'Floor optional'.tr(),
                        hintStyle: TextStyle(fontSize: 11)),
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
                    decoration: kTextFieldDecoration2.copyWith(
                        hintText: 'Flat optional'.tr(),
                        hintStyle: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ) : Container(),
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
                      'Packages'.tr(),
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

          widget.ordersDataModel == null ?
          GestureDetector(
              key: const ValueKey('addPackage'),
              onTap: () async {
                FocusScope.of(context).unfocus();
                if (_currentCitySelected!.name == null ||
                    _currentZone!.name == null) {
                  ComFunctions.showToast(
                      color: Colors.red,
                      text: "Please select the sender city and zone".tr());
                } else if (_currentReceiverCitySelected!.name == null ||
                    _currentZoneReceiver!.name == null) {
                  ComFunctions.showToast(
                      color: Colors.red,
                      text: "Please select the receiver city and zone".tr());
                } else if (packagesList.length >= 10) {
                  ComFunctions.showToast(
                      color: Colors.red,
                      text: "Maximum limit for packages is 10".tr());
                } else {
                  try {
                    Packages newPackage = await Dialogs.CreateShipmentDialog(
                        context,
                        _currentCitySelected!,
                        _currentReceiverCitySelected!,
                        _currentZone!,
                        _currentZoneReceiver!,
                        screenWidth!,
                        screenHeight!,
                        null,
                      widget.packagingType,

                     );
                    packagesList.add(newPackage);
                    sumPrice.add(newPackage.price!);
                    setState(() {});
                  } catch (e) {}

                }
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  width: screenWidth,
                  height: screenHeight! * 0.08,
                  decoration: BoxDecoration(
                      color: addPackageLightColorColor,
                      border: Border.all(color: addPackageDarkColor, width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SvgPicture.asset(
                                "assets/images/add-package.svg",
                                placeholderBuilder: (context) =>
                                    CustomLoading(),
                                color: addPackageDarkColor
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                      Text(
                            'Add Package'.tr(),
                            style: TextStyle(
                              color: addPackageDarkColor,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '(${packagesList.length})',
                          style: TextStyle(
                              color: addPackageDarkColor, fontSize: 19),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ) : Container(),
          SizedBox(height: 10,),


          packagesList.length != 0?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: packagesList.length * 110.0, minHeight: 90),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: packagesList.length,
                      itemBuilder: (context, i) {
                        // return _buildAreas(index: i);
                        return PackageCard(
                          // packages: packagesList[i],
                          currentCitySelected: _currentCitySelected,
                          currentReceiverCitySelected: _currentReceiverCitySelected,
                          currentZone: _currentZone,
                          currentZoneReceiver: _currentZoneReceiver,
                          packagesList: packagesList,
                          index: i,
                          newPackage: widget.ordersDataModel == null ? true : false,
                          deleteBtnFun: (){
                            setState(() {
                              sumPrice.removeAt(i);
                              packagesList.removeAt(i);
                            });
                            },

                        );
                      },
                    ),
                  ),
                ],
              ) : Container(),
            totalPrice > 0 && widget.ordersDataModel == null
                ? Container(
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Color(0xffF1F1F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            'Total Price'.tr(),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w100),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$totalPrice',
                                style: TextStyle(
                                    fontSize: 28,
                                    color: widget.packagingType == "liquid"
                                        ? addPackageDarkColor
                                        : Color(0xFF6F94E7),
                                    fontWeight: FontWeight.w900),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                'SR'.tr(),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            "(Taxes Included)".tr(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
                _paymentMethodDialog(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0 , vertical: 10),
                child: Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Constants.blueColor, width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text( paymentMethod?.name ?? "Choose payment method".tr() ,
                      style: TextStyle(
                          fontSize: 16 , color: Colors.black
                      ),),
                  ),
                ),
              ),
            ),
            // Padding(
            //     padding: EdgeInsets.only(bottom: 10),
            //     child: Center(
            //       child: Container(
            //         decoration: BoxDecoration(
            //             color: Colors.white,
            //             borderRadius: BorderRadius.circular(8),
            //             // border: Border.all(color: receiverPayCheckedValue ?  Color(0xFF4C8FF8):Colors.grey)
            //             border: Border.all(color: Colors.grey)),
            //         child: Padding(
            //           padding: const EdgeInsets.all(5.0),
            //           child: Column(
            //             children: [
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: [
            //                   Expanded(
            //                     child: GestureDetector(
            //                       onTap: () {
            //                         setState(() {
            //                           receiverPayCheckedValue =
            //                               !receiverPayCheckedValue;
            //                           deductFromCod = false;
            //                           deductFromOfferCheckedValue = false;
            //                         });
            //                       },
            //                       child: Row(
            //                         mainAxisAlignment: MainAxisAlignment.start,
            //                         children: [
            //                           Theme(
            //                             data: Theme.of(context).copyWith(
            //                               unselectedWidgetColor: Colors.black54,
            //                             ),
            //                             child: SizedBox(
            //                                 height: 15,
            //                                 width: 15,
            //                                 child: CustomCheckBox(
            //                                   checkedColor: Color(0xFF4C8FF8),
            //                                   unCheckedColor: Colors.grey,
            //                                   color: Colors.white,
            //                                   checked: receiverPayCheckedValue,
            //                                 )),
            //                           ),
            //                           SizedBox(
            //                             width: 3,
            //                           ),
            //                           Flexible(
            //                             child: Text(
            //                               'Shipping on receiver'.tr(),
            //                               maxLines: 2,
            //                               style: TextStyle(
            //                                   fontSize: 14,
            //                                   color: receiverPayCheckedValue
            //                                       ? Color(0xFF4C8FF8)
            //                                       : Colors.black87),
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                   (widget.dashboardDataModelNew?.offers?.isNotEmpty ?? false)
            //                       ? Expanded(
            //                         child: GestureDetector(
            //                             onTap: () {
            //                               setState(() {
            //                                 deductFromOfferCheckedValue =
            //                                     !deductFromOfferCheckedValue;
            //                                 deductFromCod = false;
            //                                 receiverPayCheckedValue = false;
            //                               });
            //                             },
            //                             child: Row(
            //                               mainAxisAlignment: MainAxisAlignment.start,
            //                               children: [
            //                                 Theme(
            //                                   data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.black54,
            //                                   ),
            //                                   child: SizedBox(
            //                                       height: 15,
            //                                       width: 15,
            //                                       child: CustomCheckBox(
            //                                         checkedColor: Color(0xFF4C8FF8),
            //                                         unCheckedColor: Colors.grey,
            //                                         color: Colors.white,
            //                                         checked: deductFromOfferCheckedValue,
            //                                       )),
            //                                 ),
            //                                 SizedBox(
            //                                   width: 5,
            //                                 ),
            //                                 Flexible(
            //                                   child: Shimmer.fromColors(
            //                                     baseColor: Colors.black,
            //                                     highlightColor: Colors.grey,
            //                                     child: Text(
            //                                       'Deduct from offer'.tr(),
            //                                       maxLines: 2,
            //                                       style: TextStyle(
            //                                           fontSize: 14,
            //                                           color: deductFromOfferCheckedValue ? Color(0xFF4C8FF8) : Colors.black87),
            //                                     ),
            //                                   ),
            //                                 )
            //                               ],
            //                             ),
            //                           ),
            //                       )
            //                       : Container()
            //                 ],
            //               ),
            //               SizedBox(
            //                 height: 8,
            //               ),
            //               (widget.dashboardDataModelNew?.amount ?? 0) > totalPrice
            //                   ? Row(
            //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         Expanded(
            //                           child: GestureDetector(
            //                             onTap: () {
            //                               setState(() {
            //                                 deductFromCod = !deductFromCod;
            //                                 receiverPayCheckedValue = false;
            //                                 deductFromOfferCheckedValue = false;
            //                               });
            //                             },
            //                             child: Row(
            //                               mainAxisAlignment: MainAxisAlignment.start,
            //                               crossAxisAlignment: CrossAxisAlignment.center,
            //                               children: [
            //                                 Theme(
            //                                   data: Theme.of(context).copyWith(
            //                                     unselectedWidgetColor:
            //                                         Colors.black54,
            //                                   ),
            //                                   child: SizedBox(
            //                                       height: 15,
            //                                       width: 15,
            //                                       child: CustomCheckBox(
            //                                         checkedColor:
            //                                             Color(0xFF4C8FF8),
            //                                         unCheckedColor: Colors.grey,
            //                                         color: Colors.white,
            //                                         checked: deductFromCod,
            //                                       )),
            //                                 ),
            //                                 SizedBox(
            //                                   width: 5,
            //                                 ),
            //                                 Flexible(
            //                                   child: Text(
            //                                     'deductFromCod'.tr(),
            //                                     maxLines: 2,
            //                                     style: TextStyle(
            //                                         fontSize: 14,
            //                                         color: deductFromCod ? Color(0xFF4C8FF8) : Colors.black87),
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                           ),
            //                         ),
            //                         Row(
            //                           mainAxisAlignment: MainAxisAlignment.start,
            //                           children: [
            //                             Container(
            //                               // width: screenWidth! * 0.15,
            //                               child: AutoSizeText(
            //                                 'Balance:'.tr(),
            //                                 style: TextStyle(
            //                                     fontSize: 14,
            //                                     color: Colors.black87),
            //                               ),
            //                             ),
            //                             SizedBox(
            //                               width: 5,
            //                             ),
            //                             Container(
            //                               // height: screenHeight! * 0.03,
            //                               // width: screenWidth! * 0.2,
            //                               decoration: ShapeDecoration(
            //                                 color:
            //                                     Colors.red.withOpacity(0.6),
            //                                 shape: RoundedRectangleBorder(
            //                                   borderRadius:
            //                                       BorderRadius.circular(20.0),
            //                                 ),
            //                               ),
            //                               child: Center(
            //                                 child: Padding(
            //                                   padding: const EdgeInsets.only(
            //                                       left: 15, right: 15),
            //                                   child: Text(
            //                                       widget.dashboardDataModelNew?.amount.toString() ?? "",
            //                                       style: TextStyle(
            //                                           fontSize: 15,
            //                                           color: Colors.white)),
            //                                 ),
            //                               ),
            //                             ),
            //                           ],
            //                         )
            //                       ],
            //                     )
            //                   : Container(),
            //             ],
            //           ),
            //         ),
            //       ),
            //     )),

          widget.ordersDataModel == null ? Padding(
              padding: EdgeInsets.only(top: 5, bottom: 15),
              child: ButtonTheme(
                minWidth: screenWidth!,
                height: 50,
                child: ElevatedButton(
                
                    // widget.packagingType == "liquid"
                    //     ? addPackageDarkColor
                    //     : Colors.blue,
                    child: Text(
                      'Add Order'.tr(),
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () {
                      _onLoginButtonPressed();
                    }),
              ),
            ) :
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 15),
            child: ButtonTheme(
              minWidth: screenWidth!,
              height: 50,
              child: ElevatedButton(
                
                  child: Text(
                    'Edit Order'.tr(),
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    _onLoginButtonPressed();
                  }),
            ),
          ) ,
          ],
        ),
      ),
    );
  }

  Widget _buildAreas({required int index}) {
    bool checkedBoxLocal =
        packagesList.elementAt(index).fragile == "1" ? true : false;

    double codDoubleValue = 0;
    String? packaging;
    String? currentWeight;
    String? packageType = packagesList.elementAt(index).packaging;
    String? quantity = packagesList.elementAt(index).quantity;
    String? currentWeightId = packagesList.elementAt(index).weight;
    for (int i = 0; i < widget.resourcesData!.packaging!.length; i++) {
      if (packageType == widget.resourcesData!.packaging![i].id) {
        packaging = widget.resourcesData!.packaging![i].name;
      }
    }


    if (packagesList.elementAt(index).cod != "" &&
        packagesList.elementAt(index).cod != null) {
      codDoubleValue = double.parse(packagesList.elementAt(index).cod!);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Container(
          width: width,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(197, 197, 197, 0.1),
                //Colors.black26,
                blurRadius: 3.0, // soften the shadow
                spreadRadius: 3, //extend the shadow
              )
            ],
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.withOpacity(0.5), //deepOrange,
              width: 1,
              //borderRadius: BorderRadius.circular(radius),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  packagesList.elementAt(index).packaging == '1'
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: SvgPicture.asset(
                            "assets/images/regular.svg",
                            height: screenHeight! * 0.05,
                          ),
                        )
                      : packagesList.elementAt(index).packaging == '2'
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: SvgPicture.asset(
                                "assets/images/save.svg",
                                height: screenHeight! * 0.05,
                              ),
                            )
                          : packagesList.elementAt(index).packaging == '3'
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  child: SvgPicture.asset(
                                    "assets/images/liquid.svg",
                                    height: screenHeight! * 0.05,
                                  ),
                                )
                              : packagesList.elementAt(index).packaging == '4'
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: SvgPicture.asset(
                                        "assets/images/cold.svg",
                                        height: screenHeight! * 0.05,
                                      ),
                                    )
                                  : packagesList.elementAt(index).packaging ==
                                          '6'
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          child: Image.asset(
                                            'assets/images/coldCartoon.png',
                                            height: screenHeight! * 0.05,
                                            // fit: BoxFit.fitWidth,
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          child: SvgPicture.asset(
                                            "assets/images/save.svg",
                                            height: screenHeight! * 0.05,
                                          ),
                                        ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Type :'.tr(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth! * 0.03),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              packaging!,
                              style: TextStyle(fontSize: screenWidth! * 0.03),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            checkedBoxLocal
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fragile'.tr(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: screenWidth! * 0.03),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                        packagesList.elementAt(index).cod != "0" &&
                                packagesList.elementAt(index).cod != ""
                            ? Row(
                                children: [
                                  Text(
                                    'cash on delivery'.tr(),
                                    style: TextStyle(
                                        fontSize: screenWidth! * 0.03),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    packagesList.elementAt(index).cod ?? '',
                                    style: TextStyle(
                                        fontSize: screenWidth! * 0.03),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    'SR'.tr(),
                                    style: TextStyle(
                                        fontSize: screenWidth! * 0.02),
                                  ),
                                ],
                              )
                            : Container(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'No. of pieces :'.tr(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth! * 0.03),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              packagesList.elementAt(index).quantity.toString(),
                              style: TextStyle(fontSize: screenWidth! * 0.03),
                            ),
                          ],
                        ),
                        packagesList.elementAt(index).comment != '' &&
                                packagesList.elementAt(index).comment != null
                            ? Container(
                                width: screenWidth! * 0.5,
                                child: AutoSizeText(
                                  '${packagesList.elementAt(index).comment}',
                                  maxLines: 2,
                                  minFontSize: 7,
                                  maxFontSize: 11,
                                ))
                            : Container(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Price :'.tr(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth! * 0.03),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  packagesList
                                      .elementAt(index)
                                      .price
                                      .toString(),
                                  style:
                                      TextStyle(fontSize: screenWidth! * 0.03),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'SR'.tr(),
                                  style: TextStyle(fontSize: 8),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // checkedBoxLocal ? Text('-') : Container(),

              Row(
                children: [
                  InkWell(
                      onTap: () async {
                        try {
                          packagesList[index] =
                              await Dialogs.CreateShipmentDialog(
                                  context,
                                  _currentCitySelected!,
                                  _currentReceiverCitySelected!,
                                  _currentZone!,
                                  _currentZoneReceiver!,
                                  screenWidth!,
                                  screenHeight!,
                                  packagesList.elementAt(index),
                              null);
                          setState(() {});
                        } catch (e) {}
                      },
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: width! * 0.01,
                            right: width! * 0.02,
                            bottom: width! * 0.01,
                          ),
                          child: Container(
                              child: Center(
                                  child: Icon(
                            Icons.edit,
                            color: Colors.black87,
                            size: width! * 0.05,
                          ))))),
                  InkWell(
                      onTap: () {
                        setState(() {
                          packagesList.removeAt(index);
                          sumPrice.removeAt(index);
                        });
                      },
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: width! * 0.01,
                              right: width! * 0.02,
                              bottom: width! * 0.01,
                              left: width! * 0.02),
                          child: Container(
                              child: Center(
                                  child: Icon(
                            Icons.delete_forever_outlined,
                            color: Color(0xFFF4693F),
                            size: width! * 0.05,
                          ))))),
                ],
              )
            ],
          )),
    );
  }

  Widget buildSenderData(){
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
                  FocusScope.of(context)
                      .requestFocus(senderPhoneFocus);
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
                        if (_senderPhoneController
                            .text.isEmpty) {
                          return '';
                        }
                        if (!phoneValidation(
                            _senderPhoneController.text)) {
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
                          return 'Please enter your mobile'
                              .tr();
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
                        FilteringTextInputFormatter
                            .digitsOnly
                      ],
                      decoration:
                      kTextFieldDecoration2.copyWith(
                        labelText: 'phone number'.tr(),
                        hintText: '5xx-xxx-xxx',
                        border: null,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 0.5),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue,
                              width: .5),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12.0)),
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
                          return 'Please enter your mobile'
                              .tr();
                        }
                        if (!phoneValidation(value)) {
                          return 'please enter a valid mobile number'
                              .tr();
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(9),
                        FilteringTextInputFormatter
                            .digitsOnly
                      ],
                      decoration:
                      kTextFieldDecoration2.copyWith(
                        labelText: 'phone number'.tr(),
                        hintText: '5xx-xxx-xxx',
                        border: null,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 0.50),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blue,
                              width: .50),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12.0)),
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
                        if (_senderPhoneController
                            .text.isEmpty) {
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
            Container(
              height: screenHeight! * 0.08,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'City'.tr(),
                        style: TextStyle(
                            fontSize: 14, color: Colors.black87),
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
                  //        _currentZone = Neighborhoods();
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
                  //     ?
                  // Expanded(
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
                  //     items: _currentCitySelected!.neighborhoods ?? [],
                  //     searchBoxController: searchBoxZoneController,
                  //     showSearchBox: true,
                  //     selectedItem: _currentZone,
                  //     itemAsString: (Neighborhoods? u) => u!.name ?? "",
                  //     emptyBuilder: (context , string){
                  //       return Center(child: Text('No results'.tr()));
                  //     },
                  //     // mode: Mode.bottomSheet // FIXME: API changed ,
                  //     enabled: true,
                  //     onChanged: (value){;
                  //     setState(() {
                  //       _currentZone = value;
                  //       searchBoxZoneController.clear();
                  //     });
                  //     },
                  //     clearButton: Icon(Icons.close),
                  //   ),
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
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    ComFunctions.launchURL(mapUrlSender!);
                  },
                  child: Container(
                    width: screenWidth! * 0.6,
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
                    border: Border.all(
                        color: Colors.grey, width: 2),
                    borderRadius:
                    BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                      borderRadius:
                      BorderRadius.circular(12)),
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
    ) ;
  }




  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }

  _paymentMethodDialog(BuildContext context){
    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return PaymentMethodDialog(paymentMethod: (selectedMethod){
            setState(() {
              paymentMethod = selectedMethod ;
            });
          },);
        });
  }

}
