import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:xturbox/data_providers/models/NationalAddreesModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/custom%20widgets/home_button.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/editProfile_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/editProfile_events.dart';
import 'package:xturbox/blocs/states/editProfile_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/drawerClient.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/utilities/Constants.dart';

import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';


class BankScreen extends StatefulWidget {
  ProfileDataModel? dashboardDataModelNew;
  ResourcesData? resourcesData ;
  BankScreen({this.resourcesData , this.dashboardDataModelNew});
  @override
  _BankScreenState createState() => _BankScreenState();
}
class _BankScreenState extends State<BankScreen> {
  double? screenWidth , screenHeight ;
  UserRepository userRepository =UserRepository();
  final _bankController = TextEditingController();
  final _ibanController = TextEditingController();
  final _ibanPrefixController = TextEditingController(text: "SA");
  final FocusNode nameFocus = FocusNode();
  final FocusNode bankNameFocus = FocusNode();
  final FocusNode ibanFocus = FocusNode();


  final _cityController = TextEditingController();
  final _zoneController = TextEditingController();
  final _buildingController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _additionalNoController = TextEditingController();
  final _unitNoController = TextEditingController();
  final _shortAddressController = TextEditingController();


  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  var _formKey = GlobalKey<FormState>();
  var _addressFormKey = GlobalKey<FormState>();
  EditProfileBloc editProfileBloc = EditProfileBloc();

  final _bankMemberNameController = TextEditingController();
  bool? checkData ;
  String? banHolder ;
  String? bankName ;
  String? bankIbam ;
  bool startValidation = false ;
  bool enableEditing = false ;

  Cancellation? _currentSelectedBank ;

  bool validateIban(String value) {
    if(value.isNotEmpty || _bankController.text.isNotEmpty){
      if (value.length == 22 ) {
        return false;
      }

      return true;

    }
    return false ;

  }
  bool validatbank(String value) {
    if (_ibanController.text.isNotEmpty) {
      if(value.isEmpty){
        return true;
      }
      return false;
    }
    return false;
  }

  ProfileDataModel dashboardDataModel = ProfileDataModel() ;
  getProfile() async{
    dashboardDataModel = await (userRepository.getUserData() as FutureOr<ProfileDataModel>);

  }
  _onBankButtonPressed(){
    startValidation =true;
    if(_formKey.currentState!.validate()){
      editProfileBloc.add(AddBank(
          bankName: _currentSelectedBank?.id,
         iban: "SA"+_ibanController.text,
         name: _bankMemberNameController.text

      ));

    }
  }
  // send email to customer services to edit the bank information
  _onChangeBankButtonPressed(){
    if(_bankMemberNameController.text == widget.dashboardDataModelNew?.bankHolder && _ibanController.text == widget.dashboardDataModelNew?.iban && _currentSelectedBank!.id == widget.dashboardDataModelNew?.bank){
      ComFunctions.showToast(color: Colors.red , text:"There is no change in the data".tr());
    }else {

      startValidation =true;

      if(_formKey.currentState!.validate()){

        editProfileBloc.add(EditBank(
            bankName: _currentSelectedBank?.id,
            iban: "SA"+_ibanController.text,
            name: _bankMemberNameController.text

        ));

      }

    }

  }
  bool checkBankData(){
    if( (
        widget.dashboardDataModelNew?.bank == "0" || widget.dashboardDataModelNew?.bank == null )
        &&
        (widget.dashboardDataModelNew?.bankName == "" || widget.dashboardDataModelNew?.bankName == null )
        &&
        (widget.dashboardDataModelNew?.bankHolder == "" || widget.dashboardDataModelNew?.bankHolder == null )
        &&
        (widget.dashboardDataModelNew?.iban == "" || widget.dashboardDataModelNew?.iban == null )

    ){

      return true  ;
    } else {
      setState(() {
        banHolder = dashboardDataModel.bankHolder;

        bankName = dashboardDataModel.bankName ;
        bankIbam = dashboardDataModel.iban;
      });
      return false ;

    }



  }

  getBankData(){
    setState(() {

      _cityController.text = SavedData.profileDataModel.city ?? "" ;
      _zoneController.text = SavedData.profileDataModel.neighborhood ?? "" ;
      _streetController.text = SavedData.profileDataModel.street ?? "" ;
      _buildingController.text = SavedData.profileDataModel.building ?? "" ;
      _postalCodeController.text = SavedData.profileDataModel.postal_code ?? "" ;
      _additionalNoController.text = SavedData.profileDataModel.additional_code ?? "" ;
      _unitNoController.text = SavedData.profileDataModel.unit ?? "" ;
      _shortAddressController.text = SavedData.profileDataModel.short_address ?? "" ;

    });
  }


