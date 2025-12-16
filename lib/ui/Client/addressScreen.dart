import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/addressBloc.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/dashboard_bloc.dart';
import 'package:xturbox/blocs/bloc/editProfile_bloc.dart';
import 'package:xturbox/blocs/events/address_events.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/blocs/states/address_states.dart';
import 'package:xturbox/blocs/states/dashboard_states.dart';
import 'package:xturbox/blocs/states/editProfile_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/home_button.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';
import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';
import 'editAddressScreen.dart';

import '../custom widgets/drawerClient.dart';
import '../custom widgets/myAppBar.dart';
import '../common/dashboard.dart';


enum addressActions { edit, cancel}

class AddressScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  AddressScreen({this.resourcesData});
  @override
  _AddressScreenState createState() => _AddressScreenState();
}



class _AddressScreenState extends State<AddressScreen> {

  Future<bool> CheckInternet()async{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
        return false ;

    }
    else {
      return true ;
    }
  }

  double? screenWidth , screenHeight , width , height ;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  addressActions? _selection;
  // List<Addresses> addressList2 = [];


  var _formKey = GlobalKey<FormState>();

  ProfileDataModel? dashboardDataModel ;
  bool? connected ;

  UserRepository userRepository = UserRepository();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
  }

  Future<bool> _onBackPressed()async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardScreen(
              resourcesData: widget.resourcesData,
            )));
    return true ;
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height ;
    width = size.width;
    return BlocProvider(
      create: (context)=>AddressBloc()..add(GetAddress()),
      child: WillPopScope(
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
                          padding: EdgeInsets.only(right: screenWidth!*0.03, left: screenWidth!*0.03, top: screenHeight!*0.01 ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              Expanded(
                                child: BlocConsumer<AddressBloc , AddressStates>(
                                  builder:(context , state){

                                    if(state is AddressError){

                                      return CreateAddressScreen(loading: false , addressBloc: BlocProvider.of<AddressBloc>(context) , error: true);
                                    }
                                    else if(state is AddressLoaded){
                                      print('11111');
                                      return CreateAddressScreen(loading: false ,list: state.addressList , addressBloc: BlocProvider.of<AddressBloc>(context),error: false );
                                    }

                                    return CreateAddressScreen(loading: true, addressBloc: BlocProvider.of<AddressBloc>(context),error: false
                                    );
                                  } ,
                                  listener: (context , state){
                                    if(state is DashboardEditAddressSuccess){
                                    BlocProvider.of<AddressBloc>(context).add(GetAddress());
                                    }

                                    if(state is AddressError){
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
                                      else if (state.error == "general"){
                                        GeneralHandler.handleGeneralError(context);
                                      }

                                    }
                                  },

                                ),
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
      ),
    );
  }
  Widget CreateAddressScreen({required bool loading , List<Addresses>? list , required AddressBloc addressBloc , required bool error }){

   return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  "assets/images/placeholder.svg",
                  placeholderBuilder: (context) => CustomLoading(),
                  height: 38.0,
                  color: Constants.blueColor
                ),
                SizedBox(width: 15,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My addresses'.tr(),
                      style:TextStyle(
                          fontSize: 17,
                          height: 0.8,
                          fontWeight: FontWeight.w500,
                          color: Constants.blueColor
                      ),
                    ),
                    Row(
                      children: [
                        Text(list?.length.toString() ??"" ,
                          style:TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Constants.redColor
                          ),
                        ),
                        SizedBox(width: 5,),
                        Text('Total'.tr(),
                          style:TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Constants.redColor
                          ),
                        ),
                      ],
                    ),


                  ],

                )
              ],
            ),
            MaterialButton(
              minWidth: 100,
              height: 50,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
              ),
              color: Constants.blueColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add , size: 25, color: Colors.white,),
                  Text('Add New'.tr(),style: TextStyle(color: Colors.white,)),
                ],
              ),
              onPressed: (){
                if(list != null){
                  Navigator.push(context, MaterialPageRoute(
                      builder:(context)=> EditAddressScreen(
                        addressBloc: addressBloc,
                        resourcesData: widget.resourcesData,
                        addressList: list,
                        // addresses: addressList2.elementAt(index),
                      ) ));
                }

              },
            )
          ],
        ),
        !loading?
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15,),
            child: RefreshIndicator(
              onRefresh: ()async{
                addressBloc.add(GetAddress());
              },
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: list?.length ,
                itemBuilder:(context , i){
                  return _buildAreas(addressElement:list?[i] , myList: list , addressBloc:addressBloc );
                } ,
              ),
            ),
          ),
        ) :
        Expanded(
          child: Center(
            child: CustomLoading(),
          ),
        ),

        error? Padding(
          padding: const EdgeInsets.only(top: 50),
          child: ErrorView(
            errorMessage: '',
            retryAction: (){
              addressBloc.add(GetAddress());
            },
          ),
        ): Container()


      ],
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }

  Widget _buildAreas( { Addresses? addressElement , List<Addresses>? myList,required AddressBloc addressBloc}) {

    String? cityName ;
    String? realCityName ;

    for (int i = 0 ; i < (widget.resourcesData?.city?.length ?? 0) ; i ++ ){

      for(int x = 0 ; x < (widget.resourcesData?.city?[i].neighborhoods?.length  ?? 0); x++){
        if (addressElement?.city == widget.resourcesData?.city?[i].neighborhoods?[x].id){
          realCityName = widget.resourcesData?.city?[i].name ;
          cityName = widget.resourcesData?.city?[i].neighborhoods?[x].name ;
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
              padding:  EdgeInsets.symmetric(horizontal: screenWidth!*0.01),
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
                              addressElement?.title == "Work" || addressElement?.title=="العمل"  ?
                              Icon(Icons.work, size: 40,) :addressElement?.title == "Home" || addressElement?.title=="المنزل"?
                              Icon(Icons.home, size: 40) : Icon(MdiIcons.officeBuilding, size: 40),
                              SizedBox(width: 5,),
                            ],
                          ),
                          SizedBox(width: 15,),
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
                                width: screenWidth!*0.55,
                                child: AutoSizeText(
                                  addressElement?.description ?? "",
                                  maxLines: 4,
                                  style: TextStyle(
                                    color: Constants.blueColor,
                                    fontSize: width! * 0.03,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Cairo",
                                    overflow: TextOverflow.fade,),
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
                  child: MaterialButton(
                    onPressed: (){
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>EditAddressScreen(
                            addressBloc: addressBloc,
                            resourcesData: widget.resourcesData,
                            addressList: myList,
                            addresses: addressElement,
                          )
                      ));
                      },
                    child: Text('Edit'.tr()),
                  ),
                ),
                PopupMenuItem<addressActions>(
                  value: addressActions.edit,
                  child: MaterialButton(
                    onPressed: (){
                     setState(() {
                       Navigator.pop(context);
                       myList!.remove(addressElement);
                       addressBloc.add(DeleteAddress(
                         adressList: myList
                       ));
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

