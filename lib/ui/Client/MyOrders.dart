// import 'dart:html';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:Fulgox/controllers/get_orders_controller.dart';
import 'package:Fulgox/data_providers/models/shipments_lists_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/Client/addOrderB2c.dart';
import 'package:Fulgox/ui/courier/captainDashboard.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/main.dart';
import 'package:Fulgox/ui/Client/addOrder.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/custom%20widgets/ErrorView.dart';
import 'package:Fulgox/ui/custom%20widgets/OrdersCard.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/ui/custom%20widgets/my_container.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/downloader.dart';

import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/drawerClient.dart';
import '../custom widgets/home_button.dart';
import '../common/dashboard.dart';


class MyOrdersScreen extends StatelessWidget {
  ResourcesData? resourcesData ;
  ProfileDataModel? dashboardDataModel ;
  MyOrdersScreen({this.resourcesData , this.dashboardDataModel});

  @override
  Widget build(BuildContext context) {
    Get.put(GetOrdersController());
    return MyOrders(
          resourcesData: resourcesData,
          dashboardDataModel: dashboardDataModel,
        );
  }
}



class MyOrders extends StatefulWidget {
  ResourcesData? resourcesData ;
  ProfileDataModel? dashboardDataModel ;

  MyOrders({this.resourcesData , this.dashboardDataModel});

  @override
  _MyOrdersState createState() => _MyOrdersState();
}


class _MyOrdersState extends State<MyOrders> with TickerProviderStateMixin {

  GlobalKey<AnimatedListState> animatedListController =
  GlobalKey<AnimatedListState>();
  GlobalKey<RefreshIndicatorState>? refreshKeyHome;
  TextEditingController searchController = TextEditingController();
  FocusNode _focus = new FocusNode();
  String localTaskId = "" ;
  bool showSearch = false ;
  List<OrdersDataModelMix> allOrdersList1 = [];
  List<OrdersDataModelMix> allOrdersList2 = [];

  List<OrdersDataModelMix> newOrdersList = [];
  List<OrdersDataModelMix> inDeliveryOrdersList = [];
  List<OrdersDataModelMix> deliveredOrdersList = [];
  List<OrdersDataModelMix> canceledOrdersList = [];





  void _onFocusChange(){
    debugPrint("Focus: "+_focus.hasFocus.toString());
  }

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  // anime.ContainerTransitionType()



  final GetOrdersController _getOrdersController = Get.find<GetOrdersController>();
  TabController? _tabController;
  double? screenWidth , screenHeight ;
  bool _slowAnimations = false;

  @override
  void dispose() {
    _tabController?.dispose();
    _unbindBackgroundIsolate();
    super.dispose();
  }

