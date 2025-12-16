import 'package:date_field/date_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:xturbox/blocs/bloc/carServiceHistory_bloc.dart';
import 'package:xturbox/blocs/bloc/postCarServices_bloc.dart';
import 'package:xturbox/blocs/events/carServiceHistory_events.dart';
import 'package:xturbox/blocs/events/postCarServices_events.dart';
import 'package:xturbox/blocs/states/carServiceHistory_states.dart';
import 'package:xturbox/blocs/states/postCarServices_states.dart';
import 'package:xturbox/data_providers/models/fuel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/courier/list_tiles/service_history_card.dart';
import 'package:xturbox/ui/custom%20widgets/CaptainAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/customCheckBox.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/ui/custom%20widgets/drawerCaptain.dart';
import 'package:xturbox/ui/custom%20widgets/drawerDriver.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/comFunctions.dart';



class CarServicesScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  
  CarServicesScreen({this.resourcesData});
  @override
  _CarServicesScreenState createState() => _CarServicesScreenState();
}

class _CarServicesScreenState extends State<CarServicesScreen>  with TickerProviderStateMixin {
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
        BlocProvider(create: (context)=>PostCarSrvBloc(),),
        BlocProvider(create: (context)=>CarSrvHistoryBloc()..add(GetCarSrvHistory()),)
      ],
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Constants.greyColor,
        drawer:
        SavedData.profileDataModel.permission.toString() == "4" ?
        CaptainDrawer(
          resourcesData: widget.resourcesData,
        ) : DriverDrawer(
          resourcesData: widget.resourcesData,
        ),
        body: Column(
          children: [
            CaptainAppBar(
              drawerKey: _drawerKey, screenName: 'Car Services'.tr(),
            ),
            SizedBox(height: 10,),
            TabBar(
              controller: _tabController,
              labelColor: Constants.blueColor,
                indicatorColor: Constants.blueColor,

                tabs: [
              Tab(text: "Add Service".tr(),),
              Tab(text: "History".tr(),),
            ]),
            SizedBox(height: 10,),
            Expanded(
              child: TabBarView(
              controller: _tabController,
              children: [
                AddCarServicesScreen(resourcesData: widget.resourcesData,tabController: _tabController,),
                ServiceHistoryTap(resourcesData: widget.resourcesData,),
              ]),
            )

          ],
        ),
      ),
    );
  }
}


class AddCarServicesScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  TabController? tabController ;
  AddCarServicesScreen({this.resourcesData,this.tabController});
  @override
  _AddCarServicesScreenState createState() => _AddCarServicesScreenState();
}

class _AddCarServicesScreenState extends State<AddCarServicesScreen> {
  double? screenWidth , screenHeight , width , height ;

  final _serviceAmountController = TextEditingController();
  final _refNoController = TextEditingController();
  final _locationController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> petrolGradeList = ['Fix','Change'] ;
  bool gradeCheck92 = false ;
  bool gradeCheck95 = false ;

  String date = '' ;
  bool hasSparPart = false ;


  Cancellation? _currentSelectedSrv  ;
  Cancellation? _selectedSparePart  ;

  List<Cancellation> sparePartsList = [];

  final _sparePartSearchController = TextEditingController();

