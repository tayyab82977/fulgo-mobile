import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:Fulgox/data_providers/models/invoices_lists_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:Fulgox/controllers/invoices_controller.dart';
import 'package:Fulgox/data_providers/models/invoices_model.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/custom%20widgets/ErrorView.dart';
import 'package:Fulgox/ui/custom%20widgets/NetworkErrorView.dart';
import 'package:Fulgox/ui/custom%20widgets/drawerClient.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/downloader.dart';
import 'package:Fulgox/utilities/idToNameFunction.dart';

import '../../data_providers/models/savedData.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/home_button.dart';

class InvoicesScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  InvoicesScreen({this.resourcesData});
  @override
  _InvoicesScreenState createState() => _InvoicesScreenState();
}



class _InvoicesScreenState extends State<InvoicesScreen> with TickerProviderStateMixin {


  double? screenWidth , screenHeight , width , height ;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  double totalVat = 0 ;
  double totalAmount = 0 ;

  List<InvoicesModel> invoicesListType1 = [] ;
  List<InvoicesModel> invoicesListType2 = [] ;

  String totalInvoice = "" ;

  TabController? _tabController;
  void _handleTabSelection() {setState(() {});}

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  ReceivePort _port = ReceivePort();

  String localTaskId = "" ;
  int count = 0 ;

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String? id = data[0];
      localTaskId = id.toString();
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      print("invoice listener starts");

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
            FlutterDownloader.open(taskId: localTaskId );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File Downloaded'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }

    });
  }
    _tabController = new TabController(vsync: this ,length: 2);
    _tabController!.addListener(_handleTabSelection);
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(Downloader.downloadCallback);
    invoicesController.getInvoices();
    super.initState();
  }

  final InvoicesController invoicesController = Get.put(InvoicesController());

  String taskId = "" ;

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  void dispose() {
    _tabController?.dispose();
    _unbindBackgroundIsolate();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height ;
    width = size.width;
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
                        padding: EdgeInsets.only(right: screenWidth!*0.03, left: screenWidth!*0.03, ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Obx(() {
                                if (invoicesController.isLoading.value) {
                                  return CreateInvoicesScreen(loading: true, error: false);
                                }
                                
                                if (invoicesController.errorMessage.value.isNotEmpty) {
                                  String error = invoicesController.errorMessage.value;
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
                                        invoicesController.errorMessage.value = '';
                                      });
                                    });
                                  } else if (error == "invalidToken") {
                                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                                      GeneralHandler.handleInvalidToken(context);
                                    });
                                  } else if (error == 'needUpdate') {
                                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                                      GeneralHandler.handleNeedUpdateState(context);
                                    });
                                  } else if (error == "general") {
                                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                                        GeneralHandler.handleGeneralError(context);
                                      });
                                  }
                                  
                                  if (!invoicesController.isLoading.value && invoicesController.invoicesList.value == null) {
                                      return CreateInvoicesScreen(loading: false, error: true);
                                  }
                                }

                                if (invoicesController.invoicesList.value != null) {
                                  return CreateInvoicesScreen(
                                      loading: false,
                                      invoicesList: invoicesController.invoicesList.value,
                                      error: false);
                                }

                                return CreateInvoicesScreen(loading: true, error: false);
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
      );
  }
  Widget CreateInvoicesScreen({required bool loading , InvoicesListsModel? invoicesList , required bool error }){


    if(invoicesList != null){

    totalInvoice      = invoicesList.total.toString() ;
    invoicesListType1 = invoicesList.invoices!.map((e) => e).toList();
    invoicesListType2 = invoicesList.refundInvoice!.map((e) => e).toList();

    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth!*0.015),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/invoice.svg",
                    placeholderBuilder: (context) => CustomLoading(),
                    height: 38.0,
                    color: Constants.blueColor,
                  ),
                  SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Invoices'.tr(),
                        style:TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Constants.blueColor,
                        ),
                      ),
                      Row(
                        children: [
                          loading?
                          SizedBox(height: 5,):
                          Text( totalInvoice.toString() ,
                            style:TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              color: Constants.redColor,                            ),
                          ),

                          SizedBox(width: 5,),
                          Text('Invoice'.tr(),
                            style:TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              color: Constants.redColor,                            ),
                          ),
                        ],
                      ),
                    ],

                  )
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.all(5),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(("Amount".tr() + ": " + totalAmount.toString() )+" "+ "SR".tr(),style: TextStyle(fontSize: 14 ,color:  Colors.red.withOpacity(0.6) , fontWeight: FontWeight.w700),),
              //       Text(("VAT Amount".tr() + ": " + totalVat.toString() )+" "+ "SR".tr(),style: TextStyle(fontSize: 14 ,color:  Colors.grey , fontWeight: FontWeight.w700),),
              //
              //     ],
              //   ),
              // ),

            ],
          ),
        ),
        TabBar(
            controller: _tabController,
            labelColor: Constants.blueColor,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                child: Container(
                  width: 160,
                  height: 35,
                  decoration: BoxDecoration(
                      color: _tabController?.index == 0 ?  Constants.blueColor : Colors.white ,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Constants.blueColor, width: 1)),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Invoice".tr() , style: TextStyle(color: _tabController?.index == 0 ? Colors.white : Constants.blueColor,fontSize: 14), ),
                        Flexible(child: AutoSizeText(loading? " (0)": " (${invoicesListType1.length.toString()})" ,
                          maxLines: 1,
                          minFontSize: 9,
                          maxFontSize: 14,
                          style: TextStyle(color:  _tabController?.index == 0 ? Colors.white : Constants.blueColor,fontSize: 14), )),
                      ],
                    ),

                  ),
                ),
              ),
              Tab(
                child: Container(
                  width: 160,
                  height: 35,
                  decoration: BoxDecoration(
                      color: _tabController?.index == 1 ?  Constants.blueColor : Colors.white ,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Constants.blueColor, width: 1)),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Refund Invoices".tr() , style: TextStyle(color: _tabController?.index == 1 ? Colors.white : Constants.blueColor,fontSize: 14), ),
                        Flexible(child: AutoSizeText(loading? " (0)": " (${invoicesListType2.length.toString()})",
                          maxLines: 1,
                          minFontSize: 9,
                          maxFontSize: 14,
                          style: TextStyle(color:  _tabController?.index == 1 ? Colors.white : Constants.blueColor,fontSize: 14), )),
                      ],
                    ),

                  ),
                ),
              ),

            ]),
        !loading?
        Expanded(
          child: Padding(
            padding:EdgeInsets.only(top: 15 ,left:screenWidth!*0.015 , right:screenWidth!*0.015 ),
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ElevatedButton(
                    //   //     color: Constants.blueColor, //
                    //     foregroundColor: Colors.white, // foreground
                    //   ,
                    //   onPressed: () {
                    //     taskId = getRandomString(10);
                    //     if (Platform.isAndroid) {
                    //       Downloader.downloadPDFAndroid2( taskId , "https://portal.Fulgox.com/print_membervise/${SavedData.profileDataModel.id}" ,SavedData.profileDataModel.name ?? "" );
                    //     } else {
                    //       Downloader.downloadPDFIOS2(taskId , "https://portal.Fulgox.com/print_membervise/${SavedData.profileDataModel.id}" , SavedData.profileDataModel.name ?? "");
                    //     }
                    //     // if (Platform.isAndroid) {
                    //     //   Downloader.downloadPDFAndroid2(localTaskId , "https://portal.Fulgox.com/cbjjsuy728fHnki/${widget.invoicesModel.id}" , "${widget.invoicesModel .name}");
                    //     // } else {
                    //     //   Downloader.downloadPDFIOS2(localTaskId , "https://portal.Fulgox.com/cbjjsuy728fHnki/${widget.invoicesModel.id}" , "${widget.invoicesModel .name}");
                    //     // }
                    //   },
                    //   child: Text('Print All'.tr()),
                    // ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: ()async{
                          invoicesController.getInvoices();
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: invoicesListType1.length,
                          itemBuilder:(context , i){
                            return IncoivceCard(invoicesModel: invoicesListType1[i],);
                          } ,
                        ),
                      ),
                    ),
                  ],
                ),
                RefreshIndicator(
                  onRefresh: ()async{
                    invoicesController.getInvoices();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: invoicesListType2.length,
                    itemBuilder:(context , i){
                      return IncoivceCard(invoicesModel: invoicesListType2[i],);
                    } ,
                  ),
                ),
              ],
            )
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
              invoicesController.getInvoices();
            },
          ),
        ): Container()


      ],
    );
  }

}


