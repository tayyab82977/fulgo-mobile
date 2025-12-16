import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';

import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/clientPayments_bloc.dart';
import 'package:xturbox/blocs/bloc/dashboard_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/clientPayments_events.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/blocs/states/clientPayments_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/drawerClient.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/custom%20widgets/transactionsCard.dart';
import 'package:xturbox/ui/common/dashboard.dart';

import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/downloader.dart';

import '../../data_providers/models/memberBalanceModel.dart';
import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/home_button.dart';

class ClientPaymentsScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  // DashboardDataModel dashboardDataModel;
  ClientPaymentsScreen({this.resourcesData});

  @override
  _ClientPaymentsScreenState createState() => _ClientPaymentsScreenState();
}

class _ClientPaymentsScreenState extends State<ClientPaymentsScreen> {
  double? screenWidth, screenHeight, width, height;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  UserRepository userRepository = UserRepository();

  String? dateDays ;
  String? dateMonth ;
  String? dateYear ;
  int? timeH ;
  String? timeM ;
  String? AMPM;


  String localTaskId = "" ;

  gettingDate(String? stamp){
    try{
      timeM = stamp.toString().substring(14, 16);
      timeH = int.tryParse(
          stamp.toString().substring(11, 13));
    }catch(e){
      timeH = 0 ;

    }

    if(timeH! > 12 ){
      timeH = timeH! - 12 ;
      AMPM = "pm".tr();

    }else if (timeH == 12){
      AMPM = "pm".tr();
    }else if (timeH == 0){
      timeH = timeH! + 12 ;
      AMPM = "am".tr();
    }else{
      AMPM = 'am'.tr();
    }

  }
  ReceivePort _port = ReceivePort();

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
 ScrollController offersScroll = ScrollController();
 ScrollController packageOffersScroll = ScrollController();
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
      localTaskId = id.toString()  ;
      setState(() {});
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];


      if (status == DownloadTaskStatus.complete) {
        Future.delayed(Duration(seconds: 2), () {
          FlutterDownloader.open(taskId: localTaskId.toString());
        });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File Downloaded'.tr()),
                backgroundColor: Colors.green,
              )
          );
      }
    });
  }

  @override
  void initState() {
    FlutterDownloader.registerCallback(Downloader.downloadCallback);
    _bindBackgroundIsolate();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return BlocProvider(
      create: (context)=> ClientPaymentsBloc()..add(GetClintPayments()),
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
                      child: Padding(
                        padding: EdgeInsets.only(right: screenWidth!*0.03, left: screenWidth!*0.03, top: screenHeight!*0.01 ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10,),
                            Expanded(
                                child: BlocConsumer<ClientPaymentsBloc , ClientPaymentsStates>(
                                    builder: (context , state){
                                      if (state is ClientPaymentsLoading){
                                        return CreatPaymentsScreen(loading: true,clientPaymentsBloc: BlocProvider.of<ClientPaymentsBloc>(context));
                                      }

                                      if (state is ClientPaymentsLoaded){
                                        return CreatPaymentsScreen(loading: false , clientPaymentsLoaded: state,clientPaymentsBloc: BlocProvider.of<ClientPaymentsBloc>(context));
                                      }
                                      else if (state is ClientPaymentsError){
                                        return ErrorView(
                                          retryAction:(){
                                            BlocProvider.of<ClientPaymentsBloc>(context).add(GetClintPayments());
                                          },
                                          errorMessage: '',
                                        );
                                      }

                                     return CreatPaymentsScreen(loading: true,clientPaymentsBloc: BlocProvider.of<ClientPaymentsBloc>(context));
                                    },
                                    listener: (context , state){
                                      if(state is ClientPaymentsError ){
                                        if (state.error == "TIMEOUT"){
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
                                      else if (state is ClientPaymentsLoaded){
                                        try{
                                          gettingDate(state.paymentsAndProfile!.dashboardDataModel!.lastWithdraw!.stamp);
                                        }catch(e){}

                                      }
                                    }
                                    ),
                            ),

                          ],
                        ),
                      ),
                    ),
                ),

              ],
            ),
          ),
          Expanded(child: HomeButton()),

        ],
      ),
    ));
  }
  Widget CreatPaymentsScreen({ required bool loading , ClientPaymentsLoaded? clientPaymentsLoaded ,required ClientPaymentsBloc clientPaymentsBloc } ){
    return
      loading ? Column(
        children: [
          Expanded(

            child: Center(
              child: CustomLoading(),

            ),
          ),
        ],
      ):
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/wallet.svg",
                  placeholderBuilder: (context) => CustomLoading(),
                  height: 38.0,
                  color: Constants.blueColor,
                ),
                SizedBox(width: 15,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Payments'.tr(),
                      style:TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Constants.blueColor,
                      ),
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
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: screenWidth!*0.45,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: EdgeInsets.only( bottom: 2 ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth!*0.45 ,
                      height: screenHeight!*0.04,
                      decoration: BoxDecoration(
                          color: Constants.blueColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft:Radius.circular(20))

                      ),
                      child: Center(
                          child: Text('Balance'.tr(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth!*0.04,
                                fontWeight: FontWeight.w400
                            ),
                          )),
                    ),
                    SizedBox(height: 4,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Collected Amount".tr(),style: TextStyle(fontSize: screenWidth!*0.04),),
                              SizedBox(width: 3,),
                              AutoSizeText(((clientPaymentsLoaded!.paymentsAndProfile?.dashboardDataModel?.amount.toString()) ?? "") + " " +'SR'.tr() ,
                                // AutoSizeText('',
                                maxLines: 2,
                                maxFontSize: 18,
                                minFontSize: 11,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Wallet".tr(),style: TextStyle(fontSize: screenWidth!*0.04),),
                              SizedBox(width: 3,),
                              Text(" :"),
                              SizedBox(width: 3,),
                              Expanded(
                                child: AutoSizeText(((clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.wallet.toString()) ?? "") + " " +'SR'.tr() ,
                                  // AutoSizeText('',
                                  maxLines: 2,
                                  maxFontSize: 18,
                                  minFontSize: 11,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(height: screenHeight*0.005,),


                  ],
                ),
              ),
            ),
            Container(
              width: screenWidth!*0.45,
              height: 160,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: EdgeInsets.only( bottom: 2 ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth!*0.45 ,
                      height: screenHeight!*0.04,
                      decoration: BoxDecoration(
                          color:  Constants.redColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft:Radius.circular(20))

                      ),
                      child: Center(
                          child: Text('P.Offers'.tr(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth!*0.04,
                                fontWeight: FontWeight.w400
                            ),
                          )),
                    ),
                    clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.packageOffer?.isNotEmpty ?? false || (clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.offer?.isNotEmpty ?? false ) ?
                    Expanded(
                      child: Column(
                        children: [
                          clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.packageOffer?.isNotEmpty ?? false ?
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Scrollbar(
                                controller:packageOffersScroll ,
                                thickness: 5,
                                isAlwaysShown: true,
                                child: ListView.builder(
                                  controller: packageOffersScroll,
                                  padding: EdgeInsets.zero,
                                  itemCount: clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.packageOffer?.length,
                                  itemBuilder: (context , i){
                                    return buildOffersCard(clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.packageOffer?.elementAt(i));
                                  },
                                ),
                              ),
                            ),
                          ):SizedBox(),
                          clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.offer?.isNotEmpty ?? false ?
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Scrollbar(
                                controller: offersScroll,
                                child: ListView.builder(
                                  controller: offersScroll,
                                  padding: EdgeInsets.zero,
                                  itemCount: clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.offer?.length,
                                  itemBuilder: (context , i){
                                    return buildOffersCard2(clientPaymentsLoaded.paymentsAndProfile!.dashboardDataModel!.offer!.elementAt(i));
                                  },
                                ),
                              ),
                            ),
                          ):SizedBox(),
                        ],
                      ),
                    ) : Expanded(
                      child: Center(child: Text('No Offers'.tr(),style: TextStyle(fontSize: screenWidth!*0.04))),
                    ),

                    // Text('10 - 15 KG'.tr(),
                    //   style: TextStyle(
                    //       color: Colors.grey,
                    //       fontSize: 12
                    //   ),
                    //
                    // ),


                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10,),
        clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.lastWithdraw?.amount.toString() != "0" ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last transfer process'.tr(),
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18
              ),
            ),
            SizedBox(height: 5,),
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                // color: amount > 0 ? Color(0xFF56D340) : amount < 0 ? Colors.red : Colors.white ,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Value'.tr(), style: TextStyle(fontSize: screenWidth!*0.04)),
                        Text(':', style: TextStyle(fontSize: screenWidth!*0.04)),
                        SizedBox(width: 3,),
                        Text(clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.lastWithdraw?.amount.toString() ?? ""
                            , style: TextStyle(fontSize: screenWidth!*0.04,fontWeight: FontWeight.w800)
                        ),
                        SizedBox(width: 2,),
                        Text("SR".tr(),style: TextStyle(fontSize: screenWidth!*0.03)),
                      ],
                    ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(clientPaymentsLoaded.paymentsAndProfile?.dashboardDataModel?.lastWithdraw?.stamp.toString().substring(0,10) ?? ""
                                , style: TextStyle(fontSize: screenWidth!*0.03,fontWeight: FontWeight.w600,)
                            ),
                            SizedBox(width: 5,),
                            Text('$timeH:$timeM',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth!*0.03
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(AMPM??''.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth!*0.03
                              ),
                            ),
                          ],
                        )

                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ) : Container(),
        SizedBox(height: screenHeight!*0.02,),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transaction History'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18
            ),
            ),
            FlatButton(
              height: 30,
              color:Constants.blueColor ,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.all(0),
              highlightColor: Colors.black,
              onPressed: (){
                _printReportDialog(context);
              },
              child: Center(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8 , vertical: 5),
                child: AutoSizeText('Print Report'.tr(),
                  style: TextStyle(color: Colors.white, fontSize: 14),),
              )),


            ),
          ],
        ),
        SizedBox(height: 5,),
        // payments list
        Expanded(
            child: RefreshIndicator(
              onRefresh: ()async{
                clientPaymentsBloc.add(GetClintPayments());
              },
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: clientPaymentsLoaded.paymentsAndProfile!.clientPaymentsDataList!.length,
                  itemBuilder: (context , i ){
                    return TransactionsCard(
                      clientPaymentsDataModel:clientPaymentsLoaded.paymentsAndProfile!.clientPaymentsDataList![i] ,
                      resourcesData: widget.resourcesData,
                    );
                  }),
            )
        ),

      ],
    );
  }
  Widget buildOffersCard(PackageOffer? offers){
    return Container(
      child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(""),
          Text(offers?.weight ?? "", style: TextStyle(fontSize: screenWidth!*0.028),),
          SizedBox(width: screenWidth!*0.01,),
          Text(offers?.distance ?? "" , style: TextStyle(fontSize: screenWidth!*0.028),),
          SizedBox(width: screenWidth!*0.01,),
          Text(":"),
          SizedBox(width: screenWidth!*0.01,),
          AutoSizeText(offers?.count ?? '',
            // AutoSizeText('',
            style: TextStyle(
                fontSize: screenWidth!*0.045,
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(width: screenWidth!*0.01,),
          AutoSizeText('package'.tr(),
            minFontSize: 4,
            maxFontSize: 6,
            style: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth!*0.021,
            ),

          ),
        ],
      ),
    );
  }
  Widget buildOffersCard2(DistanceOffer offers){
    return Container(
      child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(""),
          Text(offers.distance ?? "" , style: TextStyle(fontSize: screenWidth!*0.028),),
          SizedBox(width: screenWidth!*0.01,),
          Text(":"),
          SizedBox(width: screenWidth!*0.01,),
          AutoSizeText(offers.count ?? '',
            // AutoSizeText('',
            style: TextStyle(
                fontSize: screenWidth!*0.045,
                fontWeight: FontWeight.w500
            ),
          ),
          SizedBox(width: screenWidth!*0.01,),
          AutoSizeText('package'.tr(),
            minFontSize: 4,
            maxFontSize: 6,
            style: TextStyle(
              color: Colors.grey,
              fontSize: screenWidth!*0.021,
            ),

          ),
        ],
      ),
    );
  }
  _printReportDialog(BuildContext context){
    DateTime fromTime = DateTime.now() ;
    DateTime toTime = DateTime.now() ;
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    // _bindBackgroundIsolate();
    // FlutterDownloader.registerCallback(Downloader.downloadCallback);


    showDialog(
        context: context,
        // barrierDismissible: true,
        builder: (context) {

          return StatefulBuilder(
            builder: (context , setState2 ){
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                titlePadding: EdgeInsets.all(0),
                title: Container(
                    height: 60.00,
                    width: 300.00,
                    decoration: BoxDecoration(
                      color: Constants.blueColor,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                    ),
                    child: Center(
                      child: Text('Financial Report'.tr(),
                          style: TextStyle(color: Colors.white)),
                    )
                ),

                content: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 10,),
                                Text(
                                  'From'.tr() + ': ',
                                  style: TextStyle(fontSize: 14, color: Colors.black87,height: 0.7),
                                ),
                                Expanded(
                                  child: DateTimeFormField(
                                    decoration: kTextFieldDecoration.copyWith(
                                      hintText: '',
                                      suffixIcon: Icon(Icons.event_note, color: Constants.blueColor,),

                                    ),
                                    mode: DateTimeFieldPickerMode.date,
                                    dateFormat:DateFormat('yyyy-MM-dd') ,
                                    lastDate: DateTime.now(),
                                    onDateSelected: (DateTime value) {
                                      fromTime = value ;
                                    },
                                    onSaved: (value) {
                                      fromTime = value ?? DateTime.now() ;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 10,),
                              Text(
                                'To'.tr() + ': ',
                                style: TextStyle(fontSize: 14, color: Colors.black87,height: 0.7),
                              ),
                              Expanded(
                                child: DateTimeFormField(
                                  decoration: kTextFieldDecoration.copyWith(
                                    hintText: '',
                                    suffixIcon: Icon(Icons.event_note, color: Constants.blueColor,),

                                  ),
                                  mode: DateTimeFieldPickerMode.date,
                                  dateFormat:DateFormat('yyyy-MM-dd') ,
                                  lastDate: DateTime.now(),
                                  onDateSelected: (DateTime value) {
                                    toTime = value ;
                                  },
                                  onSaved: (value) {
                                    toTime = value ?? DateTime.now() ;
                                  },
                                ),
                              ),

                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Constants.blueColor, // background
                              onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                            ),
                            onPressed: () {
                              setState2(() {});
                              if (Platform.isAndroid) {
                                Downloader.downloadPDFAndroid2(localTaskId.toString() , "https://portal.xturbox.com/Tq8zYcZfaW232HqwQqwerT/${formatter.format(fromTime)}/hjljl/${formatter.format(toTime)}/hsahkjk/${SavedData.profileDataModel.id}" , "report");
                              } else {
                                Downloader.downloadPDFIOS2(localTaskId.toString() , "https://portal.xturbox.com/Tq8zYcZfaW232HqwQqwerT/${formatter.format(fromTime)}/hjljl/${formatter.format(toTime)}/hsahkjk/${SavedData.profileDataModel.id}" , "report");
                              }
                              // Navigator.of(context).pop();
                            },
                            child: Text('Print'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              },
          );

        });
  }

}
