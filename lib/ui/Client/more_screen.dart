import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:xturbox/blocs/bloc/addressBloc.dart';
import 'package:xturbox/blocs/bloc/clientPayments_bloc.dart';
import 'package:xturbox/blocs/bloc/drawerClient_bloc.dart';
import 'package:xturbox/blocs/bloc/invoices_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/drawerClient_events.dart';
import 'package:xturbox/blocs/states/address_states.dart';
import 'package:xturbox/blocs/states/clientPayments_states.dart';
import 'package:xturbox/blocs/states/drawerClient_states.dart';
import 'package:xturbox/blocs/states/invoices_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/userModel.dart';
import 'package:xturbox/ui/Client/addressScreen.dart';
import 'package:xturbox/ui/Client/bankScreen.dart';
import 'package:xturbox/ui/Client/clientPayments.dart';
import 'package:xturbox/ui/Client/eWallet_screen.dart';
import 'package:xturbox/ui/custom%20widgets/NetworkErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/home_button.dart';
import 'package:xturbox/ui/Client/editProfile.dart';
import 'package:xturbox/ui/Client/invoicesScreen.dart';
import 'package:xturbox/ui/Client/shipmentTracking.dart';
import 'package:xturbox/ui/Client/tickets_screen.dart';
import 'package:xturbox/ui/dialogs/addAccount_dilog.dart';
import 'package:xturbox/ui/dialogs/confirmation_dialog.dart';
import 'package:xturbox/ui/dialogs/logOut_confirm.dart';
import 'package:xturbox/ui/dialogs/switchAccount_dialog.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/push_nofitications.dart';

import '../common/chooseLanguageScreen.dart';
import '../custom widgets/custom_loading.dart';


class MoreScreen extends StatefulWidget {
   ResourcesData resourcesData ;
   MoreScreen({required this.resourcesData});
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  double width = 0  , height = 0 ;
  final _reasonController = TextEditingController();
  late SolidController solidController;


