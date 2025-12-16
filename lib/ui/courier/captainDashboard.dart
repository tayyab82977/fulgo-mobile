import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/captainOrders_bloc.dart';
import 'package:xturbox/blocs/events/captainOrders_events.dart';
import 'package:xturbox/blocs/states/captainOrders_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import '../../UserRepo.dart';
import '../custom widgets/CaptainAppBar.dart';
import '../custom widgets/Names&OrdersCard.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/drawerCaptain.dart';
class CaptainDashboard extends StatelessWidget {
  ResourcesData? resourcesData ;

  CaptainDashboard({this.resourcesData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CaptainOrdersBloc()
        ..add(GetCaptainOrders()),

      child: CaptainDashboardBloc(
        resourcesData: resourcesData,
      ),
    );
  }
}

class CaptainDashboardBloc extends StatefulWidget {
  ResourcesData? resourcesData ;

  CaptainDashboardBloc({this.resourcesData});


  @override
  _CaptainDashboardBlocState createState() => _CaptainDashboardBlocState();
}

class _CaptainDashboardBlocState extends State<CaptainDashboardBloc> with TickerProviderStateMixin {
  GlobalKey<RefreshIndicatorState>? refreshKeyHome;

  double? screenWidth , screenHeight ;
  CaptainOrdersBloc _bloc = CaptainOrdersBloc() ;
  
  Future<Null>? onRefreshAll(){
    editingControllerToStore.clear();
    editingControllerFromStore.clear();
    _bloc.add(GetCaptainOrders());
    return null ;
  }

  List<List<OrdersDataModelMix>>? toStore2 = [];
  List<List<OrdersDataModelMix>> toStore3 = [];
  List<OrdersDataModelMix> fromStore2 = [];
  List<OrdersDataModelMix> fromStore3 = [];

  TextEditingController editingControllerToStore = TextEditingController();
  TextEditingController editingControllerFromStore = TextEditingController();

  AuthenticationBloc authenticationBloc = AuthenticationBloc();
  TabController? _tabController;

  UserRepository userRepository = UserRepository();


  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  void _handleTabSelection() {
    setState(() {
    });
  }


@override
  void dispose() {
    _bloc.close();
    super.dispose();
  }




