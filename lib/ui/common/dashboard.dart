import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/controllers/resources_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/ResponseViewModel.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/main.dart';
import 'package:Fulgox/controllers/checkin_controller.dart';
import 'package:Fulgox/controllers/profile_controller.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/ui/Client/HomeScreenNew.dart';
import 'package:Fulgox/ui/Client/MyOrders.dart';
import 'package:Fulgox/ui/Client/enter_nationalId.dart';
import 'package:Fulgox/ui/courier/captainDashboard.dart';
import 'package:Fulgox/ui/courier/captaincheckINScreen.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/courier/driverDashboard.dart';
import 'package:Fulgox/ui/courier/odo_meter.dart';
import 'package:Fulgox/ui/courier/trips_management.dart';
import 'package:Fulgox/ui/custom%20widgets/ErrorView.dart';
import 'package:Fulgox/ui/custom%20widgets/Names&OrdersCard.dart';
import 'package:Fulgox/ui/custom%20widgets/NetworkErrorView.dart';

import 'package:Fulgox/ui/custom%20widgets/drawerClient.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/ui/custom%20widgets/my_container.dart';
import 'package:Fulgox/ui/custom%20widgets/notificationView.dart';
import 'package:Fulgox/ui/custom%20widgets/notification_widget.dart';
import 'package:Fulgox/ui/Client/editProfile.dart';
import 'package:Fulgox/ui/courier/newCaptainDashboard.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/utilities/location.dart';
import 'package:Fulgox/utilities/push_nofitications.dart';

import '../courier/captainOrdersList.dart';
import '../custom widgets/OrdersCard.dart';
import '../custom widgets/captainOrdersCard.dart';
import '../custom widgets/custom_loading.dart';

class ResourcesScreen extends StatefulWidget {
  final ResourcesData? resourcesData;
  ResourcesScreen({this.resourcesData});

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<ResourcesScreen> {
  double? screenWidth, screenHeight;

  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      RemoteNotification? notification = message?.notification;
      AndroidNotification? android = message?.notification?.android;
      if (notification != null) {
        showDialog(
            context: context,
            builder: (context) {
              return NotificationWidget(
                  message?.notification?.title ?? "",
                  message?.notification?.body ?? "",
                  notification.android?.imageUrl,
                  notification.apple?.imageUrl);
            });
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      try {
        showDialog(
            context: context,
            builder: (context) {
              return NotificationWidget(
                  message.notification?.title ?? "",
                  message.notification?.body ?? "",
                  message.notification?.android?.imageUrl,
                  message.notification?.apple?.imageUrl);
            });
      } catch (e) {}
    });
    PushNotificationManager.setupNotificationSettings();
    super.initState();
  }

  final ResourcesController _resourcesController = Get.put(ResourcesController());
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    // Trigger fetch if not already loaded
    if (_resourcesController.resourcesData.value == null && !_resourcesController.isLoading.value) {
      _resourcesController.fetchResources();
    }

    return Scaffold(
      body: Obx(() {
        if (_resourcesController.isLoading.value) {
          return Scaffold(
            backgroundColor: Constants.blueColor,
            body: Container(
              child: Column(
                children: [
                  Hero(
                      tag: "headerImage",
                      child: Image.asset(
                        "assets/images/WELCOME SCREEN TOP.png",
                        fit: BoxFit.cover,
                        height: screenHeight! * 0.5,
                        width: screenWidth,
                      )),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (_resourcesController.errorMessage.value.isNotEmpty) {
          // Handle error similar to Bloc listener/builder
          String error = _resourcesController.errorMessage.value;
          if (error == "TIMEOUT") {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetworkErrorView();
                  });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
                _resourcesController.errorMessage.value = '';
              });
            });
          }

          return Scaffold(
            backgroundColor: Constants.clientBackgroundGrey,
            body: Column(
              children: [
                Container(
                  child: Center(
                    child: ErrorView(
                      errorMessage: '',
                      retryAction: () {
                        _resourcesController.fetchResources();
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Container(
                    child: Center(
                      child: Text('Logout'.tr()),
                    ),
                  ),
                  onPressed: () {
                    _authController.logout();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ChooseLanguageScreen(),
                        ),
                        (route) => false,
                      );
                    });
                  },
                ),
              ],
            ),
          );
        }

        if (_resourcesController.resourcesData.value != null) {
          return DashboardScreen(
            resourcesData: _resourcesController.resourcesData.value,
          );
        }

        return Container();
      }),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  DashboardScreen({this.resourcesData});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserRepository userRepository = UserRepository();
  // DashboardBloc dashboardBloc = DashboardBloc();
  final CheckInController _checkInController = Get.put(CheckInController());
  GlobalKey<RefreshIndicatorState>? refreshKeyHome;

  String? name;

  getProfile() async {
    name = await userRepository.getAuthName();
  }

  final AuthController _authController = Get.put(AuthController());
  final ProfileController _profileController = Get.put(ProfileController());
  double? screenWidth, screenHeight;

  @override
  void initState() {
    refreshKeyHome = GlobalKey<RefreshIndicatorState>();
    getProfile();
    super.initState();
  }

  Future<Null> onRefreshAll() async {
    _profileController.fetchProfileData();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    getProfile();
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    return Scaffold(
      body: Obx(() {
        if (_profileController.isLoading.value) {
          return Scaffold(
            backgroundColor: Constants.blueColor,
            body: Container(
              child: Column(
                children: [
                  Hero(
                      tag: "headerImage",
                      child: Image.asset(
                        "assets/images/WELCOME SCREEN TOP.png",
                        fit: BoxFit.cover,
                        height: screenHeight! * 0.5,
                        width: screenWidth,
                      )),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (_profileController.errorMessage.value.isNotEmpty) {
          String error = _profileController.errorMessage.value;
          if (error == "TIMEOUT") {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetworkErrorView();
                  });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
                _profileController.errorMessage.value = '';
              });
            });
          }

          return Scaffold(
            backgroundColor: Constants.clientBackgroundGrey,
            body: Center(
              child: Column(
                children: [
                  const ClientAppBar(),
                  SizedBox(
                    height: 150,
                  ),
                  IconButton(
                    icon: Icon(MdiIcons.refresh),
                    onPressed: () {
                      _profileController.fetchProfileData();
                    },
                  ),
                  Container(
                    child: Center(
                      child: Text('Try Again').tr(),
                    ),
                  ),
                  ElevatedButton(
                    child: Container(
                      child: Center(
                        child: Text('Logout'.tr()),
                      ),
                    ),
                    onPressed: () {
                      _authController.logout();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ChooseLanguageScreen(),
                          ),
                          (route) => false,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (_profileController.showNoNationalId.value) {
          return EnterNationalIdScreen(
            resourcesData: widget.resourcesData,
          );
        }

        if (_profileController.profileData.value != null) {
          var data = _profileController.profileData.value!;
          // Logic for different screens based on roles/permission
          if (data.permission == '1' || data.permission == '11') {
            return NewHomeScreen(
              dashboardDataModel: data,
              resourcesData: widget.resourcesData,
            );
          }
          // Add other role logic here as per original Bloc
        }

        // Trigger fetch if not loaded
        if (_profileController.profileData.value == null && !_profileController.isLoading.value) {
          _profileController.fetchProfileData();
        }

        return Container();
      }),
    );
  }
}