  @override
  void dispose() {
    nameFocus.dispose();
    ibanFocus.dispose();
    bankNameFocus.dispose();
    editProfileBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    try{
      getBankData();
      checkData = checkBankData();
    }
    catch(e){
      editProfileBloc.add(EditProfileEventsGenerateError());
    }


    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    screenWidth = size.width;
    screenHeight = size.height;
    return BlocProvider(
      create: (context)=>EditProfileBloc(),
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
                  SizedBox(height: 10,),
                  Expanded(
                    child: Container(
                      color: Constants.clientBackgroundGrey,
                      child: Padding(
                        padding: EdgeInsets.only(right: screenWidth!*0.03, left: screenWidth!*0.03, top: screenHeight!*0.01 ),
                        child: ListView(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth!*0.015),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/images/money-bag.svg",
                                        placeholderBuilder: (context) => CustomLoading(),
                                        height: 38.0,
                                        color: Constants.blueColor,

                                      ),
                                      SizedBox(width: 9,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('My Bank Account'.tr(),
                                            style:TextStyle(
                                                fontSize: 19,
                                                color: Constants.blueColor,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),

                                        ],

                                      ),
                                    ],
                                  ),

                                  widget.dashboardDataModelNew?.iban != '' && widget.dashboardDataModelNew?.iban != null  ?
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        enableEditing = !enableEditing ;
                                        if(enableEditing){
                                          FocusScope.of(context).requestFocus(bankNameFocus);
                                          _ibanController.clear();
                                          _bankMemberNameController.clear();
                                          _currentSelectedBank = null ;

                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text("Edit".tr(),style: TextStyle(color: Constants.blueColor),),
                                        Icon(Icons.edit , color:Constants.blueColor ,),
                                      ],
                                    ),
                                  ) : SizedBox()

                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top:  screenHeight!*0.03 ),
                              child: BlocConsumer<EditProfileBloc , EditProfileStates>(
                                bloc: editProfileBloc,
                                builder:(context , state){


                                  if(state is EditLoading){
                                    return CreateBankScree(loading: true);
                                  }
                                 else if(state is EditError){
                                    return CreateBankScree(loading: false);
                                  }
                                  else if(state is EditSuccess){
                                    return CreateBankScree(loading: false);
                                  }
                                  return CreateBankScree(loading: false);
                                } ,
                                listener: (context , state){
                                  if (state is EditSuccess) {
                                    _onWidgetDidBuild(context, () {
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Bank data added'.tr()),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    });
                                    Future.delayed(const Duration(seconds: 1), () {
                                      Navigator.pushReplacement(context, MaterialPageRoute(
                                          builder: (context)=> ResourcesScreen(
                                            resourcesData: widget.resourcesData,
                                          )
                                      ));
                                    });


                                  }
                                  else if (state is EditError) {
                                    if(state.error == 'TIMEOUT'){
                                      GeneralHandler.handleNetworkError(context);


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
                                    else {
                                      _onWidgetDidBuild(context, () {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Container(
                                                width: screenWidth,
                                                height: screenHeight!*0.05,
                                                child: Text(state.errorList?.first ?? "Something went wrong please try again".tr())
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      });

                                    }
                                  }
                                },

                              ),
                            )

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
      ),
    );
  }
  Widget CreateBankScree({required bool loading}){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth!*0.015),

      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // checkData ?
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full name ( Account owner )'.tr()),
                    SizedBox(height: 10,),
                  enableEditing  || widget.dashboardDataModelNew?.iban == '' || widget.dashboardDataModelNew?.iban == null?
                  TextFormField(
                      key: const ValueKey('bankOwner'),
                      focusNode: nameFocus,
                      onFieldSubmitted:(v) {
                        FocusScope.of(context).requestFocus(bankNameFocus);
                      },
                      decoration: kTextFieldDecoration2.copyWith(
                        hintText: '',
                      ),
                      validator: (String? value ){
                        if(value!.isEmpty){
                          return 'please add your full name'.tr();
                        }
                        return null ;
                      },
                      onChanged: (e){
                        if(startValidation){
                          _formKey.currentState!.validate();
                        }
                      },
                      controller: _bankMemberNameController,
                    ) :
                  Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.dashboardDataModelNew?.bankHolder ?? ""),
                      ),
                    ) ,
                  ],
                ),
                SizedBox(height: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bank name'.tr()),
                    SizedBox(height: 10,),
                    enableEditing  || widget.dashboardDataModelNew?.iban == '' || widget.dashboardDataModelNew?.iban == null?
                   Container(
                      height: screenHeight! * 0.06,
                      width: screenWidth,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [

                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<Cancellation>(
                                  decoration: InputDecoration.collapsed(hintText: ''),
                                  focusNode: bankNameFocus,
                                  onTap:(){
                                    FocusScope.of(context).unfocus();
                                  },
                                  items: widget.resourcesData?.banks?.map((Cancellation dropDownStringItem) {
                                    return DropdownMenuItem<Cancellation>(
                                      value: dropDownStringItem,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: Container(
                                          width: screenWidth!*0.6,
                                          child: AutoSizeText(
                                            dropDownStringItem.name ?? "",
                                            style: TextStyle(
                                                color:Colors.black, fontSize: 15),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Cancellation? newValue) {
                                    setState(() {
                                      _currentSelectedBank = newValue;

                                    });
                                  },
                                  value: _currentSelectedBank,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) :  Container(
                   width: screenWidth,
                   decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(10)
                   ),
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text(widget.dashboardDataModelNew?.bankName?? ""),
                   ),
                 ) ,
                  ],
                ),
                SizedBox(height: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text('IBAN ( Account number )'.tr()),
                    SizedBox(height: 10,),
                    enableEditing  ||  widget.dashboardDataModelNew?.iban == '' || widget.dashboardDataModelNew?.iban == null?
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                keyboardType: TextInputType.none,
                                readOnly: true,
                                decoration: kTextFieldDecoration2.copyWith(
                                    hintText: '',
                                ),
                                onChanged: (e){
                                  if(startValidation){
                                    _formKey.currentState!.validate();
                                  }
                                },
                                validator: (String? value) {
                                  if(_ibanController.text.isEmpty){
                                    return '';
                                  }
                                  if (validateIban(_ibanController.text)) {
                                    return '';
                                  }

                                  return null ;
                                },

                                controller: _ibanPrefixController,
                              ),
                            ),
                          ),
                          SizedBox(width: 4,),
                          Expanded(
                            flex: 4,
                            child: Container(
                              child: TextFormField(
                                focusNode: ibanFocus,
                                keyboardType: TextInputType.number,
                                decoration: kTextFieldDecoration2.copyWith(
                                    hintText: '',
                                ),
                                onChanged: (e){
                                  if(startValidation){
                                    _formKey.currentState!.validate();
                                  }
                                },
                                validator: (String? value) {
                                  if(value!.isEmpty){
                                    return 'please add your iban'.tr();
                                  }
                                  if (validateIban(value)) {
                                    return 'please add Iban number with 22 digit'.tr();
                                  }

                                  return null ;
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(22),
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: _ibanController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) :
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(widget.dashboardDataModelNew?.iban ?? ""),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30,),
            loading ?
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  child: CustomLoading(),
                ),
              ),
            ) : Container(),
           widget.dashboardDataModelNew?.iban != '' && widget.dashboardDataModelNew?.iban != null  ?
           SizedBox() : ButtonTheme(
             minWidth: screenWidth!,
             height: 50,
             child: FlatButton (

                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12.0),
                 ),
                 color:Constants.blueColor,
                 textColor: Colors.white,
                 child: Text(
                   'Save Information'.tr(),
                   style: TextStyle(
                     fontSize: 17,
                   ),
                 ),
                 onPressed: () {
                   _onBankButtonPressed();
                 }

             ),
           ),
          enableEditing ? ButtonTheme(
             minWidth: screenWidth!,
             height: 50,
             child: FlatButton (

                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12.0),
                 ),
                 color:Constants.blueColor,
                 textColor: Colors.white,
                 child: Text(
                   'Change Information'.tr(),
                   style: TextStyle(
                     fontSize: 17,
                   ),
                 ),
                 onPressed: () {
                   // _onBankButtonPressed();
                   _onChangeBankButtonPressed();
                 }

             ),
           ) : SizedBox(),
            SizedBox(height: 30,),

           Form(
             key: _addressFormKey,
             child: Column(
               children: [
                 Padding(
                   padding: EdgeInsets.symmetric(horizontal: screenWidth!*0.015),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Row(
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('National address'.tr(),
                                 style:TextStyle(
                                     fontSize: 19,
                                     color: Constants.blueColor,
                                     fontWeight: FontWeight.w500
                                 ),
                               ),

                             ],

                           ),
                         ],
                       ),
                     ],
                   ),
                 ),
                 SizedBox(height: 10,),
                 Row(
                   children: [
                     Flexible(
                       child: TextFormField(
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'City'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)

                         ),
                         validator: (String? value ){
                           if(value!.isEmpty){
                             return 'please enter the value'.tr();
                           }
                           return null ;
                         },
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller:_cityController,
                       ),
                     ),
                     SizedBox(width: 10,),
                     Flexible(
                       child: TextFormField(
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'Neighborhood'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)

                         ),
                         validator: (String? value ){
                           if(value!.isEmpty){
                             return 'please enter the value'.tr();
                           }
                           return null ;
                         },
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller: _zoneController,
                       ),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),

                 Row(
                   children: [
                     Flexible(
                       child: TextFormField(
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'Building no'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)

                         ),
                         keyboardType: TextInputType.number,
                         validator: (String? value ){
                           if(value!.isEmpty){
                             return 'please enter the value'.tr();
                           }
                           return null ;
                         },
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller: _buildingController,
                       ),
                     ),
                     SizedBox(width: 10,),
                     Flexible(
                       child: TextFormField(
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'Unit no.'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)

                         ),
                         keyboardType: TextInputType.number,
                         validator: (String? value ){
                           if(value!.isEmpty){
                             return 'please enter the value'.tr();
                           }
                           return null ;
                         },
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller:_unitNoController,
                       ),
                     ),

                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Flexible(
                       child: TextFormField(
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'Postal code'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)

                         ),
                         keyboardType: TextInputType.number,
                         validator: (String? value ){
                           if(value!.isEmpty){
                             return 'please enter the value'.tr();
                           }
                           return null ;
                         },
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller:_postalCodeController,
                       ),
                     ),
                     SizedBox(width: 10,),
                     Flexible(
                       child: TextFormField(
                         keyboardType: TextInputType.number,
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'Additional no.'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)

                         ),
                         validator: (String? value ){
                           if(value!.isEmpty){
                             return 'please enter the value'.tr();
                           }
                           return null ;
                         },
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller: _additionalNoController,
                       ),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Flexible(
                       child: TextFormField(
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'Street'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)

                         ),
                         validator: (String? value ){
                           if(value!.isEmpty){
                             return 'please enter the value'.tr();
                           }
                           return null ;
                         },
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller:_streetController,
                       ),
                     ),
                   ],
                 ),
                 SizedBox(height: 8,),
                 Row(
                   children: [
                     Flexible(
                       child: TextFormField(
                         decoration: kTextFieldDecoration2.copyWith(
                             labelText: 'Short address'.tr(),
                             labelStyle: TextStyle(fontSize: 14,color: Constants.blueColor)
                         ),
                         onChanged: (e){
                           if(startValidation){
                             _formKey.currentState!.validate();
                           }
                         },
                         controller: _shortAddressController,
                       ),
                     ),
                   ],
                 ),
                 SizedBox(height: 15,),
                 ButtonTheme(
                   minWidth: screenWidth!,
                   height: 50,
                   child: FlatButton (

                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12.0),
                       ),
                       color:Constants.blueColor,
                       textColor: Colors.white,
                       child: Text(
                         'Save Information'.tr(),
                         style: TextStyle(
                           fontSize: 17,
                         ),
                       ),
                       onPressed: () {
                         NationalAddressModel model = NationalAddressModel();

                         model.city = _cityController.text ;
                         model.zone = _zoneController.text ;
                         model.street = _streetController.text ;
                         model.building = _buildingController.text ;
                         model.postalCode = _postalCodeController.text ;
                         model.additionalNumber = _additionalNoController.text ;
                         model.unit = _unitNoController.text ;
                         model.shortAddress = _shortAddressController.text ;
                         if(_addressFormKey.currentState!.validate()){
                           editProfileBloc.add(AddNationalAddress(
                               nationalAddressModel: model
                           ));
                         }

                       }

                   ),
                 ),
               ],
             ),
           ),


          ],
        ),
      ),
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }
}