  @override
  void initState() {
  _tabController = new TabController(vsync: this ,length: 2);
  _tabController!.addListener(_handleTabSelection);
  refreshKeyHome = GlobalKey<RefreshIndicatorState>();
  _bloc.add(GetCaptainOrders());
  super.initState();
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
     screenWidth = size.width;
     screenHeight = size.height;

     return SafeArea(
       child: Scaffold(
         key:_drawerKey ,
         drawer:CaptainDrawer(
           resourcesData: widget.resourcesData,
           width: screenWidth,
           height: screenHeight
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
                 drawerKey: _drawerKey, screenName: 'Pickup'.tr(),
               ),
               SizedBox(height: 40,),
               // Text('Pickup'.tr() ,
               //   style:TextStyle(
               //     fontSize: 22,
               //     color: Constants.capGrey
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
                                 "assets/images/dashboardPickup.png",
                                 // color: Colors.black54,
                                 // placeholderBuilder: (context) => CustomLoading(),
                                 height: 10.0,
                                 width: 10,
                               ),
                             ),
                           ),
                         ),
                       ),
                       BlocConsumer<CaptainOrdersBloc, CaptainOrdersStates>(
                         bloc:_bloc ,
                         builder: (context , state){
                           if(state is CaptainOrdersInitial){
                             return CreateMyReservesScreen(
                               loading: true,
                             );
                           }
                           else if(state is CaptainOrdersLoading){
                             return CreateMyReservesScreen(
                               loading: true,
                             );
                           }
                           else if (state is CaptainOrdersLoaded){

                             return CreateMyReservesScreen(
                               loading: false,
                               captainOrdersLoaded: state,
                             );
                           }
                           else if (state is CaptainOrdersError){
                             return ErrorView(

                               retryAction: (){
                                 _bloc.add(GetCaptainOrders());
                               },
                               errorMessage: 'Something went wrong please try again'.tr(),
                             );
                           }
                           return Container();
                         },
                         listener: (context , state){
                           if(state is CaptainOrdersError){
                            if (state.error == 'needUpdate'){
                              GeneralHandler.handleNeedUpdateState(context);
                           }
                            if (state.error == 'TIMEOUT'){
                              GeneralHandler.handleNetworkError(context);

                           }
                            else if(state.error == "invalidToken"){
                              GeneralHandler.handleInvalidToken(context);
                            }
                            else if (state.error == "general"){
                              GeneralHandler.handleGeneralError(context);
                            }
                           }
                           else if(state is CaptainOrdersLoaded){
                            // toStore2 = state.newForCapOrders!.toStore!.map((element)=>element).toList();
                           //  toStore3 = state.newForCapOrders!.toStore!.map((element)=>element).toList();
                           //  fromStore2 = state.newForCapOrders!.fromSore!.map((element)=>element).toList();
                           //  fromStore3 = state.newForCapOrders!.fromSore!.map((element)=>element).toList();


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
     );

  }
  Widget CreateMyReservesScreen({required bool loading ,CaptainOrdersLoaded? captainOrdersLoaded}){

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
    if(captainOrdersLoaded != null){
      totalToStore = captainOrdersLoaded.newForCapOrders!.fromClient!.length.toString();
      totalFromStore = captainOrdersLoaded.newForCapOrders!.reserves!.length.toString();
    }
    return Column(
      children: [
        Padding(
          padding:EdgeInsets.only(top: screenHeight!*0.12),
          child: TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                        color: _tabController!.index == 0 ? Constants.blueColor : Colors.white,

                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New Orders".tr(), style: TextStyle(color:_tabController!.index == 0 ?Colors.white: Colors.black,fontSize: 16),),
                        SizedBox(width: 5,),
                        Text("($totalToStore)".tr(), style: TextStyle(color:_tabController!.index == 0 ?Colors.white: Colors.black,fontSize: 14),),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                        color: _tabController!.index == 1 ? Constants.blueColor : Colors.white,

                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Reserved".tr(), style: TextStyle(color:_tabController!.index == 1 ?Colors.white: Colors.black,fontSize: 16),),
                        SizedBox(width: 5,),
                        Text("($totalFromStore)".tr(), style: TextStyle(color:_tabController!.index == 1 ?Colors.white: Colors.black,fontSize: 14),),
                      ],
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
              Padding(
                padding: const EdgeInsets.only(bottom: 8 , top: 10),
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  child: RefreshIndicator(
                    key: refreshKeyHome,
                    onRefresh: () async {
                      await onRefreshAll() ;
                    },
                    child: captainOrdersLoaded!.newForCapOrders!.fromClient!.length > 0 ?
                    ListView.builder(
                      itemCount: captainOrdersLoaded.newForCapOrders!.fromClient!.length ,
                      itemBuilder: (context, i) {
                        return NamesAndOrdersCard(
                          captainOrdersBloc: _bloc,
                          resourcesData: widget.resourcesData,
                          capOrdersList: captainOrdersLoaded.newForCapOrders!.fromClient![i],
                          hasAction: true,
                          reserved: false,
                          print: false,
                        );
                        // return _buildNamesAndOrdersCards(
                        //     capOrdersList: state.ordersList[i],
                        //     captainOrdersBloc: _bloc
                        //
                        // );
                        // return Text('Test Test');

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
              ),

              Column(
                children: [
                  SizedBox(height: 10),
                  // captainOrdersLoaded.newForCapOrders!.reserves!.length > 0 ?
                  // Padding(
                  //   padding: EdgeInsets.only(left: 12, right:12 , top: 8),
                  //   child: TextFormField(
                  //       autofocus: false,
                  //       keyboardType: TextInputType.number,
                  //
                  //       onChanged: (value){
                  //         filterSearchResults(value , fromStore2 , fromStore3 );
                  //       },
                  //       controller: editingControllerFromStore,
                  //       decoration: kTextFieldDecoration2.copyWith(
                  //         hintText: 'Search'.tr(),
                  //         suffixIcon: Icon(Icons.search),
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  //         ),
                  //
                  //       )
                  //   ),
                  // ) : Container(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: screenWidth,
                        height: screenHeight,
                        child: RefreshIndicator(
                          // key: refreshKeyHome,
                          onRefresh: () async {
                            await onRefreshAll() ;
                          },

                          child: captainOrdersLoaded.newForCapOrders!.reserves!.length > 0 ?
                          ListView.builder(
                            itemCount: captainOrdersLoaded.newForCapOrders!.reserves!.length,
                            itemBuilder: (context, i) {
                              return NamesAndOrdersCard(
                                captainOrdersBloc: _bloc,
                                resourcesData: widget.resourcesData,
                                capOrdersList: captainOrdersLoaded.newForCapOrders!.reserves![i],
                                hasAction: false,
                                reserved: true,
                                print: true,
                                dashboardDataModel: SavedData.profileDataModel,

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
                    ),
                  ),
                ],
              )


            ],
          ),
        ),

      ],
    );


  }

}

class EmptyView extends StatelessWidget {
  String? text ;
  EmptyView({this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 50,),
        SvgPicture.asset(
          "assets/images/empty-white-box.svg",
          color: Colors.black54,
          placeholderBuilder: (context) => CustomLoading(),
          height: 110.0,
          width: 130,
        ),
        SizedBox(height: 10,),
        Text(text ?? 'There are no orders'.tr(),
          style: TextStyle(
            color: Constants.capGrey,
            fontSize: 19,
          ),
        ),
        SizedBox(height: 50,),

      ],
    );
  }
}