  ReceivePort _port = ReceivePort();

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
  int count = 0 ;
  String taskId = "" ;
  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];
      localTaskId = id.toString()  ;
      taskId = id.toString() ;



      if (status == DownloadTaskStatus.enqueued && count < 1 ) {
        count ++ ;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Downloading'.tr()),
            backgroundColor: Constants.blueColor,
          ),
        );
      }

      if (status == DownloadTaskStatus.complete) {
        count = 0 ;
        Future.delayed(Duration(seconds: 1), () {
          FlutterDownloader.open(taskId: taskId );
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 1),
              content: Text('File Downloaded'.tr()),
              backgroundColor: Colors.green,
            )
        );
      }
    });
  }

  @override
  void initState() {
    refreshKeyHome = GlobalKey<RefreshIndicatorState>();
    _focus.addListener(_onFocusChange);
    // Listen for errors from controller if needed, via `ever` or just rely on Obx in build
    _getOrdersController.getOrders();

    _tabController = new TabController(vsync: this ,length: 4);
    // No need to call setState here, Obx handles rebuilds. But tab selection might need it for tab styling if not using controller state for tabs.
    _tabController!.addListener(_handleTabSelection);
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(Downloader.downloadCallback);

    super.initState();
  }

  void _handleTabSelection() {setState(() {});}

  Future<Null>? onRefreshAll(){
    _getOrdersController.getOrders();
    return null ;
  }
  @override
  Widget build(BuildContext context) {


    Size size = MediaQuery.of(context).size;
     screenWidth = size.width;
     screenHeight = size.height;
    return Scaffold(

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
                      padding: EdgeInsets.only(right: screenWidth!*0.03, left: screenWidth!*0.03),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Obx(() {
                              if (_getOrdersController.isLoading.value) {
                                return CreatMyOrdersScreen(
                                  getOrdersController: _getOrdersController,
                                  loading: true,
                                );
                              } else if (_getOrdersController.errorMessage.value != '') {
                                return ErrorView(
                                  retryAction: () {
                                    _getOrdersController.getOrders();
                                  },
                                  errorMessage: '',
                                );
                              } else {
                                // Loaded or empty (if null)
                                return CreatMyOrdersScreen(
                                  loading: false,
                                  getOrdersController: _getOrdersController,
                                );
                              }
                            }),
                          ),


                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          Expanded(child: HomeButton(isMyShipments: true,)),

        ],
      ),
      );

  }
  Widget CreatMyOrdersScreen({GetOrdersController? getOrdersController , required bool loading }){

    //for the search in all shipments according to id or receiver name
    // list 1 the list in the list view builder
    // dummySearchList is the all shipments list ya Roaa
    // dummyListData the list been filled according to the search box value
    void filterSearchResults(String query , List<OrdersDataModelMix> list1 , List<OrdersDataModelMix> list2   ) {
      List<OrdersDataModelMix> dummySearchList = [];
      dummySearchList.addAll(list2);
      if(query.isNotEmpty) {
        List<OrdersDataModelMix> dummyListData = [];
        dummySearchList.forEach((item) {
          if(item.id!.contains(query) || item.receiverName!.contains(query)) {
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

    ShipmentsListsModel? shipmentsModel = getOrdersController?.shipmentsListsModel.value;

    newOrdersList = shipmentsModel?.newShipments?.map((element)=>element).toList() ?? [];
    inDeliveryOrdersList = shipmentsModel?.inDeliveryShipments?.map((element)=>element).toList() ?? [];
    deliveredOrdersList = shipmentsModel?.deliveredShipments?.map((element)=>element).toList() ?? [];
    canceledOrdersList = shipmentsModel?.cancelShipments?.map((element)=>element).toList() ?? [];
    List<OrdersDataModelMix> allOrdersList = []..addAll(newOrdersList)..addAll(inDeliveryOrdersList)..addAll(deliveredOrdersList)..addAll(canceledOrdersList);

    // Update search lists if not searching (or first load)
    if (!showSearch) {
        allOrdersList1 = allOrdersList.map((element)=>element).toList();
        allOrdersList2 = allOrdersList.map((element)=>element).toList();
    }

    return Column(
      children: [
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.asset('assets/images/all shipments new.png', height: 40,),
                  // child: SvgPicture.asset(
                  //   "assets/images/box.svg",
                  //   placeholderBuilder: (context) => CustomLoading(),
                  //   height: 40.0,
                  // ),
                ),
                SizedBox(width: 9,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('My Shipments'.tr(),
                      style:TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        height: 0.5
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        getOrdersController?.shipmentsListsModel.value != null ?
                        Text(allOrdersList.length.toString(),
                          style:TextStyle(
                              fontSize: 15,
                              color: Constants.blueColor

                            // fontWeight: FontWeight.bold
                          ),
                        ) : Container(),
                        SizedBox(width: 5,),
                        Text('Shipment'.tr(),
                          style:TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Constants.blueColor
                          ),
                        ),
                      ],
                    ),
                  ],

                ),
                IconButton(icon: Icon(Icons.search , size: showSearch ? 35 : 25 , color: showSearch ? Constants.blueColor : Colors.grey  ,), onPressed: (){
                  setState(() {
                    showSearch = !showSearch ;
                    searchController.clear();
                    allOrdersList1.clear();
                    allOrdersList2.clear();
                    allOrdersList1 = allOrdersList.map((element)=>element).toList();
                    allOrdersList2 = allOrdersList.map((element)=>element).toList();
                  });
                })

              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
              
                onPressed: (){
                  if(SavedData.profileDataModel.permission == "1"){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddOrder(
                              resourcesData: widget.resourcesData,
                              dashboardDataModelNew:
                              widget.dashboardDataModel,
                              packagingType: "noPackaging",
                              getOrdersController: getOrdersController,
                            )));
                  }else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddOrderB2C(
                              resourcesData: widget.resourcesData,
                              dashboardDataModelNew:
                              widget.dashboardDataModel,
                              packagingType: "noPackaging",
                              getOrdersController: getOrdersController,
                            )));
                  }
                },
                child: Center(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AutoSizeText('New Shipment'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: screenWidth!*0.03),),
                )),


              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
        showSearch ?
        Padding(
          padding: EdgeInsets.only(left: 12, right:12 , top: 8 , bottom: 10),
          child: TextFormField(
              autofocus: true,
              onChanged: (value){
                filterSearchResults(value , allOrdersList1 , allOrdersList2 );
              },
              controller: searchController,
              decoration: kTextFieldDecoration2.copyWith(
                hintText: 'Search by id or receiver name'.tr(),
                suffixIcon: Icon(Icons.search , color:Constants.blueColor ,),
                focusedBorder:OutlineInputBorder(
                  borderSide: BorderSide(color: Constants.blueColor, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(23.0)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                hintStyle: TextStyle(fontSize: 14)

              )
          ),
        ) : Container(),
        !showSearch ? Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: screenWidth!*0.93,
              child: TabBar(
                  labelPadding: EdgeInsets.symmetric(horizontal: 1.0),
                  controller: _tabController,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Container(
                        width: screenWidth!*0.23,
                        height: screenHeight!*0.04,
                        decoration: BoxDecoration(
                            color: _tabController!.index == 0 ? Constants.blueColor : Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Constants.blueColor, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("New".tr() , style: TextStyle(color:_tabController!.index == 0 ?Colors.white : Constants.blueColor,fontSize: screenWidth!*0.025), ),
                              Text("(${newOrdersList.length.toString()})", style: TextStyle(color:_tabController!.index == 0 ?Colors.white : Constants.blueColor,fontSize: screenWidth!*0.025), ),
                            ],
                          ),

                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: screenWidth!*0.23,
                        height: screenHeight!*0.04,
                        decoration: BoxDecoration(
                            color: _tabController!.index == 1 ? Constants.blueColor : Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Constants.blueColor, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("In Delivery".tr() , style: TextStyle(color:_tabController!.index == 1 ?Colors.white : Constants.blueColor,fontSize: screenWidth!*0.025), ),
                              Text("(${inDeliveryOrdersList.length.toString()})", style: TextStyle(color:_tabController!.index == 1 ?Colors.white : Constants.blueColor,fontSize: screenWidth!*0.025), ),
                            ],
                          ),

                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: screenWidth!*0.23,
                        height: screenHeight!*0.04,

                        decoration: BoxDecoration(
                            color: _tabController!.index == 2 ? Color(0xFF56D340) : Colors.white,

                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Color(0xFF56D340), width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Delivered".tr(), style: TextStyle(color:_tabController!.index == 2 ?Colors.white: Color(0xFF56D340),fontSize: screenWidth!*0.025),),
                              Text("(${deliveredOrdersList.length.toString()})", style: TextStyle(color:_tabController!.index == 2 ?Colors.white: Color(0xFF56D340),fontSize: screenWidth!*0.025),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: screenWidth!*0.23,
                        height: screenHeight!*0.04,

                        decoration: BoxDecoration(
                            color: _tabController!.index == 3 ? Color(0xFFFF8A7B) : Colors.white,

                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Color(0xFFFF8A7B), width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Cancelled".tr(), style: TextStyle(color:_tabController!.index == 3 ? Colors.white:  Color(0xFFFF8A7B),fontSize: screenWidth!*0.025),),
                              Text("(${canceledOrdersList.length.toString()})", style: TextStyle(color:_tabController!.index == 3 ? Colors.white:  Color(0xFFFF8A7B),fontSize: screenWidth!*0.025),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ) : Container(),
        loading ?
        Expanded(

            child: Center(child: CustomLoading(),)): showSearch ?
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: allOrdersList1.length,
            itemBuilder: (context, i) {
              return OrdersCard(
                index: i,
                taskId: taskId,
                dashboardDataModel: widget.dashboardDataModel,
                resourcesData: widget.resourcesData,
                ordersDataModel: allOrdersList1[i],
                hasAction: true,
                getOrdersController: getOrdersController,
                showStatus: true,
                mixedShipmentsModel: shipmentsModel,
              );

            },
          ),
        ) :
        allOrdersList.length > 0 ?
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: TabBarView(
                controller: _tabController,

                children:[
                  newOrdersList.length > 0 ?
                  Column(

                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) ,
                              foregroundColor: Colors.white, // foreground
                            ),
                            onPressed: () {
                              if (Platform.isAndroid) {
                                Downloader.downloadPDFAndroid2( taskId , "https://portal.Fulgox.com/print_membervise/${SavedData.profileDataModel.id}" ,SavedData.profileDataModel.name ?? "" );
                              } else {
                                Downloader.downloadPDFIOS2(taskId , "https://portal.Fulgox.com/print_membervise/${SavedData.profileDataModel.id}" , SavedData.profileDataModel.name ?? "");
                              }
                            },
                            child: Text('Print All'.tr()),
                          ),
                        ],
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await onRefreshAll() ;
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: newOrdersList.length,
                            itemBuilder: (context, i) {
                              return OrdersCard(
                                index: i,
                                taskId: taskId,
                                dashboardDataModel: widget.dashboardDataModel,
                                resourcesData: widget.resourcesData,
                                ordersDataModel: newOrdersList[i],
                                hasAction: true,
                                mixedShipmentsModel: shipmentsModel,
                                getOrdersController: getOrdersController,
                              );

                            },
                          ),

                        ),
                      ),
                    ],
                  ) : RefreshIndicator(
                    onRefresh: () async {
                      await onRefreshAll() ;
                    },
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, i) {
                        return EmptyView();

                      },
                    ),
                  ),
                  inDeliveryOrdersList.length > 0 ?
                  RefreshIndicator(
                    key: refreshKeyHome ,
                    onRefresh: () async {
                      await onRefreshAll() ;
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: inDeliveryOrdersList.length,
                      itemBuilder: (context, i) {
                        return OrdersCard(
                          index: i,
                          taskId: taskId,
                          dashboardDataModel: widget.dashboardDataModel,
                          resourcesData: widget.resourcesData,
                          ordersDataModel: inDeliveryOrdersList[i],
                          hasAction: true,
                          mixedShipmentsModel: shipmentsModel,
                          getOrdersController: getOrdersController,
                        );
                      },
                    ),
                  ) :
                  RefreshIndicator(
                    onRefresh: () async {
                      await onRefreshAll(
                      ) ;
                    },
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, i) {
                        return EmptyView();

                      },
                    ),
                  ),
                  deliveredOrdersList.length > 0 ?
                  RefreshIndicator(
                    onRefresh: () async {
                      await onRefreshAll() ;
                    },
                    child: ListView.builder(
                      itemCount: deliveredOrdersList.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, i) {
                        return  OrdersCard(
                          index: i,
                          taskId: taskId,
                          dashboardDataModel: widget.dashboardDataModel,
                          resourcesData: widget.resourcesData,
                          ordersDataModel: deliveredOrdersList[i],
                          hasAction: false,
                          mixedShipmentsModel: shipmentsModel,
                          getOrdersController: getOrdersController,

                        );
                      },
                    ),
                  ) :
                  RefreshIndicator(
                    onRefresh: () async {
                      await onRefreshAll() ;
                    },
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, i) {
                        return EmptyView();

                      },
                    ),
                  ) ,
                  canceledOrdersList.length > 0 ?
                  RefreshIndicator(
                    onRefresh: () async {
                      await onRefreshAll() ;
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: canceledOrdersList.length,
                      itemBuilder: (context, i) {
                        return  OrdersCard(
                          index: i,
                          taskId: taskId,
                          dashboardDataModel: widget.dashboardDataModel,
                          resourcesData: widget.resourcesData,
                          ordersDataModel: canceledOrdersList[i],
                          hasAction: false,
                          mixedShipmentsModel: shipmentsModel,
                          getOrdersController: getOrdersController,

                        );
                      },
                    ),
                  ) :
                  RefreshIndicator(
                    onRefresh: () async {
                      await onRefreshAll() ;
                    },
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, i) {
                        return EmptyView();

                      },
                    ),
                  ),

                ]),
          ),
        ) :
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await onRefreshAll() ;
            },
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, i) {
                return EmptyView();

              },
            ),
          ),
        ) ,
      ],
    );

  }

}



//
//
// ),