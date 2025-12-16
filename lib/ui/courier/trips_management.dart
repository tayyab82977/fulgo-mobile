import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart'as mv;
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:xturbox/blocs/bloc/addTrip_bloc.dart';
import 'package:xturbox/blocs/bloc/tripHistory_bloc.dart';
import 'package:xturbox/blocs/bloc/trips_bloc.dart';
import 'package:xturbox/blocs/events/addTrip_events.dart';
import 'package:xturbox/blocs/events/tripHistory_events.dart';
import 'package:xturbox/blocs/events/trips_events.dart';
import 'package:xturbox/blocs/states/addTrip_states.dart';
import 'package:xturbox/blocs/states/tripHistory_states.dart';
import 'package:xturbox/blocs/states/trips_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/tripModel.dart';
import 'package:xturbox/ui/courier/captainMyPickup.dart';
import 'package:xturbox/ui/custom%20widgets/CaptainAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/ui/custom%20widgets/drawerCaptain.dart';
import 'package:xturbox/ui/custom%20widgets/drawerDriver.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';

import 'list_tiles/trip_history_card.dart';


class TripsManagementScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  TripsManagementScreen({this.resourcesData});
  @override
  _TripsManagementScreenState createState() => _TripsManagementScreenState();
}

class _TripsManagementScreenState extends State<TripsManagementScreen> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  double? screenWidth , screenHeight , width , height ;
  TabController? _tabController;


  @override
  void initState() {
    _tabController = new TabController(vsync: this ,length: 2);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context)=>AddTripBloc(),),
        BlocProvider(create: (context)=>TripsBloc()..add(GetTrip())),
        BlocProvider(create: (context)=>TripHistoryBloc()..add(GetTripHistory())),
      ],
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Constants.greyColor,
        drawer: DriverDrawer(
          width: screenWidth,
          height: screenHeight,
          resourcesData: widget.resourcesData,
        ),
        body: Column(
          children: [
            CaptainAppBar(
              drawerKey: _drawerKey, screenName: 'Trips Management'.tr(),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: BlocConsumer<TripsBloc , TripsStates>(
                  builder: (context , state){
                    if(state is TripsLoading){
                      return CustomLoading();
                    }
                    if(state is TripsError){
                      return ErrorView(
                        errorMessage: "Something went wrong please try again",
                        retryAction: (){
                          BlocProvider.of<TripsBloc>(context).add(GetTrip());
                        },
                      );
                    }
                    if(state is TripsLoaded){
                      return Column(
                        children: [
                          TabBar(
                              controller: _tabController,
                              labelColor: Constants.blueColor,
                              indicatorColor: Constants.blueColor,

                              tabs: [
                                Tab(text: "Add".tr(),),
                                Tab(text: "History".tr(),),
                              ]),
                          SizedBox(height: 10,),
                          Expanded(
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                  AddTrip(resourcesData: widget.resourcesData,tabController: _tabController, tripModel: state.tripModel,),
                                  TripHistoryTap(resourcesData: widget.resourcesData, )
                                ]),
                          )
                        ],
                      );
                    }
                    return CustomLoading();
                  },
                  listener: (context , state){
                    if(state is TripsError){
                      state.errorList?.forEach((element) {
                        ComFunctions.showToast(text:element , color: Colors.red);

                      });
                    }

                  }),
            ),


          ],
        ),
      ),
    );
  }
}


class AddTrip extends StatefulWidget {
  ResourcesData? resourcesData ;
  TabController? tabController ;
  TripModel? tripModel ;
  bool newTrip = false ;
  AddTrip({this.resourcesData,this.tabController,this.tripModel , this.newTrip = false});
  @override
  _AddTripState createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  final originCitySearchController = TextEditingController();
  final destinationCitySearchController = TextEditingController();
  final _valueController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  double? screenWidth , screenHeight , width , height ;

  ErCity? _currentOriginCity ;
  ErCity? _currentDestinationCity ;

  // int? _cameraOcr = mv.FlutterMobileVision.CAMERA_BACK;
  // mv.Size? _previewOcr;
  // String testText = '' ;
  // List<mv.OcrText> texts = [];


  @override
  void initState() {
    // mv.FlutterMobileVision.start().then((previewSizes) => setState(() {
    //   _previewOcr = previewSizes[_cameraOcr]!.first;
    // }));

    super.initState();
  }



  String originCity = "";
  String destinationCity = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;