  @override
  void initState() {
    solidController = SolidController();
    super.initState();
  }
  @override
  void dispose() {
    solidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size ;
    height = size.height ;
    width  = size.width ;

    return BlocProvider(
      create: (context) => DrawerClientBloc(),
      child: BlocConsumer<DrawerClientBloc, DrawerClientStates>(
        builder: (context , state ){
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  color: Constants.blueColor,
                  child: Column(
                    children: [
                      SizedBox(height: 40,),
                      Image.asset("assets/images/WELCOME SCREEN TOP.png",fit: BoxFit.fitWidth,),
                    ],
                  ),
                ),
                BackdropFilter(
                  filter:  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child:   Container(
                    decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                          Icon(Icons.more_horiz_rounded , size: 60, color: Colors.white,),
                          Text("More".tr() , style: TextStyle(color: Colors.white , fontSize: 16 , fontWeight: FontWeight.bold , height: 0.2),),
                          SizedBox(height: 10,),
                          //TODO fix for small screens
                          Expanded(
                            child: LayoutBuilder(builder: (context , constrains){
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40 , bottom: 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 35,),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Image.asset('assets/images/X Blue wf.png', height: 30,),
                                                Flexible(
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      _showBottomSheet(context);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                                      child: Text(SavedData.profileDataModel.name ?? "" ,
                                                        maxLines: 1,
                                                        style: TextStyle(color: Constants.blueColor , fontSize: 24 , fontWeight: FontWeight.bold  ),),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            flex: 6,
                                            child: ListView(
                                              padding:EdgeInsets.zero,
                                              children: [
                                                _moreElement("My Profile" , "user-svgrepo-com.svg" ,
                                                      (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(
                                                      resourcesData: SavedData.resourcesData,
                                                      dashboardDataModel: SavedData.profileDataModel,
                                                    )));
                                                  },
                                                ),
                                                _moreElement("My Payments" , "wallet.svg" ,
                                                        (){
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ClientPaymentsScreen(
                                                                resourcesData: widget.resourcesData,
                                                              )));
                                                    }
                                                ),
                                                _moreElement("Transfer to wallet" , "wallet-transfer.svg" ,
                                                        (){
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => EWalletScreen(
                                                                resourcesData: widget.resourcesData,
                                                              )));
                                                    }
                                                ),
                                                _moreElement("My addresses" , "myAddresses.svg" , (){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => AddressScreen(
                                                            resourcesData: widget.resourcesData,
                                                          )));
                                                }),
                                                _moreElement("Bank Account" , "myBank.svg",(){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => BankScreen(
                                                            resourcesData: widget.resourcesData,
                                                            dashboardDataModelNew: SavedData.profileDataModel,
                                                          )));
                                                }),
                                                _moreElement("My Invoices" , "invoice.svg",(){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => InvoicesScreen(
                                                            resourcesData: widget.resourcesData,
                                                          )));
                                                }),
                                                _moreElement("Ticketing" , "ticket.svg",(){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => TicketsScreen(
                                                            resourcesData: widget.resourcesData,
                                                          )));
                                                }),
                                                _moreElement("Tracking" , "route.svg",(){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => ShipmentTracking(
                                                            resourcesData: widget.resourcesData,
                                                            dashboardDataModel: SavedData.profileDataModel,
                                                          )));
                                                }),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    _moreElement("Call customer support" , "route.svg" ,),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                            padding: EdgeInsets.all(0),
                                                            onPressed: () {
                                                              ComFunctions.launcPhone2(SavedData.resourcesData.customerSupportNumber ?? "8001111757" );
                                                            },
                                                            icon: Icon(
                                                              Icons.phone,
                                                              size: width * 0.06,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            padding: EdgeInsets.all(0),
                                                            onPressed: () {
                                                              ComFunctions.launcWhatsapp(
                                                                  SavedData.resourcesData.customerSupportWhatsapp ?? "0580000451");
                                                            },
                                                            icon: Icon(
                                                              MdiIcons.whatsapp,
                                                              size: width * 0.06,
                                                              color: Colors.green,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('ver :'.tr()),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(Constants.appVersion),
                                                  ],
                                                ),
                                              ],
                                            ),

                                          ),
                                          FlatButton.icon(
                                              padding: EdgeInsets.all(0),
                                              onPressed: () {
                                                _logoutConfirmation(context);
                                              },
                                              icon: Icon(
                                                Icons.logout,
                                                size: 25,
                                                color: Colors.red,
                                              ),
                                              label: Text(
                                                'Log Out'.tr(),
                                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                                              )),
                                          SizedBox(height: 10,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(
                                          resourcesData: SavedData.resourcesData,
                                          dashboardDataModel: SavedData.profileDataModel,
                                        )));
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Constants.blueColor)
                                        ),
                                        child: Icon(Icons.person , color: Constants.blueColor, size: 30,),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                            }),
                          )
                        ],
                      ),
                    ),

                    Expanded(child: HomeButton(isMore: true,)),

                  ],
                )

              ],
            ),
          );
        },
        listener: (context, state) {
          if (state is DrawerClientSuccess) {
            Navigator.pop(context);
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState2) {
                      return AlertDialog(
                        title: Column(
                          children: [
                            SvgPicture.asset(
                              "assets/images/success.svg",
                              height: 30,
                            ),
                          ],
                        ),
                        content: Text(
                          'Your request has been sent successfully we will contact you as soon as possible'
                              .tr(),
                        ),
                        actions: [
                          TextButton(
                            child: Text('ok'.tr()),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                });
          }
          if (state is DrawerClientLoading) {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return AlertDialog(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Loading...'.tr()),
                        Container(
                            width: 20,
                            height: 20,
                            child: CustomLoading()),
                      ],
                    ),
                  );
                });
          }
          if (state is DrawerClientError) {
            if (state.error == "TIMEOUT") {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetworkErrorView();
                  });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            } else if (state.error == "general") {
              GeneralHandler.handleGeneralError(context);
            } else {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return AlertDialog(
                      content:
                      Text('Something went wrong please try again'.tr()),
                    );
                  });
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
              });
            }
          }
        },
      ),
    );
  }

  _moreElement(String text , String image , [VoidCallback? navigationFunc]){
    return Material(
      color: Colors.transparent,
      child: Center(
        child: InkWell(
          onTap: navigationFunc,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/images/$image", color: Colors.black, width: 15,),
                SizedBox(width: 10,),
                Text(text.tr() , style: TextStyle(color: Colors.black , fontSize: 16 , ),),
                SizedBox(height: 40,)

              ],
            ),
          ),
        ),
      ),
    );
  }
  _showBottomSheet(BuildContext context){

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return SolidBottomSheet(
              draggableBody: true,
              autoSwiped: true,
              elevation: 0,
              maxHeight: 200,
              showOnAppear: true,
              onHide: (){},
              headerBar: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10 , vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("My Accounts".tr(),style: TextStyle(color: Constants.blueColor,fontSize: 18),textAlign: TextAlign.end,),

                    InkWell(
                        onTap:(){
                         _addAccountDialog(context);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Add account".tr(),style: TextStyle(color: Constants.blueColor,fontSize: 15,height: 1.2),textAlign: TextAlign.end,),

                            Icon(Icons.add,color: Constants.blueColor,size: 22,),
                          ],
                        )),

                  ],
                ),
              ),
              ),
              body: Container(
                color: Colors.white,
                child: ListView(
                  children:  SavedData.accountsList.map((e)
                  =>  Material(
                    color: Colors.white,
                    child: CupertinoActionSheetAction(
                        child: InkWell(
                          onTap: (){
                            if(SavedData.profileDataModel.phone != e.phone )
                              _switchAccountDialog(context,e.name,e.phone , e.password);

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.account_circle , color: Constants.blueColor,size: 30,),
                                  SizedBox(width: 10,),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.name ,style: TextStyle(color: Constants.blueColor,fontSize: 22), ),
                                      Text(e.phone ,style: TextStyle(color: Constants.blueColor,fontSize: 15), ),
                                    ],
                                  ),
                                ],
                              ),
                              SavedData.profileDataModel.phone == e.phone ?
                              Icon(Icons.check,color: Constants.capGreen,) :
                              InkWell(
                                  onTap:(){
                                    _deleteDialog(context,e);
                                  },
                                  child: Icon(Icons.delete,color: Constants.redColor,)),
                            ],
                          ),
                        ),
                        onPressed: (){

                        }
                    ),
                  )).toList(),
                ),
              ), // Your body here
            );});

  }
  _deleteDialog(BuildContext context, UserModel e){
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return ConfirmationDialog(
            function: (){
              UserModel.deleteAccount(e);
            },
            name: e.name,
          );
        });
  }
  _addAccountDialog(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AddAccountDialog();
        });
  }
  _logoutConfirmation(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return LogoutConfirmationDialog();
        });
  }
  _switchAccountDialog(BuildContext context,String name , String phone , String password){
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return SwitchAccountDialog(
            phone: phone,
            password: password,
            name: name,
          );
        });
  }
}