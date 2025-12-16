import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/LoginBloc.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/captainOrders_bloc.dart';
import 'package:xturbox/blocs/bloc/checkIn_bloc.dart';
import 'package:xturbox/blocs/bloc/dashboard_bloc.dart';
import 'package:xturbox/blocs/bloc/reserveClient_bloc.dart';
import 'package:xturbox/blocs/bloc/resources_bloc.dart';
import 'package:xturbox/blocs/events/LoginEvents.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/captainOrders_events.dart';
import 'package:xturbox/blocs/events/checkIn_events.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/blocs/events/reserveClient_events.dart';
import 'package:xturbox/blocs/events/resources_events.dart';
import 'package:xturbox/blocs/states/captainOrders_states.dart';
import 'package:xturbox/blocs/states/checkIn_states.dart';
import 'package:xturbox/blocs/states/dashboard_states.dart';
import 'package:xturbox/blocs/states/reserveClient_states.dart';
import 'package:xturbox/blocs/states/resources_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/ResponseViewModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/main.dart';
import 'package:xturbox/ui/Client/HomeScreenNew.dart';
import 'package:xturbox/ui/Client/MyOrders.dart';
import 'package:xturbox/ui/Client/enter_nationalId.dart';
import 'package:xturbox/ui/courier/captainDashboard.dart';
import 'package:xturbox/ui/courier/captaincheckINScreen.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/courier/driverDashboard.dart';
import 'package:xturbox/ui/courier/odo_meter.dart';
import 'package:xturbox/ui/courier/trips_management.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/Names&OrdersCard.dart';
import 'package:xturbox/ui/custom%20widgets/NetworkErrorView.dart';

import 'package:xturbox/ui/custom%20widgets/drawerClient.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/my_container.dart';
import 'package:xturbox/ui/custom%20widgets/notificationView.dart';
import 'package:xturbox/ui/custom%20widgets/notification_widget.dart';
import 'package:xturbox/ui/Client/editProfile.dart';
import 'package:xturbox/ui/courier/newCaptainDashboard.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/location.dart';
import 'package:xturbox/utilities/push_nofitications.dart';

import '../courier/captainOrdersList.dart';
import '../custom widgets/OrdersCard.dart';
import '../custom widgets/captainOrdersCard.dart';
import '../custom widgets/custom_loading.dart';

class ResourcesScreen extends StatefulWidget {

  LoginBloc? loginBloc ;
  ResourcesData? resourcesData ;
  ResourcesScreen({this.resourcesData , this.loginBloc});

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}


class _DashBoardScreenState extends State<ResourcesScreen> {

  double? screenWidth , screenHeight ;


  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      RemoteNotification? notification = message?.notification;
      AndroidNotification? android = message?.notification?.android;
      if (notification != null) {
        showDialog(
            context: context,
            builder: (context){
              return NotificationWidget(message?.notification?.title ?? "" , message?.notification?.body ?? "" ,
              notification.android?.imageUrl  , notification.apple?.imageUrl
              );
            }
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      try{
        showDialog(
            context: context,
            builder: (context){
              return NotificationWidget(message.notification?.title ?? "" , message.notification?.body ?? "",
                  message.notification?.android?.imageUrl , message.notification?.apple?.imageUrl
              );
            }
        );
      }
      catch(e){}
    });
    PushNotificationManager.setupNotificationSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ResourcesBloc>(create:(context)=> ResourcesBloc()..add(GetResourcesData())),
      ],

      child: BlocConsumer<ResourcesBloc,ResourcesStates>(
        builder: (context , state){
          if (state is ResourcesLoaded){
            return DashboardScreen(
              resourcesData:  state.resourcesData,
            );
          }

          if (state is ResourcesError){

            return  Scaffold(
              backgroundColor: Constants.clientBackgroundGrey,
              body: Column(
                children: [
                  Container(
                    child: Center(
                      child: ErrorView(
                        errorMessage: '',
                        retryAction: (){
                          BlocProvider.of<ResourcesBloc>(context).add(GetResourcesData());
                        },
                      ),
                    ),
                  ),
                  MaterialButton(
                    child: Container(
                      child: Center(
                        child: Text('Logout'.tr()),
                      ),
                    ),
                    onPressed: (){
                      authenticationBloc.add(LoggedOut());
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ChooseLanguageScreen(),
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

          return  Scaffold(
            backgroundColor: Constants.blueColor,
            body: Container(
              child: Column(
                children: [
                  Hero(
                      tag: "headerImage",
                      child: Image.asset("assets/images/WELCOME SCREEN TOP.png",fit: BoxFit.cover, height: screenHeight!*0.5,width: screenWidth, )) ,
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white,),
                    ),
                  ),
                ],
              ),
            ),
          );

        },

        listener: (context , state){
          if(state is ResourcesError){
            if(state.error == "TIMEOUT"){
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetworkErrorView();
                  });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });

            }
           else if(state.error == "invalidToken"){
              GeneralHandler.handleInvalidToken(context);
           }

            else if (state.error == 'needUpdate'){
              GeneralHandler.handleNeedUpdateState(context);
            }
          }
        },

      ),
    );
  }
}



class DashboardScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  DashboardScreen({ this.resourcesData});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserRepository userRepository = UserRepository();
  // DashboardBloc dashboardBloc = DashboardBloc();
  CheckInBloc checkInBloc = CheckInBloc();
  GlobalKey<RefreshIndicatorState>? refreshKeyHome;

  String? name ;


  getProfile() async {
    name = await userRepository.getAuthName();
  }
  
  AuthenticationBloc authenticationBloc = AuthenticationBloc();
  ProfileBloc dashboardBloc = ProfileBloc();
  double? screenWidth , screenHeight ;

  @override
  void initState() {
    refreshKeyHome = GlobalKey<RefreshIndicatorState>();
    getProfile();
    super.initState();
  }
  Future<Null> onRefreshAll()async{
    dashboardBloc.add(GetProfileData());
    return null ;
  }

  @override
  Widget build(BuildContext context) {
    getProfile();
    Size size = MediaQuery.of(context).size;
     screenWidth = size.width;
     screenHeight = size.height;

    return BlocProvider(
      create: (context)=>ProfileBloc()..add(GetProfileData()),
      child: BlocConsumer<ProfileBloc , ProfileStates>(
        builder:(context , state){
          if(state is DashboardInitial || state is DashboardLoading ){
            return Scaffold(
              backgroundColor: Constants.blueColor,
              body: Container(
                child: Column(
                  children: [
                    Hero(
                        tag: "headerImage",
                        child: Image.asset("assets/images/WELCOME SCREEN TOP.png",fit: BoxFit.cover, height: screenHeight!*0.5,width: screenWidth, )) ,
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white,),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          else if (state is DashboardUserLoaded){
            //the user is client
            return NewHomeScreen(
              dashboardDataModel: state.dashboardDataModel,
              resourcesData: widget.resourcesData,
            );
          }

          else if(state is NoNationalId){
                return EnterNationalIdScreen(
                  resourcesData: widget.resourcesData,
                );
          }
          else if (state is DashboardCaptainLoaded){
            return CheckInScreen(
              dashboardDataModel: state.dashboardDataModel,
              resourcesData: widget.resourcesData,
            );
          }
          else if (state is DashboardCaptainIn){
            //the user is captain
            return NewCaptainDashboard(
              resourcesData: widget.resourcesData,
            );
          }
          else if(state is NoVehicleAssigned){
            return Scaffold(
              backgroundColor: Constants.blueColor,
              body: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('You are not assigned to any vehicle contact your supervisor and try again'.tr()),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.blueColor, // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          BlocProvider.of<ProfileBloc>(context).add(GetProfileData());

                        },
                        child: Text('Refresh'.tr()),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.redColor, // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () async{
                          try {
                            await PushNotificationManager
                                .firebaseMessaging
                                .setAutoInitEnabled(false);
                            await PushNotificationManager
                                .firebaseMessaging
                                .deleteToken();
                          } catch (e) {
                            print(e);
                          }
                          print("logout");
                          authenticationBloc.add(LoggedOut());
                          Future.delayed(
                              const Duration(milliseconds: 1), () {
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
                        child: Text('Log Out'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            );

          }
          else if(state is DriverUserDashboard){
            return DriverDashboard(resourcesData: widget.resourcesData,);
          }
          else if(state is NoLocationPermission){
            return Scaffold(
              backgroundColor: Constants.blueColor,
              body: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Make sure the location is opened and the permission has granted for the Xtrubo'.tr()),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.blueColor, // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          BlocProvider.of<ProfileBloc>(context).add(GetProfileData());

                        },
                        child: Text('Refresh'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            );

          }

          else if (state is DashboardError){
            return Scaffold(
              backgroundColor: Constants.clientBackgroundGrey,
              body: Center(
                child: Column(
                  children: [
                    const ClientAppBar(),
                    SizedBox(height: 150,),
                    IconButton(
                      icon:Icon(MdiIcons.refresh),
                      onPressed: (){
                        BlocProvider.of<ProfileBloc>(
                            context)
                            .add(state.failedEvent);
                      },
                    ),
                    Container(
                      child: Center(
                        child: Text('Try Again').tr(),
                      ),
                    ),

                    MaterialButton(
                      child: Container(
                        child: Center(
                          child: Text('Logout'.tr()),
                        ),
                      ),
                      onPressed: (){
                        authenticationBloc.add(LoggedOut());
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ChooseLanguageScreen(),
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

          return Container();
        },
        listener: (context , state){
          if(state is DashboardError ){
            if(state.error == "TIMEOUT"){
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetworkErrorView();
                  });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });

            }
            else if(state.error == "invalidToken"){
              GeneralHandler.handleInvalidToken(context);
            }
            else if (state.error == 'needUpdate'){
              GeneralHandler.handleNeedUpdateState(context);
            }
            else if (state.error == 'wrongPermission'){
              GeneralHandler.handleInvalidToken(context);
            }
          }
          else if (state is EnterODOStart){
            ComFunctions.showMeterDialog(context);

          }
          else if (state is DashboardCaptainIn){

          }
        },
      ),
    );
  }
//  Widget  _buildNamesAndOrdersCards( {List<CapOrdersDataModel> capOrdersList , CaptainOrdersBloc captainOrdersBloc}){
//     return BlocProvider(
//         create:(context)=> ReserveClientBloc(),
//         child: BlocConsumer<ReserveClientBloc , ReserveClientStates>(
//           builder: (context , state){
//             if (state is ReserveClientInitial){
//               return Padding(
//                 padding: EdgeInsets.only(left: screenWidth*0.05, right:screenWidth*0.05 , top: screenWidth*0.05 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.blue)
//                   ),
//                   child: Row(
//                     children: [
//
//                       GestureDetector(
//                         onTap: (){
//                           Navigator.push(context, MaterialPageRoute(
//
//                               builder:(context)=> CaptainOrdersListScreen(
//                                 resourcesData: widget.resourcesData,
//                                 // orderList: widget.capOrdersList,
//                               )));
//                         },
//                         child: Container(
//                           width: screenWidth*0.5,
//                           height: screenHeight*0.12,
//                           decoration: BoxDecoration(
//                               border: Border.all(color: Colors.blue)
//                           ),
//                           // color: Colors.red,
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(left: 15 , right: 7 , top:  7 ,bottom: 7),
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                         padding:EdgeInsets.only(right: 5),
//                                         child: Text('${capOrdersList[0].memberName}',
//                                           style: TextStyle(
//                                               fontSize: 22
//                                           ),
//                                         )),
//
//
//
//
//                                   ],
//                                 ),
//                               ),
//
//                               Padding(
//                                 padding: EdgeInsets.only(left: 15 , right: 7 , top:  7 ,bottom: 7),
//                                 child: Row(
//                                   children: [
//                                     Text('Packages :  ${capOrdersList.length}')
//                                   ],
//                                 ),
//                               ),
//
//
//
//
//                             ],
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(20),
//                         child: MaterialButton(
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                             color: Constants.color2,
//                             child: Text('Reserve',
//                               style: TextStyle(
//                                   color: Colors.white
//
//                               ),),
//                             onPressed: (){
//                               BlocProvider.of<ReserveClientBloc>(context).add(ReserveClient());
//                             }
//
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//             else if (state is ReserveClientLoading){
//               return Padding(
//                 padding: EdgeInsets.only(left: screenWidth*0.05, right:screenWidth*0.05 , top: screenWidth*0.05 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.blue)
//                   ),
//                   child: Row(
//                     children: [
//
//                       GestureDetector(
//                         onTap: (){
//                           Navigator.push(context, MaterialPageRoute(
//
//                               builder:(context)=> CaptainOrdersListScreen(
//                                 resourcesData: widget.resourcesData,
//                                 // orderList: widget.capOrdersList,
//                               )));
//                         },
//                         child: Container(
//                           width: screenWidth*0.5,
//                           height: screenHeight*0.12,
//                           decoration: BoxDecoration(
//                               border: Border.all(color: Colors.blue)
//                           ),
//                           // color: Colors.red,
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(left: 15 , right: 7 , top:  7 ,bottom: 7),
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                         padding:EdgeInsets.only(right: 5),
//                                         child: Text('${capOrdersList[0].memberName}',
//                                           style: TextStyle(
//                                               fontSize: 22
//                                           ),
//                                         )),
//
//
//
//
//                                   ],
//                                 ),
//                               ),
//
//                               Padding(
//                                 padding: EdgeInsets.only(left: 15 , right: 7 , top:  7 ,bottom: 7),
//                                 child: Row(
//                                   children: [
//                                     Text('Packages :  ${capOrdersList.length}')
//                                   ],
//                                 ),
//                               ),
//
//
//
//
//                             ],
//                           ),
//                         ),
//                       ),
//                       Padding(
//                           padding: EdgeInsets.all(20),
//                           child: CustomLoading()
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//             else if (state is ReserveClientSuccess){
//               captainOrdersBloc.add(GetCaptainOrders());
//               return Container();
//             }
//             else if (state is ReserveClientFailure){
//               return Padding(
//                 padding: EdgeInsets.only(left: screenWidth*0.05, right:screenWidth*0.05 , top: screenWidth*0.05 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.blue)
//                   ),
//                   child: Row(
//                     children: [
//
//                       GestureDetector(
//                         onTap: (){
//                           Navigator.push(context, MaterialPageRoute(
//
//                               builder:(context)=> CaptainOrdersListScreen(
//                                 resourcesData: widget.resourcesData,
//                                 // orderList: widget.capOrdersList,
//                               )));
//                         },
//                         child: Container(
//                           width: screenWidth*0.5,
//                           height: screenHeight*0.12,
//                           decoration: BoxDecoration(
//                               border: Border.all(color: Colors.blue)
//                           ),
//                           // color: Colors.red,
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(left: 15 , right: 7 , top:  7 ,bottom: 7),
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                         padding:EdgeInsets.only(right: 5),
//                                         child: Text('${capOrdersList[0].memberName}',
//                                           style: TextStyle(
//                                               fontSize: 22
//                                           ),
//                                         )),
//
//
//
//
//                                   ],
//                                 ),
//                               ),
//
//                               Padding(
//                                 padding: EdgeInsets.only(left: 15 , right: 7 , top:  7 ,bottom: 7),
//                                 child: Row(
//                                   children: [
//                                     Text('Packages :  ${capOrdersList.length}')
//                                   ],
//                                 ),
//                               ),
//
//
//
//
//                             ],
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(20),
//                         child: MaterialButton(
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                             color: Constants.color2,
//                             child: Text('Reserve',
//                               style: TextStyle(
//                                   color: Colors.white
//
//                               ),),
//                             onPressed: (){}
//
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//             return Container();
//           },
//           listener: (context , state){},
//         )
//     );
// }

}