    if(widget.tripModel?.id != "null"){

      originCity = IdToName.idToName("city", widget.tripModel?.origin.toString() ?? "") ?? "";
      destinationCity = IdToName.idToName("city", widget.tripModel?.destination.toString() ?? "") ?? "";

    }

    _showScanBtn(){
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary:Colors.white, // background
          onPrimary: Constants.blueColor , // foreground
        ),
        onPressed: () async{

          // try {
          //   texts = await mv.FlutterMobileVision.read(
          //       flash: false,
          //       autoFocus: true,
          //       multiple: false,
          //       showText: true,
          //       preview: _previewOcr!,
          //       scanArea: mv.Size( 800,300),
          //       fps: 5.0,
          //       forceCloseCameraOnTap: true,
          //       waitTap: true
          //   );
          //   for(mv.OcrText text in texts){
          //     print(text.value);
          //     if(text.value.isNotEmpty){
          //       setState(() {
          //         _valueController.text = texts[0].value;
          //       });
          //     }
          //   }
          //
          // } on Exception {
          //   texts.add(new mv.OcrText('Failed to recognize text.'));
          // }
        },
        child: Row(
          children: [
            Icon(Icons.camera_alt,size: 14,),
            SizedBox(width: 4,),
            Text('Scan'.tr()),
          ],
        ),
      );
    }

    return ProgressHUD(
      barrierEnabled: false,
      backgroundColor: Constants.blueColor,
      child:widget.tripModel?.id == "null" ?
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocListener<AddTripBloc , AddTripStates>(
          listener: (context , state){
            if(state is AddTripLoading){
              final progress = ProgressHUD.of(context);
              progress?.show();
            }else{
              final progress = ProgressHUD.of(context);
              progress?.dismiss();
            }
            if(state is AddTripAdded){
              ComFunctions.showToast(text: 'Done'.tr(),color: Colors.green);
              BlocProvider.of<TripsBloc>(context).add(GetTrip());

            }
            if(state is AddTripError){
              state.errorList?.forEach((element) {
                ComFunctions.showToast(text:element , color: Colors.red);

              });
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Constants.blueColor,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text('Origin city'.tr(),style: TextStyle(color: Colors.white,fontSize: 15),),
                            SizedBox(height: 10,),
                            DropdownSearch<ErCity?>(
                              dropdownSearchDecoration: kTextFieldDecoration2.copyWith(
                                  hintText: "Origin city".tr(),
                                  labelStyle: TextStyle(color: Colors.black )
                              ),
                              searchBoxDecoration: kTextFieldDecoration.copyWith(
                                  hintText: "City name ..".tr(),
                                  suffixIcon: Icon(Icons.search)
                              ),
                              label: "",
                              items: widget.resourcesData?.city,
                              searchBoxController: originCitySearchController,
                              maxHeight: screenHeight!*0.8,
                              showSearchBox: true,
                              selectedItem: _currentOriginCity ,
                              itemAsString: (ErCity? u) => u!.name ?? "",
                              emptyBuilder: (context , string){
                                return Center(child: Text('No results'.tr()));
                              },
                              mode:Mode.BOTTOM_SHEET ,
                              enabled: true,
                              onChanged: (value){
                                setState(() {
                                  _currentOriginCity = value;
                                  originCitySearchController.clear();
                                });
                              },
                              clearButton: Icon(Icons.close),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenWidth!*0.5,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _valueController,
                                    onChanged: (value){
                                      setState(() {
                                        // _counter = int.tryParse(value) ?? 0 ;
                                      });
                                    },
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(7),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'please enter the value'.tr();
                                      }
                                      return null;
                                    },
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'Km'.tr(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15,),
                                _showScanBtn()

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),
                    Icon(Icons.arrow_downward_sharp , size: 30,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: Constants.blueColor,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Destination city'.tr(),style: TextStyle(color: Colors.white,fontSize: 15),),
                            SizedBox(height: 10,),
                            DropdownSearch<ErCity?>(
                              dropdownSearchDecoration: kTextFieldDecoration2.copyWith(
                                  hintText: "Destination city".tr(),
                                  labelStyle: TextStyle(color: Colors.black )
                              ),
                              searchBoxDecoration: kTextFieldDecoration.copyWith(
                                  hintText: "City name ..".tr(),
                                  suffixIcon: Icon(Icons.search)
                              ),
                              label: "",
                              items: widget.resourcesData?.city,
                              searchBoxController: originCitySearchController,
                              maxHeight: screenHeight!*0.8,
                              showSearchBox: true,
                              selectedItem: _currentDestinationCity ,
                              itemAsString: (ErCity? u) => u!.name ?? "",
                              emptyBuilder: (context , string){
                                return Center(child: Text('No results'.tr()));
                              },
                              mode:Mode.BOTTOM_SHEET ,
                              enabled: true,
                              onChanged: (value){
                                setState(() {
                                  _currentDestinationCity = value;
                                  originCitySearchController.clear();
                                });
                              },
                              clearButton: Icon(Icons.close),
                            ),
                            SizedBox(height: 5,),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary:Constants.blueColor , // background
                        onPrimary: Colors.white , // foreground
                      ),
                      onPressed: () {
                        if(_formKey.currentState!.validate()){
                           BlocProvider.of<AddTripBloc>(context).add(AddNewTrip(
                             tripModel: TripModel(
                               origin: _currentOriginCity?.id,
                               destination: _currentDestinationCity?.id,
                               start: _valueController.text
                             )
                           ));
                        }
                      },
                      child: Text('Save'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ) :
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocListener<AddTripBloc , AddTripStates>(
          listener: (context , state){
            if(state is AddTripLoading){
              final progress = ProgressHUD.of(context);
              progress?.show();
            }else{
              final progress = ProgressHUD.of(context);
              progress?.dismiss();
            }
            if(state is AddTripError){
              state.errorList?.forEach((element) {
                ComFunctions.showToast(text:element , color: Colors.red);

              });
            }
            if(state is AddTripUpdated){
              ComFunctions.showToast(text:'Done'.tr(),color: Colors.green);
              BlocProvider.of<TripHistoryBloc>(context).add(GetTripHistory());
              BlocProvider.of<TripsBloc>(context).add(GetTrip());
              widget.tabController?.animateTo(1);
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Constants.blueColor,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text('Origin city'.tr(),style: TextStyle(color: Colors.white,fontSize: 15),),
                            SizedBox(height: 10,),
                            Text(originCity,style: TextStyle(color: Colors.white,fontSize: 15),),
                            SizedBox(height: 5,),
                            Text(widget.tripModel?.start ?? "",style: TextStyle(color: Colors.white,fontSize: 15),),


                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),
                    Icon(Icons.arrow_downward_sharp , size: 30,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: Constants.blueColor,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text('Destination city'.tr(),style: TextStyle(color: Colors.white,fontSize: 15),),
                            SizedBox(height: 10,),
                            Text(destinationCity,style: TextStyle(color: Colors.white,fontSize: 15),),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenWidth!*0.5,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _valueController,
                                    onChanged: (value){
                                      setState(() {
                                        // _counter = int.tryParse(value) ?? 0 ;
                                      });
                                    },
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(7),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'please enter the value'.tr();
                                      }
                                      return null;
                                    },
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'Km'.tr(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15,),
                                _showScanBtn()

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary:Colors.white , // background
                        onPrimary: Constants.blueColor, // foreground
                      ),
                      onPressed: () {
                        if(_formKey.currentState!.validate()){
                          BlocProvider.of<AddTripBloc>(context).add(UpdateTripEnd(
                              tripModel: TripModel(
                                  id: widget.tripModel?.id,
                                  end: _valueController.text
                              )
                          ));
                        }
                      },
                      child: Text('Save'.tr()),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      )
      ,
    );
  }
}


class TripHistoryTap extends StatefulWidget {
  ResourcesData? resourcesData ;
  TripHistoryTap({this.resourcesData});
  @override
  _TripHistoryTapState createState() => _TripHistoryTapState();
}

class _TripHistoryTapState extends State<TripHistoryTap> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripHistoryBloc , TripHistoryStates>(
      builder: (context , state){
        if(state is TripHistoryLoaded){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: RefreshIndicator(
              onRefresh: ()async{
                BlocProvider.of<TripHistoryBloc>(context).add(GetTripHistory());
              },
              child: ListView.builder(
                  itemCount: state.list.length,
                  itemBuilder: (context , i ){
                    return TripHistoryCard(
                      tripModel: state.list[i],
                    );
                  }),
            ),
          );
        }
        return CustomLoading();
      },
      listener: (context , state){

        if(state is TripHistoryError){
          state.errorList?.forEach((element) {
            ComFunctions.showToast(text:element , color: Colors.red);

          });
        }
      },
    );
  }
}
