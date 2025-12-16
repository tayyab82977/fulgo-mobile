import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/captainOrders_bloc.dart';
import 'package:xturbox/blocs/bloc/myPickup_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/myPickup_events.dart';
import 'package:xturbox/blocs/states/myPickup_states.dart';
import 'package:xturbox/data_providers/models/ErrorViewModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/courier/captainDashboard.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/CaptainOrderCardTwo.dart';
import 'package:xturbox/ui/custom%20widgets/customCheckBox.dart';
import 'package:xturbox/ui/custom%20widgets/drawerCaptain.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/custom%20widgets/my_container.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/Constants.dart';

import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';

import '../custom widgets/CaptainAppBar.dart';
import '../custom widgets/ErrorView.dart';
import '../custom widgets/Names&OrdersCard.dart';
import '../custom widgets/OrdersCard.dart';
import '../custom widgets/custom_loading.dart';
// import 'custom widgets/myAppBar.dart';

class MyPickup extends StatefulWidget {

  ResourcesData? resourcesData;

  MyPickup({this.resourcesData});

  @override
  _MyPickupState createState() => _MyPickupState();
}



double? screenWidth, screenHeight;

class _MyPickupState extends State<MyPickup> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  GlobalKey<RefreshIndicatorState>? refreshKeyHome;
  TabController? _tabController;
  MyPickupBloc myPickupBloc = MyPickupBloc();

  List<OrdersDataModelMix> toStore2 = [];
  List<OrdersDataModelMix> toStore3 = [];
  List<OrdersDataModelMix> fromStore2 = [];
  List<OrdersDataModelMix> fromStore3 = [];

  bool selectAll = false ;

  TextEditingController editingControllerToStore = TextEditingController();
  TextEditingController editingControllerFromStore = TextEditingController();


  Future<Null>? onRefreshAll(){
    editingControllerToStore.clear();
    editingControllerFromStore.clear();
    myPickupBloc.add(GetMyPickup());
    return null ;
  }
  void _handleTabSelection() {
    setState(() {
    });
  }
  String packageNumber = '';
  @override
  void initState() {
    _tabController = new TabController(vsync: this ,length: 2);
    _tabController!.addListener(_handleTabSelection);
    refreshKeyHome = GlobalKey<RefreshIndicatorState>();
    myPickupBloc.add(GetMyPickup());

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return BlocProvider(
      create: (context) => MyPickupBloc(),
      child: SafeArea(
        child: Scaffold(
          key: _drawerKey,
          drawer: CaptainDrawer(
            width: screenWidth,
            height: screenHeight,
            resourcesData: widget.resourcesData,
          ),
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white])
            ),
            child: Column(

              children: [
                CaptainAppBar(
                  drawerKey: _drawerKey, screenName: 'Delivery'.tr(),
                ),
                SizedBox(height: 40,),
                // Text('Delivery'.tr() ,
                //   style:TextStyle(
                //       fontSize: 22,
                //       color: Constants.capGrey
                //
                //   ) ,),
                SizedBox(height: 5,),
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
                              width: screenWidth!*0.27,
                              height: screenWidth!*0.27,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft:Radius.circular(25) ),

                                  color: Constants.greyColor
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Image.asset(
                                  "assets/images/dashboardDelivery.png",
                                  // color: Colors.black54,
                                  // placeholderBuilder: (context) => CustomLoading(),
                                  height: 12.0,
                                  width: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        BlocConsumer<MyPickupBloc,MyPickupStates>(
                          bloc: myPickupBloc,
                          builder: (context , state){
                            if (state is MyPickupInitial){

                              return CreateMyPickupScreen(
                                loading: true
                              );

                            }
                            else if(state is MyPickupLoading){
                              return CreateMyPickupScreen(
                                  loading: true
                              );

                            }

                            else if (state is MyPickupLoaded){
                              return CreateMyPickupScreen(
                                  loading: false,
                                myPickupLoaded: state
                              );

                            }
                            else if (state is MyPickupError){

                              return ErrorView(
                                retryAction: (){
                                  BlocProvider.of<MyPickupBloc>(context).add(state.failedEvents);

                                },
                                errorMessage: 'Please try again'.tr(),
                              );
                            }
                            return Container();
                          },
                          listener: (context , state){
                            if (state is MyPickupError){
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
                            else if (state is MyPickupLoaded){
                              toStore2 = state.pickUpDataModel!.toStore!.map((element)=>element).toList();
                              toStore3 = state.pickUpDataModel!.toStore!.map((element)=>element).toList();
                              fromStore2 = state.pickUpDataModel!.fromStore!.map((element)=>element).toList();
                              fromStore3 = state.pickUpDataModel!.fromStore!.map((element)=>element).toList();
                            }
                            else if (state is BulkSoreOutSuccess){
                              myPickupBloc.add(GetMyPickup());

                            }
                          },

                        ),
                      ],
                    ),


                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget CreateMyPickupScreen({required bool loading ,MyPickupLoaded? myPickupLoaded }){


    void filterSearchResults(String query , List<OrdersDataModelMix> list1 , List<OrdersDataModelMix> list2   ) {
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

    String totalToStore = '' ;
    String totalFromStore = '';
    if(myPickupLoaded != null){
      totalToStore = myPickupLoaded.pickUpDataModel!.toStore!.length.toString();
      totalFromStore = myPickupLoaded.pickUpDataModel!.fromStore!.length.toString();
    }
    return Column(
      children: [
        Padding(
          padding:EdgeInsets.only(top: screenHeight!*0.11),
          child: TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Container(
                    width: 190,
                    height: 60,
                    decoration: BoxDecoration(
                        color: _tabController!.index == 0 ? Constants.blueColor : Colors.white,

                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5 , vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Text("Dispatched Shipments".tr(), style: TextStyle(color:_tabController!.index == 0 ?Colors.white: Colors.black,fontSize: 14),)),
                          Text("($totalToStore)".tr(), style: TextStyle(color:_tabController!.index == 0 ?Colors.white: Colors.black,fontSize: 15),),
                        ],
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    width: 190,
                    height: 60,
                    decoration: BoxDecoration(
                        color: _tabController!.index == 1 ? Constants.blueColor : Colors.white,

                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("Out for delivery".tr(), style: TextStyle(color:_tabController!.index == 1 ?Colors.white: Colors.black,fontSize: 14),)),
                          Text("($totalFromStore)".tr(), style: TextStyle(color:_tabController!.index == 1 ?Colors.white: Colors.black,fontSize: 14),),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
        ),
        loading ?
        Expanded(
            child: Center(child: CustomLoading())
        ) :
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      myPickupLoaded!.pickUpDataModel!.toStore!.length > 0 ?
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:12),
                            child: GestureDetector(
                              onTap:(){
                                setState(() {
                                  selectAll = !selectAll ;
                                  if(selectAll){
                                    toStore2.forEach((element) {
                                      element.selected = true ;
                                    });
                                  }else{


                                    toStore2.forEach((element) {
                                      element.selected = false  ;
                                    });
                                  }

                                });
                              },
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CustomCheckBox(
                                    backgroundColor: Colors.white,
                                    checked: selectAll,
                                    checkedColor: Constants.blueColor,
                                    unCheckedColor: Constants.blueColor),
                              ),
                            ),
                          ),

                          SizedBox(width: 5,),
                          Expanded(
                            child: TextFormField(
                              autofocus: false,
                                keyboardType: TextInputType.number,

                                onChanged: (value){
                                filterSearchResults(value , toStore2 , toStore3 );
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
                          SizedBox(width: 10,),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) ,
                              primary: Constants.blueColor, // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              print(toStore2.where((element) => element.selected == true).length) ;
                              if(toStore2.where((element) => element.selected == true).isNotEmpty){
                                myPickupBloc.add(BulkStoreOut(list: toStore2.where((element) => element.selected == true).toList()));

                              }
                            },
                            child: Text('Accept'.tr()),
                          ),
                        ],
                      ) : Container(),
                      Expanded(
                        child: RefreshIndicator(
                          key: refreshKeyHome,
                          onRefresh: () async {
                            await onRefreshAll() ;
                          },
                          child: toStore2.length > 0 ?
                          ListView.builder(
                            itemCount: toStore2.length ,
                            itemBuilder: (context, i) {
                              return CaptainOrderCardTwo(
                                resourcesData: widget.resourcesData,
                                ordersDataModel: toStore2[i],
                                longActions: false,
                                shortActions: true,
                                myPickupBloc: myPickupBloc,
                                orderList: toStore2,
                                scaffoldKey: _drawerKey,

                              );

                            },
                          ) :
                          ListView.builder(
                            itemCount: 1,
                            itemBuilder: (context, i) {
                              return EmptyView();

                            },
                          )
                          ,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  child: Column(
                    children: [
                      myPickupLoaded.pickUpDataModel!.fromStore!.length > 0 ?
                      Padding(
                        padding: EdgeInsets.only(left: 12, right:12 , top: 8),
                        child: TextFormField(
                            autofocus: false,
                            keyboardType: TextInputType.number,

                            onChanged: (value){
                              filterSearchResults(value , fromStore2 , fromStore3 );
                            },
                            controller: editingControllerFromStore,
                            decoration: kTextFieldDecoration2.copyWith(
                              hintText: 'Search'.tr(),
                              suffixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),

                            )
                        ),
                      ) : Container(),
                      Expanded(
                        child: RefreshIndicator(
                          // key: refreshKeyHome,
                            onRefresh: () async {
                              await onRefreshAll() ;
                            },

                            child: myPickupLoaded.pickUpDataModel!.fromStore!.length > 0 ?
                            ListView.builder(
                              itemCount: fromStore2.length,
                              itemBuilder: (context, i) {
                                return CaptainOrderCardTwo(
                                  resourcesData: widget.resourcesData,
                                  ordersDataModel: fromStore2[i],
                                  longActions: true,
                                  shortActions: false,
                                  myPickupBloc: myPickupBloc,
                                  showD: false,
                                  orderList:fromStore2,
                                  scaffoldKey: _drawerKey,



                                );



                              },
                            ) :
                            ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context, i) {
                                return EmptyView();

                              },
                            )

                        ),
                      ),
                    ],
                  ),
                ),
              )


            ],
          ),
        ),

      ],
    );


  }

}