  @override
  void initState() {
    _currentSelectedSrv = widget.resourcesData?.service_type?.first ;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return ProgressHUD(
      backgroundColor: Constants.blueColor,
      child: BlocListener<PostCarSrvBloc , PostCarSrvStates>(
        listener: (context , state){
          if(state is PostCarSrvLoading){
            final progress = ProgressHUD.of(context);
            progress?.show();
          }else{
            final progress = ProgressHUD.of(context);
            progress?.dismiss();
          }
          if(state is PostCarSrvAddSuccess){
            widget.tabController?.animateTo(1);
            BlocProvider.of<CarSrvHistoryBloc>(context).add(GetCarSrvHistory());
            ComFunctions.showToast(text: "Done".tr(),color: Colors.green);
          }
          if(state is PostCarSrvError){
            state.errorList?.forEach((element) {
              ComFunctions.showToast(text:element , color: Colors.red);

            });
          }
        },
        child: Scaffold(
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Type of service'.tr(),
                      style: TextStyle(
                        fontSize: 17,
                        color: Constants.blueColor
                      ),
                    ),
                    SizedBox(height: 5,),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Constants.blueColor),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child:  DropdownSearch<Cancellation?>(
                          dropdownSearchDecoration: kTextFieldDecoration2.copyWith(
                              hintText: "",
                          ),
                          searchBoxDecoration: kTextFieldDecoration.copyWith(
                              hintText: "".tr(),
                              suffixIcon: Icon(Icons.search)
                          ),
                          label: "",
                          items:  widget.resourcesData?.service_type,
                          searchBoxController: _sparePartSearchController,
                          maxHeight: screenHeight!*0.8,
                          showSearchBox: true,
                          selectedItem: _currentSelectedSrv ,
                          itemAsString: (Cancellation? u) => u!.name ?? "",
                          emptyBuilder: (context , string){
                            return Center(child: Text('No results'.tr()));
                          },
                          mode:Mode.BOTTOM_SHEET ,
                          enabled: true,
                          onChanged: (value){
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _currentSelectedSrv = value;
                            });

                          },
                          clearButton: Icon(Icons.close),
                        ),
                        // DropdownButtonHideUnderline(
                        //   child: DropdownButton<Cancellation>(
                        //     onTap: (){
                        //       FocusScope.of(context).unfocus();
                        //     },
                        //     dropdownColor: Colors.white,
                        //     items: widget.resourcesData?.service_type?.map((Cancellation
                        //     dropDownStringItem) {
                        //       return DropdownMenuItem<Cancellation>(
                        //         value: dropDownStringItem,
                        //         child: Text(
                        //           dropDownStringItem.name ?? "" ,
                        //           style: TextStyle(
                        //               color: Constants.blueColor,
                        //               fontSize: 16),
                        //         ),
                        //       );
                        //     }).toList(),
                        //     onChanged: (Cancellation? newValue) {
                        //       setState(() {
                        //         _currentSelectedSrv = newValue;
                        //       });
                        //
                        //       },
                        //     value: _currentSelectedSrv,
                        //   ),
                        // ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      controller: _locationController,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'please enter the station location'.tr();
                        }
                        return null;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        labelText: 'Station Location'.tr(),
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      controller: _refNoController,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'please enter the reference number'.tr();
                        }
                        return null;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        labelText: 'Reference number'.tr(),
                      ),
                    ),
                    SizedBox(height: 15,),
                    DateTimeFormField(
                      decoration: kTextFieldDecoration.copyWith(
                        labelText: 'Date'.tr(),
                        suffixIcon: Icon(Icons.event_note, color: Constants.blueColor,),

                      ),
                      mode: DateTimeFieldPickerMode.dateAndTime,
                      autovalidateMode: AutovalidateMode.always,
                      dateFormat:DateFormat('yyyy-MM-dd hh:mm aaa'),
                      onDateSelected: (DateTime value) {
                        date = value.toString();
                      },
                      onSaved: (value){
                        date = value.toString();
                      },
                    ),
                    SizedBox(height: 30,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _serviceAmountController,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'please enter the value'.tr();
                        }
                        return null;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        labelText: 'Service charge'.tr(),
                      ),
                    ),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          hasSparPart = !hasSparPart ;
                          if(!hasSparPart){
                            sparePartsList.clear() ;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Constants.blueColor,
                            ),
                            child: SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child: CustomCheckBox(
                                  checkedColor: Constants.blueColor,
                                  unCheckedColor: Colors.grey,
                                  backgroundColor: Colors.white,
                                  checked:hasSparPart,
                                )
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text("Add spare parts".tr(),style: TextStyle(fontSize: 16,color: Constants.blueColor),),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    hasSparPart ?  Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'Spare part'.tr(),
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Constants.blueColor
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                              width: screenWidth,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: DropdownSearch<Cancellation?>(
                                dropdownSearchDecoration: kTextFieldDecoration2.copyWith(
                                    hintText: ""
                                ),
                                searchBoxDecoration: kTextFieldDecoration.copyWith(
                                    hintText: "Spare part".tr(),
                                    suffixIcon: Icon(Icons.search)
                                ),
                                label: "",
                                items: widget.resourcesData?.spare_parts,
                                searchBoxController: _sparePartSearchController,
                                maxHeight: screenHeight!*0.8,
                                showSearchBox: true,
                                selectedItem: _selectedSparePart ,
                                itemAsString: (Cancellation? u) => u!.name ?? "",
                                emptyBuilder: (context , string){
                                  return Center(child: Text('No results'.tr()));
                                },
                                mode:Mode.BOTTOM_SHEET ,
                                enabled: true,
                                onChanged: (value){

                                  setState(() {
                                    _selectedSparePart = value;
                                    _sparePartSearchController.clear();
                                    FocusScope.of(context).unfocus();
                                    if(sparePartsList.contains(value)){
                                      ComFunctions.showToast(text: "already added");
                                    }else{
                                      value?.amount = null ;
                                      value?.quantity = null ;
                                      sparePartsList.add(value!);

                                    }

                                  });

                                },
                                clearButton: Icon(Icons.close),
                              ),

                            ),
                            Wrap(
                             children: sparePartsList.map((e){
                               return  SparePartCard(
                                 function: (){
                                   setState(() {
                                     sparePartsList.remove(e);
                                   });
                                 },
                                 sparePartType: e,);
                             }).toList(),
                           )

                          ],
                        ),
                      ),
                    ) : SizedBox(),
                    SizedBox(height: 15,),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ButtonTheme(
                        minWidth: screenWidth!,
                        height: 50,
                        child: FlatButton(
                            padding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            color: Constants.blueColor,
                            textColor: Colors.white,
                            child: Text(
                              'Add'.tr(),
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () {
                              if(_formKey.currentState!.validate()){

                                if(date == ""){
                                  ComFunctions.showToast(text:"please enter the date".tr() , color: Colors.red);
                                }else{
                                  BlocProvider.of<PostCarSrvBloc>(context).add(PostCarSrv(fuelEntryModel:
                                  FuelEntryModel(vehicle: SavedData.profileDataModel.vehicle, reference: _refNoController.text, grade: _currentSelectedSrv?.id, courier: '', amount: _serviceAmountController.text, updatedAt: "", createdAt: date, id: "0", status: ''
                                      , station: _locationController.text,sparePartList: sparePartsList
                                  )
                                  ));
                                }
                              }
                            }),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




class ServiceHistoryTap extends StatefulWidget {
  ResourcesData? resourcesData ;
  ServiceHistoryTap({this.resourcesData});
  @override
  _ServiceHistoryTapState createState() => _ServiceHistoryTapState();
}

class _ServiceHistoryTapState extends State<ServiceHistoryTap> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: BlocConsumer<CarSrvHistoryBloc , CarSrvHistoryStates>(
        builder: (context , state){
          if(state is CarSrvHistoryLoaded){
            return RefreshIndicator(
              onRefresh: ()async{
                BlocProvider.of<CarSrvHistoryBloc>(context).add(GetCarSrvHistory());
              },
              child: ListView.builder(
                  itemCount:  state.list.length,
                  itemBuilder: (context , i ){
                    return ServiceHistoryCard(
                      fuelEntryModel: state.list[i],
                    );
                  }),
            ) ;
          }
          return CustomLoading();
        },
        listener: (context , state){
          if(state is CarSrvHistoryError){
            state.errorList?.forEach((element) {
              ComFunctions.showToast(text:element , color: Colors.red);

            });
          }
        },

      ),
    );
  }
}


