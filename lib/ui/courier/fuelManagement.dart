import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:xturbox/blocs/bloc/fuelHistory_bloc.dart';
import 'package:xturbox/blocs/bloc/postFeulEntry_bloc.dart';
import 'package:xturbox/blocs/events/PostFuelEntry_bloc.dart';
import 'package:xturbox/blocs/events/fuelHistory_events.dart';
import 'package:xturbox/blocs/states/fuelHistory_states.dart';
import 'package:xturbox/blocs/states/postFeulEntry_states.dart';
import 'package:xturbox/data_providers/models/fuel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/courier/list_tiles/fuel_history_card.dart';
import 'package:xturbox/ui/custom%20widgets/CaptainAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/customCheckBox.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/ui/custom%20widgets/drawerCaptain.dart';
import 'package:xturbox/ui/custom%20widgets/drawerDriver.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/comFunctions.dart';

class FuelManagementScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  FuelManagementScreen({this.resourcesData});
  @override
  _FuelManagementScreenState createState() => _FuelManagementScreenState();
}

class _FuelManagementScreenState extends State<FuelManagementScreen> with TickerProviderStateMixin {
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
    return BlocProvider(
      create: (context)=>FuelHistoryBloc()..add(GetFuelHistory()),
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
              drawerKey: _drawerKey, screenName: 'Fuel management'.tr(),
            ),
            SizedBox(height: 10,),
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
                AddFuel(resourcesData: widget.resourcesData,tabController: _tabController,),
                FuelHistoryTap(resourcesData: widget.resourcesData, )
              ]),
            )

          ],
        ),
      ),
    );
  }
}

class AddFuel extends StatefulWidget {
  ResourcesData? resourcesData ;
  TabController? tabController ;
  AddFuel({this.resourcesData , this.tabController});
  @override
  _AddFuelState createState() => _AddFuelState();
}

class _AddFuelState extends State<AddFuel> {
  double? screenWidth , screenHeight , width , height ;

  final _litersController = TextEditingController();
  final _refNoController = TextEditingController();
  final _locationController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> petrolGradeList = ['92','95'] ;
  bool gradeCheck92 = false ;
  bool gradeCheck95 = false ;

  Cancellation? _currentSelectedGrade  ;
  String date = '' ;

  @override
  void initState() {
    try{
      widget.resourcesData?.fuel_grade?.forEach((element) {element.checked = false ;});
      if(_currentSelectedGrade == null){
        _currentSelectedGrade = widget.resourcesData?.fuel_grade?.first ;
        _currentSelectedGrade?.checked = true;
      }

    }catch(e){}
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return BlocProvider(
      create: (context)=>PostFuelEntryBloc(),
      child: ProgressHUD(
        backgroundColor: Constants.blueColor,
        child: BlocConsumer<PostFuelEntryBloc , PostFuelEntryStates>(
          builder: (context , state){
            return Scaffold(
              backgroundColor: Constants.greyColor,
              body: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children:  widget.resourcesData?.fuel_grade?.map((e){
                                  return GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        e.checked = !e.checked ;
                                        _currentSelectedGrade = e ;
                                        for(int x =0 ; x < (widget.resourcesData?.fuel_grade?.length ?? 0) ; x++){
                                          if(_currentSelectedGrade?.id != widget.resourcesData?.fuel_grade?[x].id ){
                                            widget.resourcesData?.fuel_grade?[x].checked = false ;
                                          }
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CustomCheckBox(backgroundColor: Colors.white, checked: e.checked, checkedColor: Constants.blueColor, unCheckedColor: Constants.blueColor)),
                                          SizedBox(width: 5,),
                                          Text(e.name ?? "" ,style: TextStyle(color: Constants.blueColor, fontSize: 16),)
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList() ?? []
                              ),
                              SizedBox(height: 15,),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _litersController,
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'please enter the amount'.tr();
                                  }
                                  return null;
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                  labelText: 'Amount ( Liters )'.tr(),
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
                                decoration: kTextFieldDecoration.copyWith(
                                  labelText: 'Reference number'.tr(),
                                ),
                              ),
                              SizedBox(height: 15,),
                              DateTimeFormField(
                                decoration: kTextFieldDecoration.copyWith(
                                  labelText: 'Fuel Entry Date'.tr(),
                                  suffixIcon: Icon(Icons.event_note, color: Constants.blueColor,),

                                ),
                                mode: DateTimeFieldPickerMode.dateAndTime,
                                autovalidateMode: AutovalidateMode.always,
                                dateFormat:DateFormat('yyyy-MM-dd hh:mm aaa') ,
                                onDateSelected: (DateTime value) {
                                  date = value.toString();
                                },
                                onSaved: (value){
                                  date = value.toString();
                                },
                              ),
                              SizedBox(height: 30,),

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
                                            BlocProvider.of<PostFuelEntryBloc>(context).add(PostFuelEntry(fuelEntryModel:
                                            FuelEntryModel(vehicle: SavedData.profileDataModel.vehicle, reference: _refNoController.text, grade: _currentSelectedGrade?.id, courier: '', amount: _litersController.text, updatedAt: '', createdAt: date, id: "0", status: '', station:_locationController.text)
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

                  ],
                ),
              ),
            );
          },
          listener: (context , state){
            if(state is PostFuelEntryLoading){
              final progress = ProgressHUD.of(context);
              progress?.show();
            }else{
              final progress = ProgressHUD.of(context);
              progress?.dismiss();
            }
            if(state is PostFuelEntryAddSuccess){
              widget.tabController?.animateTo(1);
              BlocProvider.of<FuelHistoryBloc>(context).add(GetFuelHistory());
              ComFunctions.showToast(text: "Done".tr(),color: Colors.green);
            }
            if(state is PostFuelEntryError){
              state.errorList?.forEach((element) {
                ComFunctions.showToast(text:element , color: Colors.red);

              });
            }
          },
        ),
      ),
    );
  }
}

class FuelHistoryTap extends StatefulWidget {
  ResourcesData? resourcesData ;
  FuelHistoryTap({this.resourcesData});
  @override
  _FuelHistoryTapState createState() => _FuelHistoryTapState();
}

class _FuelHistoryTapState extends State<FuelHistoryTap> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FuelHistoryBloc , FuelHistoryStates>(
      builder: (context , state){
        if(state is FuelHistoryLoaded){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
                itemCount: state.list.length,
                itemBuilder: (context , i ){
                  return FuelHistoryCard(
                    fuelEntryModel: state.list[i],
                  );
                }),
          );
        }
        return CustomLoading();
      },
      listener: (context , state){
        if(state is FuelHistoryError){
          state.errorList?.forEach((element) {
            ComFunctions.showToast(text:element , color: Colors.red);

          });
        }
      },
    );
  }
}
