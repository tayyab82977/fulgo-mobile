import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/checkIn_bloc.dart';
import 'package:xturbox/blocs/bloc/myReserve_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/myReserve_events.dart';
import 'package:xturbox/blocs/states/myReserve_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/CaptainOrderCardTwo.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/Names&OrdersCard.dart';
import 'package:xturbox/ui/custom%20widgets/emptyListSataView.dart';
// import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/my_container.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';

import '../../main.dart';
import '../custom widgets/CaptainAppBar.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/drawerCaptain.dart';
import '../common/dashboard.dart';

class MyReserves extends StatefulWidget {
  ResourcesData? resourcesData ;
  ProfileDataModel? dashboardDataModel ;

  MyReserves({this.resourcesData, this.dashboardDataModel});

  @override
  _MyReservesState createState() => _MyReservesState();
}
double? screenWidth , screenHeight ;
class _MyReservesState extends State<MyReserves> {

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  MyReservesBloc getMyReserves = MyReservesBloc();
  AuthenticationBloc authenticationBloc = AuthenticationBloc() ;
  String packageNumber = '' ;
  GlobalKey<RefreshIndicatorState>? refreshKeyHome;
  TextEditingController editingControllerToStore = TextEditingController();

  Future<Null> onRefreshAll({List<OrdersDataModelMix>? list})async{
    editingControllerToStore.clear();
    getMyReserves.add(GetMyReserves());
    return null ;
  }
  List<OrdersDataModelMix> toStore1 = [];
  List<OrdersDataModelMix> toStore2 = [];