class SparePartCard extends StatefulWidget {
  Cancellation? sparePartType ;
  VoidCallback? function ;
  SparePartCard({this.sparePartType, this.function});
  @override
  _SparePartCardState createState() => _SparePartCardState();
}

class _SparePartCardState extends State<SparePartCard> {

  final _amountController = TextEditingController();
  final _quantityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Constants.capGrey,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sparePartType?.name ?? "" ,style: TextStyle(color: Colors.white),),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            widget.sparePartType?.quantity == null ||  widget.sparePartType?.quantity == "" ?
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'please enter the value'.tr();
                                }
                                return null;
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                  labelText: 'quantity'.tr(),
                                  labelStyle: TextStyle(color: Colors.deepOrangeAccent , fontSize: 10)

                              ),
                            ) : Text((widget.sparePartType?.quantity ?? "") + "piece".tr() , style: TextStyle(color: Colors.white , fontSize: 15),),
                            SizedBox(height: 10,),
                            widget.sparePartType?.amount == null ||  widget.sparePartType?.amount == "" ?
                            TextFormField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'please enter the value'.tr();
                                }
                                return null;
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                  labelText: 'total amount'.tr(),
                                  labelStyle: TextStyle(color: Colors.deepOrangeAccent , fontSize: 10)
                              ),
                            ) : Text((widget.sparePartType?.amount ?? "")+ " "+"SR".tr() , style: TextStyle(color: Colors.white , fontSize: 15),),
                          ],
                        ),
                      ),
                      SizedBox(width: 30,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          (widget.sparePartType?.amount == null ||  widget.sparePartType?.amount == "" ) && (widget.sparePartType?.quantity == null ||  widget.sparePartType?.quantity == "" ) ?
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary:Constants.blueColor , // background
                              onPrimary: Constants.blueColor , // foreground
                            ),
                            onPressed: () {
                              setState(() {
                                if(_amountController.text.isNotEmpty &&  _quantityController.text.isNotEmpty){
                                  widget.sparePartType?.amount = _amountController.text ;
                                  widget.sparePartType?.quantity = _quantityController.text ;
                                }


                              });
                            },
                            child: Text('Save'.tr(),style: TextStyle(color: Colors.white),),
                          ) : SizedBox(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary:Constants.redColor , // background
                              onPrimary: Constants.redColor , // foreground
                            ),
                            onPressed: widget.function,
                            child: Text('Remove'.tr(),style: TextStyle(color: Colors.white),),
                          )

                        ],
                      )
                    ],
                  ),



                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}


