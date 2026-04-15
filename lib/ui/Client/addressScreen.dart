import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/address_controller.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/custom%20widgets/ErrorView.dart';
import 'package:Fulgox/ui/custom%20widgets/home_button.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';
import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';
import 'editAddressScreen.dart';

import '../custom widgets/drawerClient.dart';
import '../custom widgets/myAppBar.dart';
import '../common/dashboard.dart';

enum addressActions { edit, cancel }

class AddressScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  AddressScreen({this.resourcesData});
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Future<bool> CheckInternet() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      return false;
    } else {
      return true;
    }
  }

  double? screenWidth, screenHeight, width, height;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  addressActions? _selection;
  // List<Addresses> addressList2 = [];

  var _formKey = GlobalKey<FormState>();

  ProfileDataModel? dashboardDataModel;
  bool? connected;

  final AddressController _addressController = Get.put(AddressController());
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _addressController.getAddress();
  }

  Future<bool> _onBackPressed() async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardScreen(
                  resourcesData: widget.resourcesData,
                )));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Constants.clientBackgroundGrey,
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  const ClientAppBar(),
                  Expanded(
                    child: Container(
                      color: Constants.clientBackgroundGrey,
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: screenWidth! * 0.03,
                            left: screenWidth! * 0.03,
                            top: screenHeight! * 0.01),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Obx(() {
                                if (_addressController.errorMessage.value != '') {
                                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                                    String error = _addressController.errorMessage.value;
                                    _addressController.errorMessage.value = '';
                                    if (error == "TIMEOUT") {
                                       GeneralHandler.handleNetworkError(context);
                                    } else if (error == "invalidToken") {
                                      GeneralHandler.handleInvalidToken(context);
                                    } else if (error == 'needUpdate') {
                                      GeneralHandler.handleNeedUpdateState(context);
                                    } else if (error == "general") {
                                      GeneralHandler.handleGeneralError(context);
                                    }
                                  });
                                }

                                return CreateAddressScreen(
                                  loading: _addressController.isLoading.value,
                                  list: _addressController.addressList,
                                  error: _addressController.errorMessage.value != ''
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(child: HomeButton()),
          ],
        ),
      ),
    );
  }

  Widget CreateAddressScreen(
      {required bool loading,
      List<Addresses>? list,
      required bool error}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset("assets/images/placeholder.svg",
                    placeholderBuilder: (context) => CustomLoading(),
                    height: 38.0,
                    color: Constants.blueColor),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My addresses'.tr(),
                      style: TextStyle(
                          fontSize: 17,
                          height: 0.8,
                          fontWeight: FontWeight.w500,
                          color: Constants.blueColor),
                    ),
                    Row(
                      children: [
                        Text(
                          list?.length.toString() ?? "",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Constants.redColor),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Total'.tr(),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Constants.redColor),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 25,
                    color: Colors.white,
                  ),
                  Text('Add New'.tr(), style: TextStyle(color: Colors.white)),
                ],
              ),
              onPressed: () {
                if (list != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditAddressScreen(
                                resourcesData: widget.resourcesData,
                                addressList: list,
                                // addresses: addressList2.elementAt(index),
                              )));
                }
              },
            )
          ],
        ),
        !loading
            ? Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _addressController.getAddress();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: list?.length,
                      itemBuilder: (context, i) {
                        return _buildAreas(
                            addressElement: list?[i],
                            myList: list);
                      },
                    ),
                  ),
                ),
              )
            : Expanded(
                child: Center(
                  child: CustomLoading(),
                ),
              ),
        error
            ? Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ErrorView(
                  errorMessage: '',
                  retryAction: () {
                    _addressController.getAddress();
                  },
                ),
              )
            : Container()
      ],
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }

  Widget _buildAreas(
      {Addresses? addressElement,
      List<Addresses>? myList}) {
    String? cityName;
    String? realCityName;

    for (int i = 0; i < (widget.resourcesData?.city?.length ?? 0); i++) {
      for (int x = 0;
          x < (widget.resourcesData?.city?[i].neighborhoods?.length ?? 0);
          x++) {
        if (addressElement?.city ==
            widget.resourcesData?.city?[i].neighborhoods?[x].id) {
          realCityName = widget.resourcesData?.city?[i].name;
          cityName = widget.resourcesData?.city?[i].neighborhoods?[x].name;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth! * 0.01),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        textBaseline: TextBaseline.alphabetic,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              addressElement?.title == "Work" ||
                                      addressElement?.title == "العمل"
                                  ? Icon(
                                      Icons.work,
                                      size: 40,
                                    )
                                  : addressElement?.title == "Home" ||
                                          addressElement?.title == "المنزل"
                                      ? Icon(Icons.home, size: 40)
                                      : Icon(MdiIcons.officeBuilding, size: 40),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  (addressElement?.title ?? "").tr(),
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: width! * 0.04,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Cairo"),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    realCityName ?? '',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: width! * 0.04,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Cairo"),
                                  ),
                                  Text(', '),
                                  Text(
                                    cityName ?? '',
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: width! * 0.04,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Cairo"),
                                  ),
                                ],
                              ),
                              Container(
                                width: screenWidth! * 0.55,
                                child: AutoSizeText(
                                  addressElement?.description ?? "",
                                  maxLines: 4,
                                  style: TextStyle(
                                    color: Constants.blueColor,
                                    fontSize: width! * 0.03,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Cairo",
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     SizedBox(width: 50,),
                  //     Container(
                  //       width: screenWidth!*0.6,
                  //       child: AutoSizeText(
                  //         addressElement?.description ?? "",
                  //         maxLines: 4,
                  //         style: TextStyle(
                  //             color: Constants.blueColor,
                  //             fontSize: width! * 0.03,
                  //             fontWeight: FontWeight.bold,
                  //             fontFamily: "Cairo",
                  //           overflow: TextOverflow.fade,),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            PopupMenuButton<addressActions>(
              onSelected: (addressActions result) {
                setState(() {
                  _selection = result;
                });
                // Navigator.pop(context);
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<addressActions>>[
                PopupMenuItem<addressActions>(
                  value: addressActions.edit,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                               builder: (context) => EditAddressScreen(
                                     resourcesData: widget.resourcesData,
                                     addressList: myList,
                                     addresses: addressElement,
                                   )));
                    },
                    child: Text('Edit'.tr()),
                  ),
                ),
                PopupMenuItem<addressActions>(
                  value: addressActions.edit,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                        myList!.remove(addressElement);
                        _addressController.deleteAddress(myList);
                      });
                    },
                    child: Text('Delete'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