  void filterSearchResults(String query , List<OrdersDataModelMix> list1 , List<OrdersDataModelMix> list2) {
    List<OrdersDataModelMix> dummySearchList = [];
    dummySearchList.addAll(list2);
    if(query.isNotEmpty) {
      List<OrdersDataModelMix> dummyListData = [];
      dummySearchList.forEach((item) {
        if(item.id!.contains(query)) {
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

  @override
  void initState() {
    getMyReserves.add(GetMyReserves());
    refreshKeyHome = GlobalKey<RefreshIndicatorState>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
     screenWidth = size.width;
     screenHeight = size.height;

    return BlocProvider(
        create: (context)=> MyReservesBloc(),
        child: SafeArea(
          child: Scaffold(
            key: _drawerKey,
            drawer: CaptainDrawer(
                resourcesData: widget.resourcesData,
                width: screenWidth,
                height: screenHeight
            ),
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // colors: [Color(0xffE0DAE8), Color(0xffE6C7D0)])
                      colors: [Colors.white,
                        Colors.white])
              ),
              child: Column(
                children: [
                  CaptainAppBar(
                    drawerKey:_drawerKey, screenName: 'Return to Warehouse'.tr(),
                  ),
                  SizedBox(height: 5,),
                  // Text('Return to Warehouse'.tr() ,
                  //   style:TextStyle(
                  //       fontSize: 25,
                  //       color: Constants.capGrey,
                  //     fontWeight: FontWeight.bold
                  //
                  //   ) ,),
                  Expanded(
                    child: BlocConsumer<MyReservesBloc , MyReservesStates>(
                      bloc: getMyReserves,
                      builder: (context , state){
                        if(state is MyReservesInitial){
                          return CreateMyReservesScreen(
                            loading: true,
                            empty: true,
                          );

                        }
                        else if(state is MyReservesLoading){
                          return CreateMyReservesScreen(
                              loading: true,
                             empty: true,
                            myReservesBloc: getMyReserves
                          );

                        }

                        else if(state is MyReservesLoaded){
                          return CreateMyReservesScreen(
                            loading: false,
                            myReservesLoaded: state,
                            empty: true,
                              myReservesBloc: getMyReserves

                          );

                        }
                        else if(state is MyReservesEmpty){
                          return SafeArea(
                            child:CreateMyReservesScreen(
                              loading: false ,
                              empty: false ,
                                myReservesBloc: getMyReserves

                            )
                          );

                        }
                        else if (state is MyReservesFailure){
                          return ErrorView(
                            retryAction: (){
                              getMyReserves.add(GetMyReserves());
                            },
                            errorMessage: '',
                          );
                        }

                        return Container();
                      },
                      listener: (context , state){
                        if (state is MyReservesFailure){
                         if (state.error == 'needUpdate'){
                           GeneralHandler.handleNeedUpdateState(context);
                        }
                         else if(state.error == "invalidToken"){
                           GeneralHandler.handleInvalidToken(context);
                         }
                         else if (state.error == "general"){
                           GeneralHandler.handleGeneralError(context);
                         }
                        }
                        else if (state is MyReservesLoaded){
                        toStore1 =  state.ordersList!.map((element)=>element).toList();
                        toStore2 =  state.ordersList!.map((element)=>element).toList();
                        }
                      },
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      );
  }
  Widget CreateMyReservesScreen({MyReservesLoaded? myReservesLoaded , required bool loading , bool? empty , MyReservesBloc? myReservesBloc}){
    if (myReservesLoaded != null){
        packageNumber = toStore1.length.toString() ;

    }else {
      packageNumber = '';
    }

    return Column(
      children: [

        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have'.tr() ,
              style:TextStyle(
                  fontSize: 15,
                  color: Constants.capGrey,
                  fontWeight: FontWeight.bold

              ) ,),
            SizedBox(width: 5,),
            Text(packageNumber,
              style:TextStyle(
                  fontSize: 15,
                  color: Constants.capGrey,
                  fontWeight: FontWeight.bold

              ) ,),
            SizedBox(width: 5,),

            Text('Shipments'.tr() ,
              style:TextStyle(
                  fontSize: 15,
                  color: Constants.capGrey,
                  fontWeight: FontWeight.bold

              ) ,),
          ],
        ),

        SizedBox(height: 15,),

        Expanded(
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [

                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding:EdgeInsets.only(top: screenHeight!*0.06),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft:Radius.circular(25) ),
                          color: Constants.greyColor,

                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment:Alignment.topCenter,
                    child: Container(
                      width: screenWidth!*0.25,
                      height: screenWidth!*0.25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft:Radius.circular(25) ),
                          color: Constants.greyColor
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.asset(
                          "assets/images/warehouse.png",
                          // color: Colors.black54,
                          // placeholderBuilder: (context) => CustomLoading(),
                          height: 10.0,
                          width: 10,
                        ),
                      ),
                    ),
                  ),
                ),

              loading ?
              Center(
                child: CustomLoading(),
              ):
              (myReservesLoaded?.ordersList?.length ?? 0)> 0 ?
              Padding(
                padding: EdgeInsets.only(top: screenHeight!*0.100),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12, right:12 , top: 8),
                      child: TextFormField(
                          autofocus: false,
                          keyboardType: TextInputType.number,

                          onChanged: (value){
                            filterSearchResults(value , toStore1 , toStore2 );
                          },
                          controller: editingControllerToStore,
                          decoration: kTextFieldDecoration2.copyWith(
                            hintText: 'Search'.tr(),
                            suffixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            ),

                          )
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await onRefreshAll();
                        },
                        child: ListView.builder(
                          itemCount: toStore1.length,
                          itemBuilder: (context , i){
                            // return  NamesAndOrdersCard(
                            //   resourcesData: widget.resourcesData,
                            //   capOrdersList: myReservesLoaded.ordersList![i],
                            //   hasAction: false,
                            //   reserved: true,
                            //   myReservesBloc: myReservesBloc,
                            //   print: true,
                            //   dashboardDataModel: widget.dashboardDataModel,
                            //
                            // ) ;

                            return CaptainOrderCardTwo(
                              resourcesData: widget.resourcesData,
                              ordersDataModel: toStore1[i],
                              longActions: false,
                              shortActions: false,
                              myReservesBloc: myReservesBloc,
                              showD: false,
                              reActive: true,
                              scaffoldKey: _drawerKey,

                            );

                          },

                        ),
                      ),
                    ),
                  ],
                ),
              ) : Padding(
                padding: EdgeInsets.only(top: screenHeight!*0.155),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await onRefreshAll();
                  },
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context , i){
                      return  EmptyListView(
                        resourcesData: widget.resourcesData,
                      ) ;

                    },

                  ),
                ),
              )


              ],
            ),

          ),
        ),
      ],
    );



  }
}
