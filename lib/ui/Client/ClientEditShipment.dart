// import 'dart:convert';
// import 'package:date_time_picker/date_time_picker.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker/google_maps_place_picker.dart';
// import 'package:xturbox/ui/custom%20widgets/customCheckBox.dart';
//
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:easy_localization/easy_localization.dart';
//
// import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
// import 'package:xturbox/blocs/bloc/clientCancelOrder_bloc.dart';
// import 'package:xturbox/blocs/bloc/postOrders_bloc.dart';
// import 'package:xturbox/blocs/events/authentication_events.dart';
// import 'package:xturbox/blocs/events/clientCancelOrder_events.dart';
// import 'package:xturbox/blocs/events/postOrder_events.dart';
// import 'package:xturbox/blocs/states/clientCancelOrder_states.dart';
// import 'package:xturbox/blocs/states/postOrders_states.dart';
// import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
// import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
// import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
// import 'package:xturbox/data_providers/models/postOrderData.dart';
// import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
// import 'package:xturbox/ui/chooseLanguageScreen.dart';
// import 'package:xturbox/ui/dashboard.dart';
// import 'package:xturbox/utilities/Constants.dart';
// import 'package:xturbox/utilities/GeneralHandling.dart';
// import 'package:xturbox/utilities/comFunctions.dart';
//
// import '../UserRepo.dart';
// import 'HomeScreenNew.dart';
// import 'MyOrders.dart';
// import 'custom widgets/NetworkErrorView.dart';
// import 'custom widgets/drawerClient.dart';
// import 'custom widgets/myAppBar.dart';
//
// class ClientEditShipment extends StatefulWidget {
//   ProfileDataModel? dashboardDataModelNew;
//   ResourcesData? resourcesData;
//   OrdersDataModelMix? ordersDataModel;
//   ClientEditShipment(
//       {this.resourcesData, this.ordersDataModel, this.dashboardDataModelNew});
//   @override
//   _ClientEditShipmentState createState() => _ClientEditShipmentState();
// }
//
// class _ClientEditShipmentState extends State<ClientEditShipment> {
//   final _senderNameController = TextEditingController();
//   final _senderPhoneController = TextEditingController();
//   final _senderAddressController = TextEditingController();
//   final _senderMapController = TextEditingController();
//   final _receiverNameController = TextEditingController();
//   final _receiverPhoneController = TextEditingController();
//   final _receiverAddressController = TextEditingController();
//   final _receiverMapController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _passwordConfirmationController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _packageWeightController = TextEditingController();
//   final _packageLengthController = TextEditingController();
//   final _packageWidthController = TextEditingController();
//   final _packageHeightController = TextEditingController();
//   final _packageCommentController = TextEditingController();
//   final _receiverFloor = TextEditingController();
//   final _receiverBuildingController = TextEditingController();
//   final _receiverFlatController = TextEditingController();
//
//   FocusNode senderNameFocus = FocusNode();
//   FocusNode senderPhoneFocus = FocusNode();
//   FocusNode senderCityFocus = FocusNode();
//   FocusNode senderAddressFocus = FocusNode();
//   FocusNode senderPickupTimeFocus = FocusNode();
//   FocusNode receiverNameFocus = FocusNode();
//   FocusNode receiverPhoneFocus = FocusNode();
//   FocusNode receiverCityFocus = FocusNode();
//   FocusNode receiverAddressFocus = FocusNode();
//   FocusNode receiverBuildingFocus = FocusNode();
//   FocusNode receiverFloorFocus = FocusNode();
//   FocusNode receiverFlatFocus = FocusNode();
//   FocusNode zoneFocus = FocusNode();
//   FocusNode zoneFocusReceiver = FocusNode();
//
//   ErCity? _currentCitySelected = ErCity();
//   ErCity? _currentReceiverCitySelected = ErCity();
//   Cancellation? _currentTimeSelected = Cancellation();
//   Neighborhoods? _currentZone = Neighborhoods();
//   Neighborhoods? _currentZoneReceiver = Neighborhoods();
//
//   double? width, height;
//   double? screenWidth, screenHeight;
//   List<Packages> packagesList = [];
//   PostOrderBloc postOrderBloc = PostOrderBloc();
//   double totalPrice = 0;
//   PostOrderDataModel _postOrderDataModel = PostOrderDataModel();
//   GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
//   List<double> sumPrice = [];
//   // LocationResult _pickedLocation;
//   PickResult? _pickedLocation;
//   bool locationSelected = false;
//   bool locationSelectedReceiver = false;
//   // LocationResult _delivePickedLocation;
//   PickResult? _deliverPickedLocation;
//   bool? checkedValue2 = false;
//   String? pickuplMaplLink;
//   String? deliverMapLink;
//   String? mapUrlSender;
//   String? mapUrlReceiver;
//   String savedPickupTime = "";
//
//   AuthenticationBloc authenticationBloc = AuthenticationBloc();
//   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   UserRepository userRepository = UserRepository();
//   ProfileDataModel dashboardDataModel = ProfileDataModel();
//   Addresses? _currentSelectedAddress;
//   Weight? _currentSelectedWeight;
//   Packaging? _currentSelectedPackaging;
//   bool iamSender = true;
//   List<ErCity> senderCities = [];
//   List<ErCity> receiverCities = [];
//   ClientCancelOrderBloc cancelOrderBloc = ClientCancelOrderBloc();
//   bool checkedValue = false;
//   final _codController = TextEditingController();
//   final _quantityController = TextEditingController();
//   bool? codCheckedValue = false;
//   late bool checkedBoxLocal;
//   String? packaging;
//   String? currentWeight;
//   bool? receiverPayCheckedValue;
//   double codDoubleValue = 0;
//   bool deductFromCod = false;
//   bool showReceiverPay = true;
//   final searchBoxCityController = TextEditingController();
//   final searchBoxZoneController = TextEditingController();
//   final searchBoxCityRController = TextEditingController();
//   final searchBoxZoneRController = TextEditingController();
//
//   double CalcPackagePrice(
//       {String? senderCity,
//       String? deliverCity,
//       ResourcesData? resourcesData,
//       String? weightId,
//       String? packagingId}) {
//     double total;
//     double weightPrice;
//     late double packagingPrice;
//
//     if (_currentCitySelected!.id == _currentReceiverCitySelected!.id) {
//       // for (int i = 0; i < resourcesData.weight.length; i++) {
//       //   if (weightId == resourcesData.weight[i].id) {
//       //     var weightPriceDouble =
//       //     double.parse(resourcesData.weight[i].prices[0].price);
//       //     weightPrice = weightPriceDouble;
//       //   }
//       // }
//       var weightPriceDouble =
//           double.parse(resourcesData!.weight!.first.prices![0].price!);
//       weightPrice = weightPriceDouble;
//       for (int i = 0; i < resourcesData.packaging!.length; i++) {
//         if (packagingId == resourcesData.packaging![i].id) {
//           var packagingPriceDouble =
//               double.parse(resourcesData.packaging![i].extra!);
//
//           packagingPrice = packagingPriceDouble;
//         }
//       }
//
//       total = weightPrice + packagingPrice;
//
//       return total;
//     } else {
//       // for (int i = 0; i < widget.resourcesData.weight.length; i++) {
//       //   if (weightId == widget.resourcesData.weight[i].id) {
//       //     var weightPriceDouble =
//       //     double.parse(widget.resourcesData.weight[i].prices[0].price);
//       //     weightPrice = weightPriceDouble;
//       //   }
//       // }
//       var weightPriceDouble =
//           double.parse(resourcesData!.weight!.first.prices![1].price!);
//       weightPrice = weightPriceDouble;
//
//       for (int i = 0; i < widget.resourcesData!.packaging!.length; i++) {
//         if (packagingId == widget.resourcesData!.packaging![i].id) {
//           var packagingPriceDouble =
//               double.parse(resourcesData.packaging![i].extra!);
//           // double packagingPriceDouble = 10 ;
//
//           packagingPrice = packagingPriceDouble;
//         }
//       }
//       total = weightPrice + packagingPrice;
//
//       return total;
//     }
//   }
//
//   bool phoneValidation(String value) {
//     if (value.length == 9 && value.characters.first == '5') {
//       return true;
//     }
//     return false;
//   }
//
//   _launchURL(String url) async {
//     print('launcher activated');
//     if (await canLaunch(url)) {
//       print('launcher success');
//
//       await launch(url);
//     } else {
//       print('launcher failed');
//
//       throw 'Could not launch $url';
//     }
//   }
//
//   claculateTotalPrice() {
//     double x = 0;
//     for (int i = 0; i < sumPrice.length; i++) {
//       x += sumPrice[i];
//     }
//     setState(() {
//       totalPrice = x;
//     });
//   }
//
//   restoreData() {
//     setState(() {
//       _senderNameController.text = widget.dashboardDataModelNew!.name!;
//       _senderPhoneController.text = widget.dashboardDataModelNew!.phone!;
//       if (widget.dashboardDataModelNew!.addresses!.length > 0) {
//         _currentSelectedAddress = widget.dashboardDataModelNew!.addresses![0];
//         for (int i = 0; i < widget.resourcesData!.city!.length; i++) {
//           for (int x = 0;
//               x < widget.resourcesData!.city![i].neighborhoods!.length;
//               x++) {
//             if (_currentSelectedAddress!.city ==
//                 widget.resourcesData!.city![i].neighborhoods![x].id) {
//               _currentCitySelected = widget.resourcesData!.city![i];
//               _currentZone = widget.resourcesData!.city![i].neighborhoods![x];
//             }
//           }
//         }
//         _senderAddressController.text =
//             widget.dashboardDataModelNew!.addresses![0].description!;
//
//         if (widget.dashboardDataModelNew!.addresses![0].map != '') {
//           locationSelected = true;
//           mapUrlSender = widget.dashboardDataModelNew!.addresses![0].map;
//         }
//       }
//     });
//   }
//
//   clearData() {
//     _senderNameController.clear();
//     _senderPhoneController.clear();
//     _senderAddressController.clear();
//     locationSelected = false;
//     mapUrlSender = '';
//   }
//
//   resetGoogleMaps() {
//     setState(() {
//       mapUrlSender = '';
//       locationSelected = false;
//     });
//   }
//
//   setGoogleMaps(String? map) {
//     setState(() {
//       mapUrlSender = map;
//       locationSelected = true;
//     });
//   }
//
//   getAddress() async {
//     if (widget.dashboardDataModelNew!.addresses!.length > 0) {
//       setState(() {
//         _currentSelectedAddress = widget.dashboardDataModelNew!.addresses![0];
//
//         for (int i = 0; i < widget.resourcesData!.city!.length; i++) {
//           for (int x = 0;
//               x < widget.resourcesData!.city![i].neighborhoods!.length;
//               x++) {
//             if (_currentSelectedAddress!.city ==
//                 widget.resourcesData!.city![i].neighborhoods![x].id) {
//               _currentCitySelected = widget.resourcesData!.city![i];
//               _currentZone = widget.resourcesData!.city![i].neighborhoods![x];
//             }
//           }
//         }
//
//         _senderAddressController.text =
//             widget.dashboardDataModelNew!.addresses![0].description!;
//         if (widget.dashboardDataModelNew!.addresses![0].map != '') {
//           locationSelected = true;
//           mapUrlSender = widget.dashboardDataModelNew!.addresses![0].map;
//         }
//       });
//     } else {
//       _currentCitySelected = widget.resourcesData!.city!
//           .where((element) => element.send == "1")
//           .toList()
//           .first;
//       _currentZone = _currentCitySelected!.neighborhoods!.first;
//     }
//
//     _senderNameController.text = widget.dashboardDataModelNew!.name!;
//     _senderPhoneController.text = widget.dashboardDataModelNew!.phone!;
//   }
//
//   Future<Null> getUserData() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     preferences = await SharedPreferences.getInstance();
//     Map<String, dynamic>? userMap;
//     final String? userStr = preferences.getString('userData');
//     if (userStr != null) {
//       userMap = jsonDecode(userStr) as Map<String, dynamic>?;
//     }
//     if (userMap != null) {
//       print('test 1');
//
//       final ProfileDataModel userData = ProfileDataModel.fromJson(userMap);
//       setState(() {
//         dashboardDataModel = userData;
//       });
//     }
//   }
//
//   getOrderData() async {
//     setState(() {
//       if (widget.ordersDataModel!.cod != '0' &&
//           widget.ordersDataModel!.cod != '') {
//         codCheckedValue = true;
//         _codController.text = widget.ordersDataModel!.cod!;
//       } else {
//         codCheckedValue = false;
//       }
//       _quantityController.text = widget.ordersDataModel!.quantity! == ""
//           ? "1"
//           : widget.ordersDataModel!.quantity!;
//       _packageCommentController.text = widget.ordersDataModel!.comment!;
//
//       receiverPayCheckedValue = widget.ordersDataModel!.rc != "0" &&
//               widget.ordersDataModel!.rc != "" &&
//               widget.ordersDataModel!.rc != ""
//           ? true
//           : false;
//       checkedValue = widget.ordersDataModel!.fragile == "1" ? true : false;
//       checkedBoxLocal = widget.ordersDataModel!.fragile == "1" ? true : false;
//       deductFromCod = widget.ordersDataModel!.deductFromCod != "0" &&
//               widget.ordersDataModel!.deductFromCod != "" &&
//               widget.ordersDataModel!.deductFromCod != ""
//           ? true
//           : false;
//
//       String? packageType = widget.ordersDataModel!.packaging;
//       String? currentWeightId = widget.ordersDataModel!.weight;
//       for (int i = 0; i < widget.resourcesData!.packaging!.length; i++) {
//         if (packageType == widget.resourcesData!.packaging![i].id) {
//           _currentSelectedPackaging = widget.resourcesData!.packaging![i];
//           packaging = widget.resourcesData!.packaging![i].name;
//         }
//       }
//       for (int i = 0; i < widget.resourcesData!.weight!.length; i++) {
//         if (currentWeightId == widget.resourcesData!.weight![i].id) {
//           currentWeight = widget.resourcesData!.weight![i].name;
//         }
//       }
//
//       List<ErCity> senderCities = [];
//       List<ErCity> receiverCities = [];
//       senderCities.addAll(widget.resourcesData!.city!
//           .where((element) =>
//               element.send == "1" && element.neighborhoods!.length > 0)
//           .toList());
//       receiverCities.addAll(widget.resourcesData!.city!
//           .where((element) =>
//               element.receive == "1" && element.neighborhoods!.length > 0)
//           .toList());
//
//       for (int i = 0; i < widget.resourcesData!.city!.length; i++) {
//         for (int x = 0;
//             x < widget.resourcesData!.city![i].neighborhoods!.length;
//             x++) {
//           if (widget.ordersDataModel!.pickupNeighborhood ==
//               widget.resourcesData!.city![i].neighborhoods![x].id) {
//             _currentCitySelected = widget.resourcesData!.city![i];
//             _currentZone = widget.resourcesData!.city![i].neighborhoods![x];
//           }
//         }
//       }
//
//       for (int i = 0; i < widget.resourcesData!.city!.length; i++) {
//         for (int x = 0;
//             x < widget.resourcesData!.city![i].neighborhoods!.length;
//             x++) {
//           if (widget.ordersDataModel!.deliverNeighborhood ==
//               widget.resourcesData!.city![i].neighborhoods![x].id) {
//             _currentReceiverCitySelected = widget.resourcesData!.city![i];
//             _currentZoneReceiver =
//                 widget.resourcesData!.city![i].neighborhoods![x];
//           }
//         }
//       }
//
//       checkedValue2 = false;
//       _senderNameController.text = widget.ordersDataModel!.senderName!;
//       _senderPhoneController.text = widget.ordersDataModel!.senderPhone!;
//       _senderAddressController.text = widget.ordersDataModel!.pickupAddress!;
//       if (widget.ordersDataModel!.pickupMap != null &&
//           widget.ordersDataModel!.pickupMap != '') {
//         locationSelected = true;
//         mapUrlSender = widget.ordersDataModel!.pickupMap;
//       }
//       // for (int i = 0; i < widget.resourcesData!.times!.length; i++) {
//       //   if (widget.ordersDataModel!.pickupTime ==
//       //       widget.resourcesData!.times![i].id) {
//       //     _currentTimeSelected = widget.resourcesData!.times![i];
//       //   }
//       // }
//       if(widget.ordersDataModel!.pickupTime.toString().length > 1){
//         savedPickupTime = widget.ordersDataModel!.pickupTime.toString();
//
//       }else {
//         savedPickupTime = DateTime.now().toString() ;
//       }
//
//       _receiverNameController.text = widget.ordersDataModel!.receiverName!;
//       _receiverPhoneController.text = widget.ordersDataModel!.receiverPhone!;
//       _receiverAddressController.text = widget.ordersDataModel!.deliverAddress!;
//       if (widget.ordersDataModel!.deliverMap != null &&
//           widget.ordersDataModel!.deliverMap != '') {
//         locationSelectedReceiver = true;
//         mapUrlReceiver = widget.ordersDataModel!.deliverMap;
//       }
//
//       if (widget.ordersDataModel!.cod != "" &&
//           widget.ordersDataModel!.cod != null) {
//         try {
//           codDoubleValue = double.parse(widget.ordersDataModel!.cod!);
//         } catch (e) {
//           codDoubleValue = 0.0;
//         }
//       }
//     });
//   }
//
//   OrdersDataModelMix ordersDataModelMix = OrdersDataModelMix();
//
//   _onLoginButtonPressed() {
//     if (_formKey.currentState!.validate()) {
//       if (locationSelected == false ||
//           mapUrlSender == '' ||
//           mapUrlSender == null) {
//         _drawerKey.currentState!.showSnackBar(
//           SnackBar(
//             content: Text(
//               'Please Select Your Pick Location'.tr(),
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else {
//         if (_currentReceiverCitySelected!.cod == "0" &&
//             (codCheckedValue! || receiverPayCheckedValue!)) {
//           _onWidgetDidBuild(context, () {
//             _drawerKey.currentState!.showSnackBar(
//               SnackBar(
//                 content: Text(
//                   'cash on delivery services is not available in this receiver city'
//                       .tr(),
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           });
//         } else {
//           ordersDataModelMix.width = '0';
//           ordersDataModelMix.height = '0';
//           ordersDataModelMix.length = '0';
//           ordersDataModelMix.weight = '1';
//           ordersDataModelMix.quantity = _quantityController.text.isNotEmpty
//               ? _quantityController.text
//               : "1";
//           ordersDataModelMix.fragile = checkedValue ? '1' : '0';
//           ordersDataModelMix.por = receiverPayCheckedValue! ? "1" : "0";
//           ordersDataModelMix.packaging = _currentSelectedPackaging!.id;
//           ordersDataModelMix.cod =
//               _codController.text.isEmpty ? '0' : _codController.text;
//           ordersDataModelMix.comment = _packageCommentController.text;
//           ordersDataModelMix.id = widget.ordersDataModel!.id;
//           ordersDataModelMix.senderName = _senderNameController.text;
//           ordersDataModelMix.senderPhone = _senderPhoneController.text;
//           ordersDataModelMix.pickupNeighborhood = _currentZone!.id;
//           ordersDataModelMix.deliverCity = _currentReceiverCitySelected!.id;
//           ordersDataModelMix.pickupCity = _currentCitySelected!.id;
//           ordersDataModelMix.pickupAddress = _senderAddressController.text;
//           ordersDataModelMix.pickupMap = mapUrlSender;
//           ordersDataModelMix.rc = receiverPayCheckedValue! ? "1" : "0";
//           // ordersDataModelMix.pickupTime = _currentTimeSelected!.id;
//           ordersDataModelMix.pickupTime =  savedPickupTime.toString();
//           ordersDataModelMix.receiverName = _receiverNameController.text;
//           ordersDataModelMix.receiverPhone = _receiverPhoneController.text;
//           ordersDataModelMix.deliverNeighborhood = _currentZoneReceiver!.id;
//           ordersDataModelMix.deliverAddress = _receiverAddressController.text;
//           ordersDataModelMix.deliverMap = mapUrlReceiver;
//           ordersDataModelMix.deliverTime = "0";
//           ordersDataModelMix.deductFromCod = deductFromCod ? "1" : "0";
//
//           cancelOrderBloc
//               .add(ClientEditOrder(ordersDataModelMix: ordersDataModelMix));
//         }
//       }
//
//       print('kkkk');
//     }
//   }
//
//   @override
//   void initState() {
//     try {
//       senderCities.addAll(widget.resourcesData!.city!
//           .where((element) =>
//               element.send == "1" && element.neighborhoods!.length > 0)
//           .toList());
//       receiverCities.addAll(widget.resourcesData!.city!
//           .where((element) =>
//               element.receive == "1" && element.neighborhoods!.length > 0)
//           .toList());
//
//       getOrderData();
//     } catch (e) {
//       cancelOrderBloc.add(ClientCancelOrderEventsGenerateError());
//     }
//
//     if (senderCities.isEmpty ||
//         receiverCities.isEmpty ||
//         widget.resourcesData!.packaging!.isEmpty ||
//         widget.resourcesData!.times!.isEmpty) {
//       cancelOrderBloc.add(ClientCancelOrderEventsGenerateError());
//     }
//
//     print('deduct check ${widget.ordersDataModel!.deductFromCod}');
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     senderNameFocus.dispose();
//     senderPhoneFocus.dispose();
//     senderCityFocus.dispose();
//     senderAddressFocus.dispose();
//     senderPickupTimeFocus.dispose();
//     receiverNameFocus.dispose();
//     receiverPhoneFocus.dispose();
//     receiverCityFocus.dispose();
//     receiverAddressFocus.dispose();
//     receiverBuildingFocus.dispose();
//     receiverFloorFocus.dispose();
//     receiverFlatFocus.dispose();
//     zoneFocus.dispose();
//     zoneFocusReceiver.dispose();
//     cancelOrderBloc.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     width = size.width;
//     height = size.height;
//     screenWidth = size.width;
//     screenHeight = size.height;
//     return BlocProvider(
//       create: (context) => ClientCancelOrderBloc(),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         key: _drawerKey,
//         drawer: ClientDrawerWidget(
//           resourcesData: widget.resourcesData,
//           width: screenWidth,
//           height: screenHeight,
//         ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: Container(
//                   color: Constants.clientBackgroundGrey,
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(
//                             right: screenWidth! * 0.03,
//                             left: screenWidth! * 0.03,
//                             top: screenHeight! * 0.01),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     SvgPicture.asset(
//                                       "assets/images/regular.svg",
//                                       height: 38.0,
//                                     ),
//                                     SizedBox(
//                                       width: 20,
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Text(
//                                               'Shipment id :'.tr(),
//                                               style: TextStyle(fontSize: 12),
//                                             ),
//                                             SizedBox(
//                                               width: 5,
//                                             ),
//                                             Text(
//                                               widget.ordersDataModel!.id!,
//                                               style: TextStyle(fontSize: 12),
//                                             )
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             ButtonTheme(
//                               minWidth: 0,
//                               height: 0,
//                               child: FlatButton(
//                                 padding: EdgeInsets.all(1),
//                                 minWidth: 0,
//                                 height: 0,
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.shrinkWrap,
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 child: Container(
//                                   width: 35,
//                                   height: 35,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.2),
//                                         spreadRadius: 1,
//                                         blurRadius: 2,
//                                         offset: Offset(
//                                             0, 3), // changes position of shadow
//                                       ),
//                                     ],
//                                   ),
//                                   child: Icon(
//                                     Icons.close,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: screenHeight! * 0.04,
//                       ),
//                       Expanded(
//                         child: BlocConsumer<ClientCancelOrderBloc,
//                             ClientCancelOrderStates>(
//                           bloc: cancelOrderBloc,
//                           builder: (context, state) {
//                             if (state is ClientCancelOrderInitial) {
//                               return _buildAddOrderScreen();
//                             } else if (state is ClientCancelOrderLoading) {
//                               return _buildAddOrderScreen();
//                             } else if (state is ClientCancelOrderFailure) {
//                               return _buildAddOrderScreen();
//                             }
//
//                             return Container();
//                           },
//                           listener: (context, state) {
//                             if (state is ClientCancelOrderSuccess) {
//                               Navigator.pushAndRemoveUntil(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (BuildContext context) =>
//                                         MyOrdersScreen(
//                                           dashboardDataModel:
//                                               widget.dashboardDataModelNew,
//                                           resourcesData: widget.resourcesData,
//                                         )),
//                                 (route) => false,
//                               );
//                             }
//                             if (state is ClientCancelOrderFailure) {
//                               Navigator.pop(context);
//
//                               if (state.error == 'TIMEOUT') {
//                                 GeneralHandler.handleNetworkError(context);
//                               } else if (state.error == 'needUpdate') {
//                                 GeneralHandler.handleNeedUpdateState(context);
//                               } else if (state.error == "invalidToken") {
//                                 GeneralHandler.handleInvalidToken(context);
//                               } else if (state.error == "general") {
//                                 GeneralHandler.handleGeneralError(context);
//                               } else {
//                                 _onWidgetDidBuild(context, () {
//                                   Scaffold.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Container(
//                                         width: screenWidth,
//                                         height: screenHeight! * 0.1,
//                                         child: ListView.builder(
//                                           itemCount: state.errors!.length,
//                                           itemBuilder: (context, i) {
//                                             return Text(state.errors![i]!);
//                                           },
//                                         ),
//                                       ),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 });
//                               }
//                             }
//                             if (state is ClientCancelOrderLoading) {
//                               ComFunctions.ProgressDialog(context);
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddOrderScreen() {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: screenWidth! * 0.03,
//       ),
//       child: SingleChildScrollView(
//         key: ValueKey('editOrderScroll'),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 textBaseline: TextBaseline.ideographic,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 10),
//                     child: Text(
//                       'Sender Data'.tr(),
//                       style: TextStyle(fontSize: 15),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Expanded(
//                     child: Center(
//                       child: Padding(
//                         padding: EdgeInsets.only(bottom: 5),
//                         child: Container(
//                           height: 1,
//                           color: Colors.black.withOpacity(0.2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Padding(
//                       padding: EdgeInsets.only(bottom: 10),
//                       child: Center(
//                         child: InkWell(
//                           onTap: () {
//                             setState(() {
//                               checkedValue2 = !checkedValue2!;
//                               if (checkedValue2!) {
//                                 clearData();
//                               } else {
//                                 restoreData();
//                               }
//                             });
//                           },
//                           child: Container(
//                             width: 180,
//                             height: 30,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(color: Color(0xFF4C8FF8))),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Theme(
//                                   data: Theme.of(context).copyWith(
//                                     unselectedWidgetColor: Color(0xFF4C8FF8),
//                                   ),
//                                   child: SizedBox(
//                                     height: 20.0,
//                                     width: 20.0,
//                                     child: Checkbox(
//                                       value: checkedValue2,
//                                       onChanged: (newValue) {
//                                         setState(() {
//                                           checkedValue2 = newValue;
//                                           if (checkedValue2!) {
//                                             clearData();
//                                           } else {
//                                             restoreData();
//                                           }
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 12,
//                                 ),
//                                 Text(
//                                   'Unregistered info'.tr(),
//                                   style: TextStyle(
//                                       fontSize: 12, color: Color(0xFF4C8FF8)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   widget.dashboardDataModelNew!.addresses!.length > 0 &&
//                           !checkedValue2!
//                       ? Padding(
//                           padding: EdgeInsets.only(bottom: 10),
//                           child: Container(
//                             height: screenHeight! * 0.06,
//                             width: screenWidth! * 0.94,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(
//                                     color: Colors.blueAccent.withOpacity(0.4)),
//                                 borderRadius: BorderRadius.circular(12)),
//                             child: Row(
//                               children: [
//                                 Padding(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 10),
//                                     child: Center(
//                                       child: Text(
//                                         'My Addresses'.tr(),
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black87),
//                                       ),
//                                     )),
//                                 Expanded(
//                                   child: DropdownButtonHideUnderline(
//                                     child: DropdownButton<Addresses>(
//                                       items: widget
//                                           .dashboardDataModelNew!.addresses!
//                                           .map((Addresses dropDownStringItem) {
//                                         return DropdownMenuItem<Addresses>(
//                                           value: dropDownStringItem,
//                                           child: AutoSizeText(
//                                             dropDownStringItem.title!.tr(),
//                                             style: TextStyle(
//                                                 color: Color(0xFF959595),
//                                                 fontSize: 13),
//                                           ),
//                                         );
//                                       }).toList(),
//                                       onChanged: (Addresses? newValue) {
//                                         setState(() {
//                                           _currentSelectedAddress = newValue;
//
//                                           checkedValue2 = false;
//                                           if (_currentSelectedAddress!.map ==
//                                               '') {
//                                             resetGoogleMaps();
//                                           } else {
//                                             setGoogleMaps(
//                                                 _currentSelectedAddress!.map);
//                                           }
//                                           _senderAddressController.text =
//                                               _currentSelectedAddress!
//                                                   .description!;
//
//                                           for (int i = 0;
//                                               i <
//                                                   widget.resourcesData!.city!
//                                                       .length;
//                                               i++) {
//                                             for (int x = 0;
//                                                 x <
//                                                     widget
//                                                         .resourcesData!
//                                                         .city![i]
//                                                         .neighborhoods!
//                                                         .length;
//                                                 x++) {
//                                               if (_currentSelectedAddress!
//                                                       .city ==
//                                                   widget.resourcesData!.city![i]
//                                                       .neighborhoods![x].id) {
//                                                 _currentCitySelected = widget
//                                                     .resourcesData!.city![i];
//                                                 _currentZone = widget
//                                                     .resourcesData!
//                                                     .city![i]
//                                                     .neighborhoods![x];
//                                               }
//                                             }
//                                           }
//                                         });
//                                       },
//                                       value: _currentSelectedAddress,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ))
//                       : Container(),
//                 ],
//               ),
//               Column(
//                 children: [
//                   SizedBox(
//                     width: 15,
//                   ),
//                   Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(bottom: 10),
//                         child: TextFormField(
//                           key: const ValueKey('editSenderName'),
//                           focusNode: senderNameFocus,
//                           onFieldSubmitted: (v) {
//                             FocusScope.of(context)
//                                 .requestFocus(senderPhoneFocus);
//                           },
//                           decoration: kTextFieldDecoration2.copyWith(
//                               hintText: 'Full name'.tr()),
//                           validator: (String? value) {
//                             if (value!.isEmpty) {
//                               return 'this field is required'.tr();
//                             } else {
//                               return null;
//                             }
//                           },
//                           controller: _senderNameController,
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(bottom: 10),
//                         child: TextFormField(
//                           focusNode: senderPhoneFocus,
//                           onFieldSubmitted: (v) {
//                             FocusScope.of(context)
//                                 .requestFocus(senderCityFocus);
//                           },
//                           inputFormatters: [
//                             LengthLimitingTextInputFormatter(9),
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           keyboardType: TextInputType.number,
//                           decoration: kTextFieldDecoration2.copyWith(
//                               hintText: 'Phone number'.tr()),
//                           controller: _senderPhoneController,
//                           validator: (String? value) {
//                             if (value!.isEmpty) {
//                               return 'this field is required'.tr();
//                             }
//                             if (!phoneValidation(value)) {
//                               return 'please enter a valid mobile number'.tr();
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       Container(
//                         height: screenHeight! * 0.06,
//                         width: screenWidth,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12)),
//                         child: Row(
//                           children: [
//                             Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 15),
//                                 child: Text(
//                                   'City'.tr(),
//                                   style: TextStyle(
//                                       fontSize: 14, color: Colors.black87),
//                                 )),
//                             Expanded(
//                               child: DropdownSearch<ErCity?>(
//                                 dropdownSearchDecoration: kTextFieldDecoration2
//                                     .copyWith(hintText: ""),
//                                 searchBoxDecoration:
//                                     kTextFieldDecoration.copyWith(
//                                         hintText: "City name ..".tr(),
//                                         suffixIcon: Icon(Icons.search)),
//                                 label: "",
//                                 items: senderCities,
//                                 searchBoxController: searchBoxCityController,
//                                 showSearchBox: true,
//                                 selectedItem: _currentCitySelected,
//                                 itemAsString: (ErCity? u) => u!.name ?? "",
//                                 emptyBuilder: (context, string) {
//                                   return Center(child: Text('No results'.tr()));
//                                 },
//                                 mode: Mode.BOTTOM_SHEET,
//                                 enabled: true,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _currentCitySelected = value;
//                                     _currentZone = _currentCitySelected!
//                                         .neighborhoods!.first;
//                                     searchBoxCityController.clear();
//                                   });
//                                 },
//                                 clearButton: Icon(Icons.close),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Container(
//                         height: screenHeight! * 0.06,
//                         width: screenWidth,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12)),
//                         child: Row(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 15),
//                               child: Text(
//                                 'Neighborhood'.tr(),
//                                 style: TextStyle(
//                                     fontSize: 14, color: Colors.black87),
//                               ),
//                             ),
//                             Expanded(
//                               child: DropdownSearch<Neighborhoods?>(
//                                 dropdownSearchDecoration: kTextFieldDecoration2
//                                     .copyWith(hintText: ""),
//                                 searchBoxDecoration:
//                                     kTextFieldDecoration.copyWith(
//                                         hintText: "Neighborhood name..".tr(),
//                                         suffixIcon: Icon(Icons.search)),
//                                 label: "",
//                                 items: _currentCitySelected!.neighborhoods,
//                                 searchBoxController: searchBoxZoneController,
//                                 showSearchBox: true,
//                                 selectedItem: _currentZone,
//                                 itemAsString: (Neighborhoods? u) =>
//                                     u!.name ?? "",
//                                 emptyBuilder: (context, string) {
//                                   return Center(child: Text('No results'.tr()));
//                                 },
//                                 mode: Mode.BOTTOM_SHEET,
//                                 enabled: true,
//                                 onChanged: (value) {
//                                   ;
//                                   setState(() {
//                                     _currentZone = value;
//                                     searchBoxZoneController.clear();
//                                   });
//                                 },
//                                 clearButton: Icon(Icons.close),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//
//                       locationSelected
//                           ? Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     _launchURL(mapUrlSender!);
//                                   },
//                                   child: Container(
//                                     width: screenWidth! * 0.7,
//                                     height: screenHeight! * 0.06,
//                                     decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         border: Border.all(
//                                             color: Color(0xFF56D340), width: 2),
//                                         borderRadius:
//                                             BorderRadius.circular(12)),
//                                     child: Row(
//                                       children: [
//                                         Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: SvgPicture.asset(
//                                             "assets/images/google-maps.svg",
//                                             placeholderBuilder: (context) =>
//                                                 CustomLoading(),
//                                             // height: 18.0,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           'Saved Location'.tr(),
//                                           style: TextStyle(
//                                             color: Color(0xFF56D340),
//                                             fontSize: 17,
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                     icon: Icon(
//                                       Icons.delete_forever_outlined,
//                                       color: Color(0xFFF4693F),
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         _senderAddressController.clear();
//                                         mapUrlSender = '';
//                                         locationSelected = false;
//                                       });
//                                     })
//                               ],
//                             )
//                           : GestureDetector(
//                               onTap: () {
//                                 FocusScope.of(context).unfocus();
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => PlacePicker(
//                                       apiKey: Constants
//                                           .googleMabiApiKey, // Put YOUR OWN KEY here.
//                                       onPlacePicked: (result) {
//                                         print(result.adrAddress);
//                                         print(result.name);
//                                         print(result.id);
//                                         Navigator.of(context).pop();
//                                       },
//                                       // initialPosition: LatLng(Constants.latitude, Constants.longitude),
//                                       initialPosition: LatLng(21.4858, 39.1925),
//                                       strictbounds: true,
//                                       onGeocodingSearchFailed: (e) {
//                                         print('FAILED FAILED $e');
//                                       },
//                                       enableMapTypeButton: false,
//                                       autocompleteRadius: 800000,
//                                       selectInitialPosition: true,
//                                       searchForInitialValue: false,
//                                       useCurrentLocation: true,
//                                       onAutoCompleteFailed: (e) {
//                                         print("Auto complete failed $e");
//                                       },
//                                       autocompleteLanguage: "ar",
//                                       selectedPlaceWidgetBuilder: (_,
//                                           selectedPlace,
//                                           state,
//                                           isSearchBarFocused) {
//                                         return isSearchBarFocused
//                                             ? Container()
//                                             : FloatingCard(
//                                                 bottomPosition:
//                                                     40.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
//                                                 leftPosition: 10.0,
//                                                 rightPosition: 10.0,
//                                                 width: 500,
//                                                 elevation: 5,
//                                                 borderRadius:
//                                                     BorderRadius.circular(12.0),
//                                                 child: Padding(
//                                                   padding: EdgeInsets.only(
//                                                       top: 10, bottom: 10),
//                                                   child: selectedPlace != null
//                                                       ? Column(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(2.0),
//                                                               child: Text(
//                                                                 selectedPlace
//                                                                     .formattedAddress!,
//                                                                 style: TextStyle(
//                                                                     fontSize:
//                                                                         18),
//                                                               ),
//                                                             ),
//                                                             SizedBox(
//                                                                 height: 10),
//                                                             TextButton(
//                                                               child: Text(
//                                                                   'Save'.tr()),
//                                                               onPressed: () {
//                                                                 setState(() {
//                                                                   _pickedLocation =
//                                                                       selectedPlace;
//                                                                   _senderAddressController
//                                                                           .text =
//                                                                       _pickedLocation!
//                                                                           .formattedAddress
//                                                                           .toString();
//
//                                                                   locationSelected =
//                                                                       true;
//
//                                                                   mapUrlSender =
//                                                                       'https://www.google.com/maps/search/?api=1&query=${_pickedLocation!.geometry!.location.lat},${_pickedLocation!.geometry!.location.lng}';
//                                                                 });
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop();
//                                                               },
//                                                             ),
//                                                           ],
//                                                         )
//                                                       : Center(
//                                                           child:
//                                                               CircularProgressIndicator()),
//                                                 ),
//                                               );
//                                       },
//                                       centerForSearching: Constants.sauidArabia,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 width: screenWidth,
//                                 height: screenHeight! * 0.06,
//                                 decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     border: Border.all(
//                                         color: Colors.grey, width: 2),
//                                     borderRadius: BorderRadius.circular(12)),
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                       padding:
//                                           EdgeInsets.symmetric(horizontal: 10),
//                                       child: SvgPicture.asset(
//                                         "assets/images/google-maps.svg",
//                                         placeholderBuilder: (context) =>
//                                             CircularProgressIndicator(),
//                                         // height: 18.0,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 5,
//                                     ),
//                                     Text(
//                                       'Position on Google Maps'.tr(),
//                                       style: TextStyle(
//                                         color: Colors.black87,
//                                         fontSize: 17,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
// //                       GestureDetector(
// //                         onTap: () async {
// //                           LocationResult result = await showLocationPicker(
// //                             context,
// //                             Constants.googleMabiApiKey,
// //                             automaticallyAnimateToCurrentLocation: true,
// // //                      mapStylePath: 'assets/mapStyle.json',
// //                             myLocationButtonEnabled: true,
// //                             // requiredGPS: true,
// //                             layersButtonEnabled: true,
// //                             hintText: EasyLocalization.of(context).locale == Locale("en") ? "search" : "البحث",
// //                             language:EasyLocalization.of(context).locale == Locale("en") ? "en" : 'ar',
// //                             countries: ['SA'],
// //
// // //                      resultCardAlignment: Alignment.bottomCenter,
// //                             desiredAccuracy: LocationAccuracy.best,
// //                           );
// //                           print("result = $result");
// //                           setState(() {
// //                             if(result != null){
// //                               _pickedLocation = result;
// //                               locationSelected = true ;
// //                               if(_senderAddressController.text.isEmpty){
// //                                 _senderAddressController.text = result.address ;
// //
// //                               }
// //
// //                               mapUrlSender = 'https://www.google.com/maps/@${_pickedLocation.latLng.latitude},${_pickedLocation.latLng.longitude},17z';
// //
// //                             }
// //
// //
// //                           });
// //                         },
// //                         child: Container(
// //                           width: screenWidth,
// //                           height: screenHeight * 0.06,
// //                           decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               border: Border.all(color: Color(0xFFf79b7f), width: 2),
// //                               borderRadius: BorderRadius.circular(12)),
// //                           child: Row(
// //                             children: [
// //                               Padding(
// //                                 padding: EdgeInsets.symmetric(horizontal: 10),
// //                                 child: SvgPicture.asset(
// //                                   "assets/images/google-maps.svg",
// //                                   placeholderBuilder: (context) =>
// //                                       CircularProgressIndicator(),
// //                                   // height: 18.0,
// //                                 ),
// //                               ),
// //                               SizedBox(
// //                                 width: 5,
// //                               ),
// //                               Text(
// //                                 'Position on Google Maps'.tr(),
// //                                 style: TextStyle(
// //                                   color: Color(0xFFF4693F),
// //                                   fontSize: 17,
// //                                 ),
// //                               ),
// //                               // SizedBox(
// //                               //   width: 2,
// //                               // ),
// //                               // Text(
// //                               //   '(required)'.tr(),
// //                               //   style: TextStyle(
// //                               //     color: Color(0xFFF4693F),
// //                               //     fontSize: 11,
// //                               //   ),
// //                               // ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       // Padding(
//                       //   padding: EdgeInsets.only(bottom: 10),
//                       //   child: TextFormField(
//                       //     focusNode: senderAddressFocus,
//                       //     onFieldSubmitted:(v) {
//                       //       FocusScope.of(context).requestFocus(senderPickupTimeFocus);
//                       //     },
//                       //     decoration:
//                       //     kTextFieldDecoration2.copyWith(hintText: 'Address'.tr()),
//                       //     controller: _senderAddressController,
//                       //     // validator: (String value) {
//                       //     //   if (value.isEmpty) {
//                       //     //     return 'this field is required';
//                       //     //   }
//                       //     //   return null;
//                       //     // },
//                       //   ),
//                       // ),
//                       _senderAddressController.text.isNotEmpty
//                           ? Padding(
//                               padding: EdgeInsets.only(bottom: 10),
//                               child: Container(
//                                   width: screenWidth,
//                                   height: screenHeight! * 0.06,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12)),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(4.0),
//                                     child: AutoSizeText(
//                                       "${_senderAddressController.text}",
//                                       maxLines: 3,
//                                     ),
//                                   )),
//                             )
//                           : Container(),
//                     ],
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Text(
//                     'Pickup Time'.tr(),
//                     style: TextStyle(
//                         fontSize: 14, color: Colors.black87),
//                   ),
//                 ],
//               ),
//               Padding(
//                   padding: EdgeInsets.only(bottom: 10),
//                   child: Container(
//                     height: screenHeight! * 0.06,
//                     width: screenWidth,
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(
//                           color: Colors.grey.withOpacity(0.2),
//                         ),
//                         borderRadius: BorderRadius.circular(12)),
//                     child: Row(
//                       children: [
//
//                         Expanded(
//                           child: DateTimePicker(
//                             type: DateTimePickerType.dateTimeSeparate,
//                             dateMask: 'dd MMM, yyyy',
//                             initialValue: savedPickupTime.toString(),
//                             firstDate: DateTime(2000),
//                             lastDate: DateTime(2100),
//                             icon: Icon(Icons.event),
//                             dateLabelText: '',
//                             timeLabelText: "",
//                             selectableDayPredicate: (date) {
//                               // Disable weekend days to select from the calendar
//                               // if (date.weekday == 6 || date.weekday == 7) {
//                               //   return false;
//                               // }
//
//                               return true;
//                             },
//                             onChanged: (val){
//                               savedPickupTime = val ;
//                             },
//                             onSaved: (val){
//                               savedPickupTime = val.toString() ;
//
//                             },
//                           ),
//                         ),
//
//                       ],
//                     ),
//                   )),
//
//               SizedBox(
//                 height: 5,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 textBaseline: TextBaseline.ideographic,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 10),
//                     child: Text(
//                       'Receiver Data'.tr(),
//                       style: TextStyle(fontSize: 15),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Expanded(
//                     child: Center(
//                       child: Padding(
//                         padding: EdgeInsets.only(bottom: 5),
//                         child: Container(
//                           height: 1,
//                           color: Colors.black.withOpacity(0.2),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: EdgeInsets.only(bottom: 10),
//                 child: TextFormField(
//                   key: const ValueKey('editReciName'),
//                   focusNode: receiverNameFocus,
//                   onFieldSubmitted: (v) {
//                     FocusScope.of(context).requestFocus(receiverPhoneFocus);
//                   },
//                   decoration: kTextFieldDecoration2.copyWith(
//                       hintText: 'Full name'.tr()),
//                   controller: _receiverNameController,
//                   validator: (String? value) {
//                     if (value!.isEmpty) {
//                       return 'this field is required'.tr();
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(bottom: 10),
//                 child: TextFormField(
//                   focusNode: receiverPhoneFocus,
//                   onFieldSubmitted: (v) {
//                     FocusScope.of(context).requestFocus(receiverCityFocus);
//                   },
//                   inputFormatters: [
//                     LengthLimitingTextInputFormatter(9),
//                     FilteringTextInputFormatter.digitsOnly
//                   ],
//                   keyboardType: TextInputType.number,
//                   decoration: kTextFieldDecoration2.copyWith(
//                       hintText: 'Phone number'.tr()),
//                   controller: _receiverPhoneController,
//                   validator: (String? value) {
//                     if (value!.isEmpty) {
//                       return 'this field is required'.tr();
//                     }
//                     if (!phoneValidation(value)) {
//                       return 'please enter a valid mobile number'.tr();
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               Container(
//                 height: screenHeight! * 0.06,
//                 width: screenWidth,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Row(
//                   children: [
//                     Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 15),
//                         child: Text(
//                           'City'.tr(),
//                           style: TextStyle(fontSize: 14, color: Colors.black87),
//                         )),
//                     Expanded(
//                       child: DropdownSearch<ErCity?>(
//                         dropdownSearchDecoration:
//                             kTextFieldDecoration2.copyWith(hintText: ""),
//                         searchBoxDecoration: kTextFieldDecoration.copyWith(
//                             hintText: "City name ..".tr(),
//                             suffixIcon: Icon(Icons.search)),
//                         label: "",
//                         items: receiverCities,
//                         searchBoxController: searchBoxCityRController,
//                         showSearchBox: true,
//                         selectedItem: _currentReceiverCitySelected,
//                         itemAsString: (ErCity? u) => u!.name ?? "",
//                         emptyBuilder: (context, string) {
//                           return Center(child: Text('No results'.tr()));
//                         },
//                         mode: Mode.BOTTOM_SHEET,
//                         enabled: true,
//                         onChanged: (value) {
//                           setState(() {
//                             _currentReceiverCitySelected = value;
//                             _currentZoneReceiver = _currentReceiverCitySelected!
//                                 .neighborhoods!.first;
//                             searchBoxCityRController.clear();
//                           });
//                         },
//                         clearButton: Icon(Icons.close),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Container(
//                 height: screenHeight! * 0.06,
//                 width: screenWidth,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 15),
//                       child: Text(
//                         'Neighborhood'.tr(),
//                         style: TextStyle(fontSize: 14, color: Colors.black87),
//                       ),
//                     ),
//                     Expanded(
//                       child: DropdownSearch<Neighborhoods?>(
//                         dropdownSearchDecoration:
//                             kTextFieldDecoration2.copyWith(hintText: ""),
//                         searchBoxDecoration: kTextFieldDecoration.copyWith(
//                             hintText: "Neighborhood name..".tr(),
//                             suffixIcon: Icon(Icons.search)),
//                         label: "",
//                         items: _currentReceiverCitySelected!.neighborhoods,
//                         searchBoxController: searchBoxZoneRController,
//                         showSearchBox: true,
//                         selectedItem: _currentZoneReceiver,
//                         itemAsString: (Neighborhoods? u) => u!.name ?? "",
//                         emptyBuilder: (context, string) {
//                           return Center(child: Text('No results'.tr()));
//                         },
//                         mode: Mode.BOTTOM_SHEET,
//                         enabled: true,
//                         onChanged: (value) {
//                           setState(() {
//                             _currentZoneReceiver = value;
//                             searchBoxZoneRController.clear();
//                           });
//                         },
//                         clearButton: Icon(Icons.close),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               locationSelectedReceiver
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             _launchURL(mapUrlReceiver!);
//                           },
//                           child: Container(
//                             width: screenWidth! * 0.7,
//                             height: screenHeight! * 0.06,
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(
//                                     color: Color(0xFF56D340), width: 2),
//                                 borderRadius: BorderRadius.circular(12)),
//                             child: Row(
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsets.symmetric(horizontal: 10),
//                                   child: SvgPicture.asset(
//                                     "assets/images/google-maps.svg",
//                                     placeholderBuilder: (context) =>
//                                         CircularProgressIndicator(),
//                                     // height: 18.0,
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 Text(
//                                   'Saved Location'.tr(),
//                                   style: TextStyle(
//                                     color: Color(0xFF56D340),
//                                     fontSize: 17,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                             icon: Icon(
//                               Icons.delete_forever_outlined,
//                               color: Color(0xFFF4693F),
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 mapUrlReceiver = '';
//                                 _receiverAddressController.clear();
//                                 locationSelectedReceiver = false;
//                               });
//                             })
//                       ],
//                     )
//                   : GestureDetector(
//                       onTap: () {
//                         FocusScope.of(context).unfocus();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PlacePicker(
//                               apiKey: Constants
//                                   .googleMabiApiKey, // Put YOUR OWN KEY here.
//                               onPlacePicked: (result) {
//                                 print(result.adrAddress);
//                                 print(result.name);
//                                 print(result.id);
//                                 Navigator.of(context).pop();
//                               },
//                               // initialPosition: LatLng(Constants.latitude, Constants.longitude),
//                               initialPosition: LatLng(21.4858, 39.1925),
//                               strictbounds: true,
//                               onGeocodingSearchFailed: (e) {
//                                 print('FAILED FAILED $e');
//                               },
//                               enableMapTypeButton: false,
//                               autocompleteRadius: 800000,
//                               selectInitialPosition: true,
//                               searchForInitialValue: false,
//                               useCurrentLocation: true,
//                               onAutoCompleteFailed: (e) {
//                                 print("Auto complete failed $e");
//                               },
//                               autocompleteLanguage: "ar",
//                               selectedPlaceWidgetBuilder: (_, selectedPlace,
//                                   state, isSearchBarFocused) {
//                                 return isSearchBarFocused
//                                     ? Container()
//                                     : FloatingCard(
//                                         bottomPosition:
//                                             40.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
//                                         leftPosition: 10.0,
//                                         rightPosition: 10.0,
//                                         width: 500,
//                                         elevation: 5,
//                                         borderRadius:
//                                             BorderRadius.circular(12.0),
//                                         child: Padding(
//                                           padding: EdgeInsets.only(
//                                               top: 10, bottom: 10),
//                                           child: selectedPlace != null
//                                               ? Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               2.0),
//                                                       child: Text(
//                                                         selectedPlace
//                                                             .formattedAddress!,
//                                                         style: TextStyle(
//                                                             fontSize: 18),
//                                                       ),
//                                                     ),
//                                                     SizedBox(height: 10),
//                                                     TextButton(
//                                                       child: Text('Save'.tr()),
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           _deliverPickedLocation =
//                                                               selectedPlace;
//                                                           _receiverAddressController
//                                                                   .text =
//                                                               _deliverPickedLocation!
//                                                                   .formattedAddress
//                                                                   .toString();
//
//                                                           locationSelectedReceiver =
//                                                               true;
//
//                                                           mapUrlReceiver =
//                                                               'https://www.google.com/maps/search/?api=1&query=${_deliverPickedLocation!.geometry!.location.lat},${_deliverPickedLocation!.geometry!.location.lng}';
//                                                         });
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//                                                     ),
//                                                   ],
//                                                 )
//                                               : Center(
//                                                   child:
//                                                       CircularProgressIndicator()),
//                                         ),
//                                       );
//                               },
//                               centerForSearching: Constants.sauidArabia,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: screenWidth,
//                         height: screenHeight! * 0.06,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(color: Colors.grey, width: 2),
//                             borderRadius: BorderRadius.circular(12)),
//                         child: Row(
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 10),
//                               child: SvgPicture.asset(
//                                 "assets/images/google-maps.svg",
//                                 placeholderBuilder: (context) =>
//                                     CircularProgressIndicator(),
//                                 // height: 18.0,
//                               ),
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             Text(
//                               'Position on Google Maps'.tr(),
//                               style: TextStyle(
//                                 color: Colors.black87,
//                                 fontSize: 17,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
// //               GestureDetector(
// //                 onTap: () async {
// //                   LocationResult result = await showLocationPicker(
// //                     context,
// //                     Constants.googleMabiApiKey,
// //                     automaticallyAnimateToCurrentLocation: true,
// // //                      mapStylePath: 'assets/mapStyle.json',
// //                     myLocationButtonEnabled: true,
// //                     // requiredGPS: true,
// //                     hintText: EasyLocalization.of(context).locale == Locale("en") ? "search" : "البحث",
// //                     language:EasyLocalization.of(context).locale == Locale("en") ? "en" : 'ar',
// //                     layersButtonEnabled: true,
// //                     countries: ['SA'],
// //
// // //                      resultCardAlignment: Alignment.bottomCenter,
// //                     desiredAccuracy: LocationAccuracy.best,
// //                   );
// //                   print("result = $result");
// //                   setState(() {
// //                     if(result != null){
// //                       _delivePickedLocation = result;
// //                       if(_receiverAddressController.text.isEmpty) {
// //                         _receiverAddressController.text = result.address ;
// //
// //                       }
// //                       locationSelectedReceiver = true ;
// //
// //                       mapUrlReceiver = 'https://www.google.com/maps/@${_delivePickedLocation.latLng.latitude},${_delivePickedLocation.latLng.longitude},17z';
// //                     }
// //
// //
// //                   });
// //                 },
// //                 child: Container(
// //                   width: screenWidth,
// //                   height: screenHeight * 0.06,
// //                   decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       border: Border.all(color: Color(0xFFf79b7f), width: 2),
// //                       borderRadius: BorderRadius.circular(12)),
// //                   child: Row(
// //                     children: [
// //                       Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 10),
// //                         child: SvgPicture.asset(
// //                           "assets/images/google-maps.svg",
// //                           placeholderBuilder: (context) =>
// //                               CircularProgressIndicator(),
// //                           // height: 18.0,
// //                         ),
// //                       ),
// //                       SizedBox(
// //                         width: 5,
// //                       ),
// //
// //                       Text(
// //                         'Position on Google Maps'.tr(),
// //                         style: TextStyle(
// //                           color: Color(0xFFF4693F),
// //                           fontSize: 17,
// //                         ),
// //                       )
// //                     ],
// //                   ),
// //                 ),
// //               ),
//               SizedBox(
//                 height: 15,
//               ),
//               _receiverAddressController.text.isNotEmpty
//                   ? Padding(
//                       padding: EdgeInsets.only(bottom: 10),
//                       child: Container(
//                           width: screenWidth,
//                           height: screenHeight! * 0.06,
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: AutoSizeText(
//                               "${_receiverAddressController.text}",
//                               maxLines: 3,
//                             ),
//                           )),
//                     )
//                   : Container(),
//               // Padding(
//               //   padding: EdgeInsets.only(bottom: 10),
//               //   child: TextFormField(
//               //     focusNode: receiverAddressFocus,
//               //     onFieldSubmitted:(v) {
//               //       FocusScope.of(context).requestFocus(receiverBuildingFocus);
//               //     },
//               //     decoration:
//               //     kTextFieldDecoration2.copyWith(hintText: 'Address'.tr()),
//               //     controller: _receiverAddressController,
//               //     // validator: (String value) {
//               //     //   if (value.isEmpty) {
//               //     //     return 'this field is required';
//               //     //   }
//               //     //   return null;
//               //     // },
//               //   ),
//               // ),
//               SizedBox(
//                 height: 10,
//               ),
//               // Padding(
//               //     padding: EdgeInsets.only(bottom: 10),
//               //     child: Container(
//               //       height: screenHeight * 0.06,
//               //       width: screenWidth,
//               //       decoration: BoxDecoration(
//               //           color: Colors.white,
//               //           borderRadius: BorderRadius.circular(12)),
//               //       child: Row(
//               //         children: [
//               //           Padding(
//               //               padding: EdgeInsets.all(13),
//               //               child: Text(
//               //                 'Deliver Time'.tr(),
//               //                 style:
//               //                     TextStyle(fontSize: 14, color: Colors.black87),
//               //               )),
//               //           DropdownButton<Cancellation>(
//               //             items: widget.resourcesData.times
//               //                 .map((Cancellation dropDownStringItem) {
//               //               return DropdownMenuItem<Cancellation>(
//               //                 value: dropDownStringItem,
//               //                 child: Text(
//               //                   dropDownStringItem.name.tr(),
//               //                   style: TextStyle(
//               //                       color: Color(0xFF959595), fontSize: 15),
//               //                 ),
//               //               );
//               //             }).toList(),
//               //             onChanged: (Cancellation newValue) {
//               //               setState(() {
//               //                 _currentReceiverTimeSelected = newValue;
//               //                 print(_currentReceiverTimeSelected.id);
//               //               });
//               //             },
//               //             value: _currentReceiverTimeSelected,
//               //           ),
//               //         ],
//               //       ),
//               //     )),
//               Padding(
//                 padding: EdgeInsets.only(bottom: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   textBaseline: TextBaseline.ideographic,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(bottom: 10),
//                       child: Text(
//                         'Packages'.tr(),
//                         style: TextStyle(fontSize: 15),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: EdgeInsets.only(bottom: 5),
//                         child: Container(
//                           height: 1,
//                           color: Colors.black.withOpacity(0.2),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                   padding: EdgeInsets.only(bottom: 10),
//                   child: Center(
//                     child: Container(
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           // border: Border.all(color: receiverPayCheckedValue ?  Color(0xFF4C8FF8):Colors.grey)
//                           border: Border.all(color: Colors.grey)),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 3, vertical: 5),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   receiverPayCheckedValue =
//                                       !receiverPayCheckedValue!;
//                                   deductFromCod = false;
//                                 });
//                               },
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Theme(
//                                     data: Theme.of(context).copyWith(
//                                       unselectedWidgetColor: Colors.black54,
//                                     ),
//                                     child: SizedBox(
//                                         height: screenWidth! * 0.04,
//                                         width: screenWidth! * 0.04,
//                                         child: CustomCheckBox(
//                                           checkedColor: Color(0xFF4C8FF8),
//                                           unCheckedColor: Colors.grey,
//                                           backgroundColor: Colors.white,
//                                           checked: receiverPayCheckedValue,
//                                         )),
//                                   ),
//                                   SizedBox(
//                                     width: screenWidth! * 0.01,
//                                   ),
//                                   Container(
//                                     width: screenWidth! * 0.3,
//                                     child: AutoSizeText(
//                                       'Shipping on receiver'.tr(),
//                                       style: TextStyle(
//                                           fontSize: 11,
//                                           color: receiverPayCheckedValue!
//                                               ? Color(0xFF4C8FF8)
//                                               : Colors.black87),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: screenWidth! * 0.02,
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   deductFromCod = !deductFromCod;
//                                   receiverPayCheckedValue = false;
//                                 });
//                               },
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Theme(
//                                     data: Theme.of(context).copyWith(
//                                       unselectedWidgetColor: Colors.black54,
//                                     ),
//                                     child: SizedBox(
//                                         height: screenWidth! * 0.04,
//                                         width: screenWidth! * 0.04,
//                                         child: CustomCheckBox(
//                                           checkedColor: Color(0xFF4C8FF8),
//                                           unCheckedColor: Colors.grey,
//                                           backgroundColor: Colors.white,
//                                           checked: deductFromCod,
//                                         )),
//                                   ),
//                                   SizedBox(
//                                     width: screenWidth! * 0.01,
//                                   ),
//                                   Container(
//                                     width: screenWidth! * 0.45,
//                                     child: AutoSizeText(
//                                       'deductFromCod'.tr(),
//                                       style: TextStyle(
//                                           fontSize: 11,
//                                           color: deductFromCod
//                                               ? Color(0xFF4C8FF8)
//                                               : Colors.black87),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )),
//
//               _buildAreas(index: 0),
//
//               // Padding(
//               //   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
//               //
//               //   child: Container(
//               //     width: screenWidth*0.4,
//               //     child: Row(
//               //       children: [
//               //         AutoSizeText('Total Price'.tr(),
//               //           style: TextStyle(
//               //               fontSize:19,
//               //               color: Colors.black,
//               //               fontWeight: FontWeight.bold
//               //           ),
//               //         ),
//               //         Container(
//               //           width: screenWidth*0.3,
//               //           child: AutoSizeText('$totalPrice SR',
//               //             style: TextStyle(
//               //                 fontSize:19,
//               //                 color: Colors.black,
//               //                 fontWeight: FontWeight.bold
//               //             ),
//               //           ),
//               //         ),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//               Padding(
//                   padding: EdgeInsets.only(top: 5, bottom: 15),
//                   child: ButtonTheme(
//                       key: const ValueKey('editShipmentBtn'),
//                       minWidth: 300,
//                       height: 50,
//                       child: FlatButton(
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                               side: BorderSide(color: Colors.grey)),
//                           color: Colors.blue,
//                           textColor: Colors.white,
//                           child: Text(
//                             'Edit Order'.tr(),
//                             style: TextStyle(
//                               fontSize: 17,
//                             ),
//                           ),
//                           onPressed: () {
//                             _onLoginButtonPressed();
//                           }))),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAreas({int? index}) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 5),
//       child: Container(
//           width: width,
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Color.fromRGBO(197, 197, 197, 0.1),
//                 //Colors.black26,
//                 blurRadius: 3.0, // soften the shadow
//                 spreadRadius: 3, //extend the shadow
//               )
//             ],
//             color: Colors.white,
//             border: Border.all(
//               color: Colors.grey.withOpacity(0.5), //deepOrange,
//               width: 1,
//               //borderRadius: BorderRadius.circular(radius),
//             ),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   widget.ordersDataModel!.packaging == '1'
//                       ? Padding(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 5, vertical: 4),
//                           child: SvgPicture.asset(
//                             "assets/images/regular.svg",
//                             height: screenHeight! * 0.045,
//                           ),
//                         )
//                       : widget.ordersDataModel!.packaging == '2'
//                           ? Padding(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 5, vertical: 4),
//                               child: SvgPicture.asset(
//                                 "assets/images/save.svg",
//                                 height: screenHeight! * 0.045,
//                               ),
//                             )
//                           : widget.ordersDataModel!.packaging == '3'
//                               ? Padding(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 5, vertical: 4),
//                                   child: SvgPicture.asset(
//                                     "assets/images/liquid.svg",
//                                     height: screenHeight! * 0.045,
//                                   ),
//                                 )
//                               : widget.ordersDataModel!.packaging == '4'
//                                   ? Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 5, vertical: 4),
//                                       child: SvgPicture.asset(
//                                         "assets/images/cold.svg",
//                                         height: screenHeight! * 0.045,
//                                       ),
//                                     )
//                                   : widget.ordersDataModel!.packaging == '6'
//                                       ? Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 20, vertical: 4),
//                                           child: Image.asset(
//                                             'assets/images/coldCartoon.png',
//                                             height: screenHeight! * 0.05,
//                                             // fit: BoxFit.fitWidth,
//                                           ),
//                                         )
//                                       : Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 5, vertical: 4),
//                                           child: SvgPicture.asset(
//                                             "assets/images/liquid.svg",
//                                             height: screenHeight! * 0.045,
//                                           ),
//                                         ),
//                   Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Type :'.tr(),
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             Text(packaging!),
//                           ],
//                         ),
//                         widget.ordersDataModel!.fragile == "1"
//                             ? Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Fragile'.tr(),
//                                     style: TextStyle(color: Colors.black),
//                                   ),
//                                 ],
//                               )
//                             : Container(),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text(
//                               'No. of pieces :'.tr(),
//                               style: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: screenWidth! * 0.03),
//                             ),
//                             SizedBox(
//                               width: 5,
//                             ),
//                             Text(
//                               widget.ordersDataModel!.quantity.toString(),
//                               style: TextStyle(fontSize: screenWidth! * 0.03),
//                             ),
//                           ],
//                         ),
//                         widget.ordersDataModel!.cod != "0" &&
//                                 widget.ordersDataModel!.cod != ""
//                             ? Row(
//                                 children: [
//                                   Text('cash on delivery'.tr()),
//                                   SizedBox(
//                                     width: 4,
//                                   ),
//                                   Text(widget.ordersDataModel!.cod ?? ''),
//                                   SizedBox(
//                                     width: 4,
//                                   ),
//                                   Text(
//                                     'SR'.tr(),
//                                     style: TextStyle(fontSize: 9),
//                                   ),
//                                 ],
//                               )
//                             : Container(),
//                         widget.ordersDataModel!.comment != '' &&
//                                 widget.ordersDataModel!.comment != null
//                             ? Container(
//                                 width: screenWidth! * 0.5,
//                                 child: AutoSizeText(
//                                   '${widget.ordersDataModel!.comment}',
//                                   maxLines: 2,
//                                 ))
//                             : Container()
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               // checkedBoxLocal ? Text('-') : Container(),
//               SizedBox(
//                 width: 10,
//               ),
//
//               InkWell(
//                   onTap: () {
//                     double price = CalcPackagePrice(
//                         resourcesData: widget.resourcesData,
//                         senderCity: _currentCitySelected!.id,
//                         deliverCity: _currentCitySelected!.id,
//                         packagingId: _currentSelectedPackaging!.id);
//
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return StatefulBuilder(
//                             builder: (context, setState2) {
//                               return Align(
//                                 alignment: Alignment.topCenter,
//                                 child: AlertDialog(
//                                   contentPadding: EdgeInsets.all(0.0),
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius.circular(20.0)),
//                                   content: SingleChildScrollView(
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                             width: width,
//                                             decoration: BoxDecoration(
//                                                 color: Color(0xffF9F9F9),
//                                                 borderRadius: BorderRadius.only(
//                                                     topLeft:
//                                                         Radius.circular(20),
//                                                     topRight:
//                                                         Radius.circular(20))),
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 15,
//                                                       vertical: 15),
//                                               child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Text(
//                                                       'Edit Package'.tr(),
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.w700),
//                                                     ),
//                                                     GestureDetector(
//                                                         onTap: () {
//                                                           Navigator.pop(
//                                                               context);
//                                                         },
//                                                         child: Icon(
//                                                           Icons.close,
//                                                           size: 15,
//                                                         ))
//                                                   ]),
//                                             )),
//                                         SizedBox(
//                                           height: 20,
//                                         ),
//                                         Padding(
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 10, vertical: 6),
//                                             child: Center(
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   setState2(() {
//                                                     checkedValue =
//                                                         !checkedValue;
//                                                   });
//                                                 },
//                                                 child: Container(
//                                                   width: screenWidth,
//                                                   height: 45,
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               8),
//                                                       border: Border.all(
//                                                           color: checkedValue
//                                                               ? Color(
//                                                                   0xFF4C8FF8)
//                                                               : Colors.grey)),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Padding(
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                                 horizontal: 10),
//                                                         child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             Theme(
//                                                               data: Theme.of(
//                                                                       context)
//                                                                   .copyWith(
//                                                                 unselectedWidgetColor:
//                                                                     Color(
//                                                                         0xFF4C8FF8),
//                                                               ),
//                                                               child: SizedBox(
//                                                                   height: 20.0,
//                                                                   width: 20.0,
//                                                                   child:
//                                                                       CustomCheckBox(
//                                                                     checkedColor:
//                                                                         Color(
//                                                                             0xFF4C8FF8),
//                                                                     unCheckedColor:
//                                                                         Colors
//                                                                             .grey,
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .white,
//                                                                     checked:
//                                                                         checkedValue,
//                                                                   )),
//                                                             ),
//                                                             SizedBox(
//                                                               width: 12,
//                                                             ),
//                                                             Text(
//                                                               'fragile'.tr(),
//                                                               style: TextStyle(
//                                                                   fontSize:
//                                                                       screenWidth! *
//                                                                           0.03,
//                                                                   color: checkedValue
//                                                                       ? Color(
//                                                                           0xFF4C8FF8)
//                                                                       : Colors
//                                                                           .grey),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                       Padding(
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                                 horizontal: 10),
//                                                         child: SvgPicture.asset(
//                                                           "assets/images/fragile.svg",
//                                                           width: 25,
//                                                           height: 25,
//                                                           color: checkedValue
//                                                               ? null
//                                                               : Colors.grey,
//                                                           placeholderBuilder:
//                                                               (context) =>
//                                                                   CircularProgressIndicator(),
//
//                                                           // height: 18.0,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             )),
//                                         Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 10, vertical: 6),
//                                           child: Container(
//                                             width: screenWidth,
//                                             height: 45,
//                                             decoration: BoxDecoration(
//                                                 color: Colors.white,
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                                 border: Border.all(
//                                                     color: Color(0xFF4C8FF8))),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Padding(
//                                                   padding: const EdgeInsets
//                                                           .symmetric(
//                                                       horizontal: 10),
//                                                   child: Text(
//                                                     'Packaging'.tr(),
//                                                     style:
//                                                         TextStyle(fontSize: 12),
//                                                   ),
//                                                 ),
//                                                 Expanded(
//                                                   child:
//                                                       DropdownButtonHideUnderline(
//                                                     child: DropdownButton<
//                                                         Packaging>(
//                                                       onTap: () {
//                                                         FocusScope.of(context)
//                                                             .unfocus();
//                                                       },
//                                                       items: widget
//                                                           .resourcesData!
//                                                           .packaging!
//                                                           .map((Packaging
//                                                               dropDownStringItem) {
//                                                         return DropdownMenuItem<
//                                                             Packaging>(
//                                                           key: const ValueKey(
//                                                               'packaging'),
//                                                           value:
//                                                               dropDownStringItem,
//                                                           child: Text(
//                                                             dropDownStringItem
//                                                                 .name!,
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black87,
//                                                                 fontSize: 14),
//                                                           ),
//                                                         );
//                                                       }).toList(),
//                                                       onChanged: (Packaging?
//                                                           newValue) {
//                                                         setState2(() {
//                                                           _currentSelectedPackaging =
//                                                               newValue;
//
//                                                           price = CalcPackagePrice(
//                                                               resourcesData: widget
//                                                                   .resourcesData,
//                                                               senderCity:
//                                                                   _currentCitySelected!
//                                                                       .id,
//                                                               deliverCity:
//                                                                   _currentCitySelected!
//                                                                       .id,
//                                                               packagingId:
//                                                                   _currentSelectedPackaging!
//                                                                       .id);
//                                                         });
//                                                       },
//                                                       value:
//                                                           _currentSelectedPackaging,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 10, vertical: 6),
//                                           child: TextFormField(
//                                             keyboardType:
//                                                 TextInputType.numberWithOptions(
//                                                     decimal: false),
//                                             decoration:
//                                                 kTextFieldDecoration.copyWith(
//                                               prefixIcon: Icon(
//                                                 MdiIcons.counter,
//                                                 color: Color(0xFF414141),
//                                                 size: 20,
//                                               ),
//                                               hintText: 'no. of pieces'.tr(),
//                                               hintStyle: TextStyle(
//                                                   fontSize:
//                                                       screenWidth! * 0.03),
//                                             ),
//                                             controller: _quantityController,
//                                           ),
//                                         ),
//                                         Padding(
//                                             padding: EdgeInsets.symmetric(
//                                                 horizontal: 10, vertical: 6),
//                                             child: Column(
//                                               children: [
//                                                 Center(
//                                                   child: InkWell(
//                                                     onTap: () {
//                                                       setState2(() {
//                                                         codCheckedValue =
//                                                             !codCheckedValue!;
//                                                       });
//                                                     },
//                                                     child: Container(
//                                                       width: screenWidth,
//                                                       height: 45,
//                                                       decoration: BoxDecoration(
//                                                           color: Colors.white,
//                                                           borderRadius: codCheckedValue!
//                                                               ? BorderRadius.only(
//                                                                   topRight: Radius
//                                                                       .circular(
//                                                                           8),
//                                                                   topLeft: Radius
//                                                                       .circular(
//                                                                           8))
//                                                               : BorderRadius
//                                                                   .circular(8),
//                                                           border: Border.all(
//                                                               color: codCheckedValue!
//                                                                   ? Color(
//                                                                       0xFF4C8FF8)
//                                                                   : Colors
//                                                                       .grey)),
//                                                       child: Column(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               Padding(
//                                                                 padding: EdgeInsets
//                                                                     .symmetric(
//                                                                         horizontal:
//                                                                             10),
//                                                                 child: Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .center,
//                                                                   children: [
//                                                                     Theme(
//                                                                       data: Theme.of(
//                                                                               context)
//                                                                           .copyWith(
//                                                                         unselectedWidgetColor:
//                                                                             Color(0xFF4C8FF8),
//                                                                       ),
//                                                                       child: SizedBox(
//                                                                           height: 20.0,
//                                                                           width: 20.0,
//                                                                           child: CustomCheckBox(
//                                                                             checkedColor:
//                                                                                 Color(0xFF4C8FF8),
//                                                                             unCheckedColor:
//                                                                                 Colors.grey,
//                                                                             backgroundColor:
//                                                                                 Colors.white,
//                                                                             checked:
//                                                                                 codCheckedValue,
//                                                                           )),
//                                                                     ),
//                                                                     SizedBox(
//                                                                       width: 12,
//                                                                     ),
//                                                                     Text(
//                                                                       'Cash on delivery'
//                                                                           .tr(),
//                                                                       style: TextStyle(
//                                                                           fontSize:
//                                                                               12,
//                                                                           color: codCheckedValue!
//                                                                               ? Color(0xFF4C8FF8)
//                                                                               : Colors.grey),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                               Padding(
//                                                                 padding: EdgeInsets
//                                                                     .symmetric(
//                                                                         horizontal:
//                                                                             10),
//                                                                 child:
//                                                                     SvgPicture
//                                                                         .asset(
//                                                                   "assets/images/cash-payment.svg",
//                                                                   width: 25,
//                                                                   height: 25,
//                                                                   color: codCheckedValue!
//                                                                       ? null
//                                                                       : Colors
//                                                                           .grey,
//                                                                   placeholderBuilder:
//                                                                       (context) =>
//                                                                           CircularProgressIndicator(),
//
//                                                                   // height: 18.0,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 codCheckedValue! &&
//                                                         _currentReceiverCitySelected!
//                                                                 .cod ==
//                                                             "1"
//                                                     ? TextFormField(
//                                                         key: const ValueKey(
//                                                             'codValue'),
//                                                         inputFormatters: [
//                                                           FilteringTextInputFormatter
//                                                               .digitsOnly
//                                                         ],
//                                                         keyboardType: TextInputType
//                                                             .numberWithOptions(
//                                                                 decimal: true),
//                                                         decoration:
//                                                             kTextFieldDecoration
//                                                                 .copyWith(
//                                                           border:
//                                                               OutlineInputBorder(
//                                                             borderRadius: BorderRadius.only(
//                                                                 bottomLeft: Radius
//                                                                     .circular(
//                                                                         8.0),
//                                                                 bottomRight: Radius
//                                                                     .circular(
//                                                                         8.0)),
//                                                           ),
//                                                           enabledBorder:
//                                                               OutlineInputBorder(
//                                                             borderSide:
//                                                                 BorderSide(
//                                                                     color: Colors
//                                                                         .grey,
//                                                                     width:
//                                                                         1.15),
//                                                             borderRadius: BorderRadius.only(
//                                                                 bottomLeft: Radius
//                                                                     .circular(
//                                                                         8.0),
//                                                                 bottomRight: Radius
//                                                                     .circular(
//                                                                         8.0)),
//                                                           ),
//                                                           focusedBorder:
//                                                               OutlineInputBorder(
//                                                             borderSide:
//                                                                 BorderSide(
//                                                                     color: Colors
//                                                                         .blue,
//                                                                     width:
//                                                                         1.15),
//                                                             borderRadius: BorderRadius.only(
//                                                                 bottomLeft: Radius
//                                                                     .circular(
//                                                                         8.0),
//                                                                 bottomRight: Radius
//                                                                     .circular(
//                                                                         8.0)),
//                                                           ),
//                                                           prefixIcon: Icon(
//                                                             MdiIcons.cash,
//                                                             color: Color(
//                                                                 0xFF414141),
//                                                             size: 20,
//                                                           ),
//                                                           hintText:
//                                                               'value'.tr(),
//                                                           hintStyle: TextStyle(
//                                                               fontSize:
//                                                                   screenWidth! *
//                                                                       0.03),
//                                                         ),
//                                                         onFieldSubmitted:
//                                                             (value) {
//                                                           try {
//                                                             setState2(() {
//                                                               codDoubleValue =
//                                                                   double.parse(
//                                                                       value);
//                                                             });
//                                                           } catch (e) {}
//                                                         },
//                                                         onChanged: (value) {
//                                                           try {
//                                                             setState2(() {
//                                                               codDoubleValue =
//                                                                   double.parse(
//                                                                       value);
//                                                             });
//                                                           } catch (e) {}
//                                                         },
//                                                         controller:
//                                                             _codController,
//                                                       )
//                                                     : Container(),
//                                               ],
//                                             )),
//                                         Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 10, vertical: 6),
//                                           child: TextFormField(
//                                             decoration:
//                                                 kTextFieldDecoration.copyWith(
//                                               prefixIcon: Icon(
//                                                 MdiIcons.comment,
//                                                 color: Color(0xFF414141),
//                                                 size: 20,
//                                               ),
//                                               hintText: 'parcel details'.tr(),
//                                               hintStyle: TextStyle(
//                                                   fontSize:
//                                                       screenWidth! * 0.03),
//                                             ),
//                                             controller:
//                                                 _packageCommentController,
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 10, vertical: 6),
//                                           child: Container(
//                                             height: 70,
//                                             width: screenWidth,
//                                             decoration: BoxDecoration(
//                                               color: Color(0xffF9F9F9),
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Text(
//                                                   'Estimated price'.tr(),
//                                                   style: TextStyle(fontSize: 7),
//                                                 ),
//                                                 Row(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.center,
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       '$price',
//                                                       style: TextStyle(
//                                                           fontSize: 19,
//                                                           color:
//                                                               Color(0xFF6F94E7),
//                                                           fontWeight:
//                                                               FontWeight.w900),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 4,
//                                                     ),
//                                                     Text('SR'.tr(),
//                                                         style: TextStyle(
//                                                             fontSize: 9)),
//                                                   ],
//                                                 ),
//                                                 Text(
//                                                   "(Taxes Included)".tr(),
//                                                   style: TextStyle(fontSize: 7),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         ButtonTheme(
//                                           minWidth: screenWidth!,
//                                           height: 50,
//                                           child: FlatButton(
//                                               padding: EdgeInsets.all(0),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.only(
//                                                     bottomRight:
//                                                         Radius.circular(20),
//                                                     bottomLeft:
//                                                         Radius.circular(20)),
//                                               ),
//                                               color: Colors.blue,
//                                               textColor: Colors.white,
//                                               child: Text(
//                                                 'Edit Package'.tr(),
//                                                 style: TextStyle(
//                                                     fontSize:
//                                                         screenWidth! * 0.04),
//                                               ),
//                                               onPressed: () {
//                                                 setState(() {
//                                                   setState(() {
//                                                     checkedBoxLocal
//                                                         ? widget
//                                                             .ordersDataModel!
//                                                             .fragile = "1"
//                                                         : widget
//                                                             .ordersDataModel!
//                                                             .fragile = "0";
//                                                     checkedValue
//                                                         ? widget
//                                                             .ordersDataModel!
//                                                             .fragile = "1"
//                                                         : widget
//                                                             .ordersDataModel!
//                                                             .fragile = "0";
//                                                     widget.ordersDataModel!
//                                                             .cod =
//                                                         _codController.text;
//                                                     widget.ordersDataModel!
//                                                             .quantity =
//                                                         _quantityController
//                                                                 .text.isNotEmpty
//                                                             ? _quantityController
//                                                                 .text
//                                                             : "1";
//                                                     widget.ordersDataModel!
//                                                             .comment =
//                                                         _packageCommentController
//                                                             .text;
//                                                     for (int i = 0;
//                                                         i <
//                                                             widget
//                                                                 .resourcesData!
//                                                                 .packaging!
//                                                                 .length;
//                                                         i++) {
//                                                       if (_currentSelectedPackaging!
//                                                               .id ==
//                                                           widget
//                                                               .resourcesData!
//                                                               .packaging![i]
//                                                               .id) {
//                                                         _currentSelectedPackaging =
//                                                             widget
//                                                                 .resourcesData!
//                                                                 .packaging![i];
//                                                         widget.ordersDataModel!
//                                                                 .packaging =
//                                                             _currentSelectedPackaging!
//                                                                 .id;
//                                                         packaging = widget
//                                                             .resourcesData!
//                                                             .packaging![i]
//                                                             .name;
//                                                       }
//                                                     }
//                                                     if (!codCheckedValue!) {
//                                                       _codController.clear();
//                                                       widget.ordersDataModel!
//                                                           .cod = '0';
//                                                     }
//                                                   });
//                                                   // _packageCommentController.clear();
//
//                                                   Navigator.pop(context);
//                                                 });
//                                               }),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                           return StatefulBuilder(
//                             builder: (context, setState2) {
//                               return AlertDialog(
//                                 title: Text('Edit Package'.tr()),
//                                 content: SingleChildScrollView(
//                                   child: Column(
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.all(width! * 0.02),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: CheckboxListTile(
//                                                 title: Text("fragile".tr()),
//                                                 value: checkedValue,
//                                                 onChanged: (newValue) {
//                                                   setState2(() {
//                                                     checkedValue =
//                                                         !checkedValue;
//                                                   });
//                                                 },
//                                                 controlAffinity:
//                                                     ListTileControlAffinity
//                                                         .leading, //  <-- leading Checkbox
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(width! * 0.02),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: CheckboxListTile(
//                                                 title: Text(
//                                                     "Cash on delivery".tr()),
//                                                 value: codCheckedValue,
//                                                 onChanged: (newValue) {
//                                                   setState2(() {
//                                                     codCheckedValue = newValue;
//                                                     _codController.clear();
//                                                   });
//                                                 },
//                                                 controlAffinity:
//                                                     ListTileControlAffinity
//                                                         .leading, //  <-- leading Checkbox
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                       codCheckedValue!
//                                           ? Padding(
//                                               padding:
//                                                   EdgeInsets.all(width! * 0.02),
//                                               child: Container(
//                                                 width: width! * 0.7,
//                                                 child: TextFormField(
//                                                   inputFormatters: [
//                                                     FilteringTextInputFormatter
//                                                         .digitsOnly
//                                                   ],
//                                                   keyboardType:
//                                                       TextInputType.number,
//                                                   decoration:
//                                                       kTextFieldDecoration
//                                                           .copyWith(
//                                                               prefixIcon: Icon(
//                                                                 MdiIcons.cash,
//                                                                 color: Color(
//                                                                     0xFF414141),
//                                                                 size: 20,
//                                                               ),
//                                                               hintText:
//                                                                   'value'.tr()),
//                                                   controller: _codController,
//                                                 ),
//                                               ),
//                                             )
//                                           : Container(),
//                                       Padding(
//                                         padding: EdgeInsets.all(width! * 0.02),
//                                         child: Row(
//                                           children: [
//                                             Text('Packaging'.tr()),
//                                             SizedBox(
//                                               width: 20,
//                                             ),
//                                             DropdownButton<Packaging>(
//                                               items: widget
//                                                   .resourcesData!.packaging!
//                                                   .map((Packaging
//                                                       dropDownStringItem) {
//                                                 return DropdownMenuItem<
//                                                     Packaging>(
//                                                   value: dropDownStringItem,
//                                                   child: Text(
//                                                     dropDownStringItem.name!
//                                                         .tr(),
//                                                     style: TextStyle(
//                                                         color:
//                                                             Color(0xFF959595),
//                                                         fontSize: 15),
//                                                   ),
//                                                 );
//                                               }).toList(),
//                                               onChanged: (Packaging? newValue) {
//                                                 setState2(() {
//                                                   _currentSelectedPackaging =
//                                                       newValue;
//                                                   print(
//                                                       _currentSelectedPackaging!
//                                                           .id);
//                                                 });
//                                               },
//                                               value: _currentSelectedPackaging,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(width! * 0.02),
//                                         child: Container(
//                                           width: width! * 0.7,
//                                           child: TextFormField(
//                                             decoration:
//                                                 kTextFieldDecoration.copyWith(
//                                                     prefixIcon: Icon(
//                                                       MdiIcons.comment,
//                                                       color: Color(0xFF414141),
//                                                       size: 20,
//                                                     ),
//                                                     hintText: 'comment'.tr()),
//                                             controller:
//                                                 _packageCommentController,
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.all(width! * 0.02),
//                                         child: ButtonTheme(
//                                           minWidth: 300,
//                                           height: 50,
//                                           child: FlatButton(
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           12.0),
//                                                   side: BorderSide(
//                                                       color: Colors.grey)),
//                                               color: Colors.blue,
//                                               textColor: Colors.white,
//                                               child: Text(
//                                                 'Add Package'.tr(),
//                                                 style: TextStyle(
//                                                   fontSize: 17,
//                                                 ),
//                                               ),
//                                               onPressed: () {
//                                                 setState(() {
//                                                   checkedBoxLocal
//                                                       ? widget.ordersDataModel!
//                                                           .fragile = "1"
//                                                       : widget.ordersDataModel!
//                                                           .fragile = "0";
//                                                   checkedValue
//                                                       ? widget.ordersDataModel!
//                                                           .fragile = "1"
//                                                       : widget.ordersDataModel!
//                                                           .fragile = "0";
//                                                   widget.ordersDataModel!.cod =
//                                                       _codController.text;
//                                                   widget.ordersDataModel!
//                                                           .comment =
//                                                       _packageCommentController
//                                                           .text;
//                                                   for (int i = 0;
//                                                       i <
//                                                           widget
//                                                               .resourcesData!
//                                                               .packaging!
//                                                               .length;
//                                                       i++) {
//                                                     if (_currentSelectedPackaging!
//                                                             .id ==
//                                                         widget.resourcesData!
//                                                             .packaging![i].id) {
//                                                       _currentSelectedPackaging =
//                                                           widget.resourcesData!
//                                                               .packaging![i];
//                                                       widget.ordersDataModel!
//                                                               .packaging =
//                                                           _currentSelectedPackaging!
//                                                               .id;
//                                                       packaging = widget
//                                                           .resourcesData!
//                                                           .packaging![i]
//                                                           .name;
//                                                     }
//                                                   }
//                                                   if (!codCheckedValue!) {
//                                                     _codController.clear();
//                                                   }
//                                                 });
//
//                                                 Navigator.pop(context);
//                                               }),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         });
//                   },
//                   child: Padding(
//                       padding: EdgeInsets.only(
//                           top: width! * 0.01,
//                           right: width! * 0.02,
//                           bottom: width! * 0.01,
//                           left: width! * 0.02),
//                       child: Container(
//                           child: Center(
//                               child: Icon(
//                         Icons.edit,
//                         size: width! * 0.05,
//                       )))))
//             ],
//           )),
//     );
//   }
//
//   void _onWidgetDidBuild(BuildContext context, Function callback) {
//     WidgetsBinding.instance!.addPostFrameCallback((_) {
//       callback();
//     });
//   }
// }