class IncoivceCard extends StatefulWidget {
  InvoicesModel invoicesModel ;
  String? taskId ;
  IncoivceCard({required this.invoicesModel , this.taskId});
  @override
  _IncoivceCardState createState() => _IncoivceCardState();
}

class _IncoivceCardState extends State<IncoivceCard> {



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.invoicesModel.name ?? "",style: TextStyle(fontSize: 14 ,),),
                  SizedBox(width: 10,),
                  Text( "Amount".tr() + ": " + (widget.invoicesModel.totalAmount ?? "" )+" "+ "SR".tr(),style: TextStyle(fontSize: 14 ,color: (double.tryParse(widget.invoicesModel .totalAmount) ?? 0 )> 0 ? Colors.green : Colors.red , fontWeight: FontWeight.w700),),
                  Text(("VAT".tr() + ": " + widget.invoicesModel.totalVat )+" "+ "SR".tr(),style: TextStyle(fontSize: 12 ,color: (double.tryParse(widget.invoicesModel .totalAmount) ?? 0 )> 0 ? Colors.grey : Colors.grey , fontWeight: FontWeight.w700),),
                ],
              ),

              widget.invoicesModel.statusDownload == DownloadTaskStatus.enqueued ||  widget.invoicesModel.statusDownload == DownloadTaskStatus.running ?
              CustomLoading() :
              IconButton(onPressed: (){
                if (Platform.isAndroid) {
                  Downloader.downloadPDFAndroid2("${widget.taskId}" , "https://portal.Fulgox.com/cbjjsuy728fHnki/${widget.invoicesModel.id}" , "${widget.invoicesModel .name}");
                } else {
                  Downloader.downloadPDFIOS2("${widget.taskId}" , "https://portal.Fulgox.com/cbjjsuy728fHnki/${widget.invoicesModel.id}" , "${widget.invoicesModel .name}");
                }
              }, icon: Icon(Icons.print , color: Constants.blueColor,))
            ],
          ),
        ),
      ),
    );
  }
}


