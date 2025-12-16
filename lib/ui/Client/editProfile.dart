import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart' as intl;

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/dashboard_bloc.dart';
import 'package:xturbox/blocs/bloc/editProfile_bloc.dart';
import 'package:xturbox/blocs/bloc/resources_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/blocs/events/editProfile_events.dart';
import 'package:xturbox/blocs/states/editProfile_states.dart';
import 'package:xturbox/blocs/states/resources_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/ResponseViewModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/main.dart';
import 'package:xturbox/ui/common/Confirmation.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/drawerClient.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/my_container.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:collection/collection.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/fieldValidations.dart';

import 'MyOrders.dart';
import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';
import '../custom widgets/home_button.dart';

class EditProfile extends StatefulWidget {

  ResourcesData? resourcesData;
  ProfileDataModel? dashboardDataModel;
  EditProfile({this.resourcesData, this.dashboardDataModel});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool areListsEqual(List<Addresses> list1, List<Addresses> list2) {
    // check if both are lists

    if (list1.length != list2.length) {
      return false;
    }

    // check if elements are equal
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    for (int i = 0; i < list2.length; i++) {
      if (list2[i] != list1[i]) {
        return false;
      }
    }

    return true;
  }

  final _usernameController = TextEditingController();

  // EditProfileBloc editProfileBloc = EditProfileBloc();
  final _idController = TextEditingController();

  final _nameController = TextEditingController();
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _cerController = TextEditingController();

  final _emailController = TextEditingController();
  final _addressMapController = TextEditingController();

  List<String> citiesNames = [];

  final _passwordOldController = TextEditingController();
  final _passwordNewController = TextEditingController();

  final _passwordNewConfirmationController = TextEditingController();

  final _phoneController = TextEditingController();
  final _phoneController2 = TextEditingController();
  final _arCodeController = TextEditingController();
  final _enCodeController = TextEditingController();

  FocusNode newPasswordNode = FocusNode();
  FocusNode newPasswordConfNode = FocusNode();
  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();

  UserRepository userRepository = UserRepository();
  double? width, height, screenWidth, screenHeight;

  String? mapUrlGeneral;

  bool? hasAddress;
  bool phoneChanged = false;
  bool? phoneChangerTWO;
  int? lengthCheck;

  bool locationSelected = false;

  var _formKey = GlobalKey<FormState>();
  String? password;

  Function deepEq = const DeepCollectionEquality().equals;
  List<Addresses> checkAddressChanging = [];
  bool? checkBox;
  bool changePassword = false;
  bool changePasswordTWO = false;
  String newPassword = '';

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    return (!regex.hasMatch(value)) ? false : true;
  }

  bool validatePassword(String? value) {
    if (_passwordNewController.text ==
        _passwordNewConfirmationController.text) {
      return true;
    }
    return false;
  }

  bool phoneValidation(String value) {
    if (value.length == 9 && value.characters.first == '5') {
      return true;
    }
    return false;
  }

  AuthenticationBloc authenticationBloc = AuthenticationBloc();

  EditProfileBloc editProfileBloc = EditProfileBloc();

  ResourcesBloc resourcesBloc = ResourcesBloc();
  getProfile() async {
    password = await userRepository.getAuthPassword();
    _nameController.text = widget.dashboardDataModel?.name ?? "";
    _phoneController.text = widget.dashboardDataModel?.phone ?? "";
    _phoneController2.text = widget.dashboardDataModel?.phone2 ?? "";
    _emailController.text = widget.dashboardDataModel?.email ?? "";
    _fNameController.text = SavedData.profileDataModel.firstName ?? "";
    _lNameController.text = SavedData.profileDataModel.lastName ?? "";
    _idController.text = SavedData.profileDataModel.national_id ?? "";
    _companyNameController.text = SavedData.profileDataModel.companyName ?? "";
    _vatNumberController.text = SavedData.profileDataModel.vatNumber ?? "";
    _cerController.text = SavedData.profileDataModel.cer ?? "";
  }

  @override
  void dispose() {
    newPasswordNode.dispose();
    newPasswordConfNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  _onEditProfileBtnPressed() {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text == widget.dashboardDataModel!.name &&
          _emailController.text == widget.dashboardDataModel!.email &&
          !changePasswordTWO &&
          _phoneController2.text == widget.dashboardDataModel!.phone2 &&
          _fNameController.text == SavedData.profileDataModel.firstName &&
          _idController.text == SavedData.profileDataModel.national_id &&
          _companyNameController.text == SavedData.profileDataModel.companyName &&
          _vatNumberController.text == SavedData.profileDataModel.vatNumber &&
          _cerController.text == SavedData.profileDataModel.cer &&
          _lNameController.text == SavedData.profileDataModel.lastName) {
        _onWidgetDidBuild(context, () {
          _drawerKey.currentState!.showSnackBar(
            SnackBar(
              content: Container(
                width: screenWidth,
                height: screenHeight! * 0.05,
                child: Text('Nothing Changed'.tr()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
      } else {
        bool checkUsername = _nameController.text.toString() !=
                SavedData.profileDataModel.name.toString()
            ? true
            : false;
        editProfileBloc.add(PutProfileRequest(
            id: widget.dashboardDataModel!.id,
            email: _emailController.text.toString(),
            password:
                changePasswordTWO ? _passwordNewController.text : password,
            name: _nameController.text.toString(),
            phone2: _phoneController2.text,
            firstName: _fNameController.text,
            lastName: _lNameController.text,
            national_id:  widget.dashboardDataModel!.national_id != null &&  widget.dashboardDataModel!.national_id != "" &&   widget.dashboardDataModel!.national_id != "0" ?
            widget.dashboardDataModel!.national_id.toString()  :  _idController.text.toString(),
            cer: _cerController.text,
            vatNumber: _vatNumberController.text,
            companyName: _companyNameController.text,
            changeUsername: checkUsername));
      }
    }
  }

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    _enCodeController.text = '+966';
    _arCodeController.text = '966+';
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    width = size.width;
    height = size.height;
    return BlocProvider(
      create: (context) => EditProfileBloc(),
      child: Scaffold(
        backgroundColor: Constants.clientBackgroundGrey,
        key: _drawerKey,
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
                        padding: EdgeInsets.only(
                            right: screenWidth! * 0.03,
                            left: screenWidth! * 0.03,
                            top: screenHeight! * 0.01),
                        child: Column(
                          children: [
                            Expanded(
                              child: BlocConsumer<EditProfileBloc, EditProfileStates>(
                                  bloc: editProfileBloc,
                                  builder: (context, state) {
                                    if (state is EditInitial) {
                                      return CreateEditProfileScreen();
                                    } else if (state is EditLoading) {
                                      return Stack(
                                        children: [
                                          CreateEditProfileScreen(),
                                          Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: screenWidth,
                                                height: screenHeight,
                                                child: Center(
                                                  child: CustomLoading(),
                                                ),
                                              )),
                                        ],
                                      );
                                    } else if (state is EditError) {
                                      return CreateEditProfileScreen();
                                    } else if (state is EditSuccess) {
                                      return CreateEditProfileScreen();
                                    } else if (state is EditPhone) {
                                      return ConfirmationScreen(
                                        phone: _phoneController.text,
                                        resourcesData: widget.resourcesData,
                                      );
                                    }
                                    return Container();
                                  },
                                  listener: (context, state) {
                                    if (state is EditSuccess) {
                                      _onWidgetDidBuild(context, () {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Data updated'.tr()),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      });
                                      Future.delayed(const Duration(seconds: 1), () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DashboardScreen(
                                                      resourcesData:
                                                          widget.resourcesData,
                                                    )));
                                      });
                                    } else if (state is EditPhone) {
                                      _onWidgetDidBuild(context, () {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Data updated'.tr()),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      });
                                    } else if (state is EditError) {
                                      if (state.error == 'TIMEOUT') {
                                        GeneralHandler.handleNetworkError(context);
                                      } else if (state.error == "general") {
                                        GeneralHandler.handleGeneralError(context);
                                      } else if (state.error == "invalidToken") {
                                        GeneralHandler.handleInvalidToken(context);
                                      } else if (state.error == 'needUpdate') {
                                        GeneralHandler.handleNeedUpdateState(context);
                                      } else {
                                        ComFunctions.showList(context: context,list: state.errorList);
                                      }
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
            Expanded(child: HomeButton())
          ],
        ),
      ),
    );
  }

  Widget CreateEditProfileScreen() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("Store Name".tr() +" " +"(*)"),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    child: TextFormField(
                      onChanged: (value){
                        _formKey.currentState!.validate();
                      },
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter your store name'.tr();
                        }
                        if(value.contains(' ')){

                          return 'Store can not contain spaces'.tr();
                        }
                        if(!FieldValidation.validaStoreName(value)){
                          return 'Store can not contain arabic letters'.tr();

                        }
                        return null;
                      },
                      decoration: kTextFieldDecoration2.copyWith(
                        prefixIcon: Icon(
                          MdiIcons.store,
                          color: Color(0xFF414141),
                          size: 20,
                        ),
//                                  ImageIcon(
//                                    AssetImage('assets/images/user.png'),
//                                    color:Color(0xFF414141),
//                                  ) ,
                        hintText: 'name'.tr(),
                      ),
                      controller: _nameController,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("First Name".tr()+" " +"(*)"),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    child: TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter your first name'.tr();
                        }
                        return null;
                      },
                      onChanged: (v){
                        _formKey.currentState!.validate();
                      },
                      decoration: kTextFieldDecoration2.copyWith(
                        prefixIcon: Icon(
                          MdiIcons.account,
                          color: Color(0xFF414141),
                          size: 20,
                        ),
                      ),
                      controller: _fNameController,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("Last Name".tr()+" " +"(*)"),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    child: TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter your last name'.tr();
                        }
                        return null;
                      },
                      onChanged: (v){
                        _formKey.currentState!.validate();
                      },
                      decoration: kTextFieldDecoration2.copyWith(
                        prefixIcon: Icon(
                          MdiIcons.account,
                          color: Color(0xFF414141),
                          size: 20,
                        ),
                      ),
                      controller: _lNameController,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("Company Name".tr()),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    child: TextFormField(
                      decoration: kTextFieldDecoration2.copyWith(
                        prefixIcon: Icon(
                          Icons.work,
                          color: Color(0xFF414141),
                          size: 20,
                        ),
                      ),
                      controller: _companyNameController,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("Vat number".tr()),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    child: TextFormField(
                      decoration: kTextFieldDecoration2.copyWith(
                        prefixIcon: Icon(
                          MdiIcons.numeric,
                          color: Color(0xFF414141),
                          size: 20,
                        ),
                      ),
                      controller: _vatNumberController,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("CR".tr()),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    child: TextFormField(
                      decoration: kTextFieldDecoration2.copyWith(
                        prefixIcon: Icon(
                            MdiIcons.numeric,
                          color: Color(0xFF414141),
                          size: 20,
                        ),
                      ),
                      controller: _cerController,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text("National id".tr() +" " +"(*)"),
                ),
                widget.dashboardDataModel?.national_id != null &&  widget.dashboardDataModel?.national_id != "" &&   widget.dashboardDataModel?.national_id != "0"
                    ? Container(
                        height: 50,
                        width: screenWidth,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.dashboardDataModel!.national_id
                                    .toString(),
                                textAlign: EasyLocalization.of(context)!
                                            .currentLocale ==
                                        Locale("ar")
                                    ? TextAlign.end
                                    : TextAlign.start,
                                style: TextStyle(),
                              ),
                            ],
                          ),
                        ))
                    : Container(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (v){
                            _formKey.currentState!.validate();
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter your national id'.tr();
                            }
                            if (value.length != 10) {
                              return 'Please enter a valid national id'.tr();
                            }
                            return null;
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            prefixIcon: Icon(
                              MdiIcons.idCard,
                              color: Color(0xFF414141),
                              size: 20,
                            ),
                          ),
                          controller: _idController,
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text('Phone number'.tr()),
                ),
                EasyLocalization.of(context)!.locale == Locale('en')
                    ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey)),
                                  child: Center(child: Text('+966'))),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(widget
                                                .dashboardDataModel!.phone ??
                                            ''),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(widget
                                                .dashboardDataModel!.phone ??
                                            ''),
                                      ),
                                    ],
                                  )),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey)),
                                  child: Center(child: Text('966+'))),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text('Alternative Phone number'.tr()),
            ),
            EasyLocalization.of(context)!.locale == Locale('en')
                ? Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            readOnly: true,
                            validator: (String? value) {
                              if (_phoneController2.text.isNotEmpty &&
                                  !phoneValidation(_phoneController2.text)) {
                                return '';
                              }
                              return null;
                            },
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration.copyWith(
                                contentPadding: EdgeInsets.all(0),
                                hintText: ''),
                            controller: _enCodeController,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            key: const ValueKey('phoneLogin'),
                            // focusNode: phoneFocusNode,
                            // onFieldSubmitted:(v) {
                            //   FocusScope.of(context).requestFocus(passwordFocusNode);
                            // },
                            // onChanged: (e){
                            //   if(startValidation){
                            //     _formKey.currentState.validate();
                            //   }
                            // },
                            validator: (String? value) {
                              if (value!.isNotEmpty &&
                                  !phoneValidation(value)) {
                                return 'please enter a valid mobile number'
                                    .tr();
                              }
                              return null;
                            },

                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(9),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'phone number'.tr(),
                            ),
                            controller: _phoneController2,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            key: const ValueKey('phoneLogin'),
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            validator: (String? value) {
                              if (value!.isNotEmpty &&
                                  !phoneValidation(value)) {
                                return 'please enter a valid mobile number'
                                    .tr();
                              }
                              return null;
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(9),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: kTextFieldDecoration.copyWith(
                              hintText: 'phone number'.tr(),
                            ),
                            controller: _phoneController2,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            readOnly: true,
                            validator: (String? value) {
                              if (_phoneController2.text.isNotEmpty &&
                                  !phoneValidation(_phoneController2.text)) {
                                return '';
                              }
                              return null;
                            },
                            textAlign: TextAlign.center,
                            decoration: kTextFieldDecoration.copyWith(
                                contentPadding: EdgeInsets.all(0),
                                hintText: ''),
                            controller: _arCodeController,
                          ),
                        ),
                      ],
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text('Email'.tr()),
                ),
                EasyLocalization.of(context)!.locale == Locale('en')
                    ? Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                          child: TextFormField(
                            key: ValueKey("profileMail"),
                            validator: (String? value) {
                              if (!validateEmail(value!) &&
                                  value.isNotEmpty) {
                                return 'please enter a valid email address'
                                    .tr();
                              }
                              return null;
                            },
                            textAlign: TextAlign.end,
                            decoration: kTextFieldDecoration2.copyWith(
                              prefixIcon: Icon(
                                MdiIcons.emailOutline,
                                color: Color(0xFF414141),
                                size: 20,
                              ),
//                                  ImageIcon(
//                                    AssetImage('assets/images/mail.png'),
//                                    color:Color(0xFF414141),
//                                  ) ,
                              hintText: 'email'.tr(),
                            ),
                            controller: _emailController,
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                          child: TextFormField(
                            textAlign: TextAlign.end,
                            validator: (String? value) {
                              if (!validateEmail(value!) &&
                                  value.isNotEmpty) {
                                return 'please enter a valid email address'
                                    .tr();
                              }
                              return null;
                            },
                            decoration: kTextFieldDecoration2.copyWith(
                              suffixIcon: Icon(
                                MdiIcons.emailOutline,
                                color: Color(0xFF414141),
                                size: 20,
                              ),
                              hintText: 'email'.tr(),
                            ),
                            controller: _emailController,
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Material(
              borderRadius: BorderRadius.circular(15),
              // color: Colors.red,
              child: ExpansionTile(

                backgroundColor: Colors.transparent,
                tilePadding: EdgeInsets.symmetric(horizontal: 5),
                childrenPadding: EdgeInsets.symmetric(horizontal: 15),

                title: changePasswordTWO
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Do not change password'.tr(),
                          style: TextStyle(color: Constants.blueColor),
                        ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Change password'.tr(),
                          style: TextStyle(color: Colors.black),
                        ),
                    ),
                onExpansionChanged: (changePassword) {
                  if (!changePassword) {
                    setState(() {
                      changePasswordTWO = false;
                    });
                  } else {
                    setState(() {
                      changePasswordTWO = true;
                    });
                  }
                },
                children: <Widget>[
                  Container(
                    decoration:BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      // color: Colors.green
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            child: TextFormField(
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(newPasswordNode);
                              },
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'please enter your old password'.tr();
                                }
                                if (value != password) {
                                  return 'the old pass word in not correct'.tr();
                                }
                                return null;
                              },
                              decoration: kTextFieldDecoration2.copyWith(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                hintText: 'old password'.tr(),
                                hintStyle: TextStyle(
                                  fontSize: 11,
                                ),
                                prefixIcon: Icon(
                                  MdiIcons.keyVariant,
                                  color: Color(0xFF414141),
                                  size: 20,
                                ),
//                                ImageIcon(
//                                  AssetImage('assets/images/key.png'),
//                                  color: Color(0xFF414141),
//                                  size: 10,
//                                ),
                              ),
                              controller: _passwordOldController,
                              obscureText: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            child: TextFormField(
                              focusNode: newPasswordNode,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(newPasswordConfNode);
                              },
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'please enter your password'.tr();
                                }
                                if (!validatePassword(value)) {
                                  return 'password and confirmation not match'
                                      .tr();
                                }
                                return null;
                              },
                              decoration: kTextFieldDecoration2.copyWith(
                                hintText: 'new password'.tr(),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 11,
                                ),
                                prefixIcon: Icon(
                                  MdiIcons.keyVariant,
                                  color: Color(0xFF414141),
                                  size: 20,
                                ),
                              ),
                              controller: _passwordNewController,
                              obscureText: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            child: TextFormField(
                              focusNode: newPasswordConfNode,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return 'please confirm your password'.tr();
                                }
                                if (!validatePassword(value)) {
                                  return 'password and confirmation not match'
                                      .tr();
                                }
                                return null;
                              },
                              decoration: kTextFieldDecoration2.copyWith(
                                prefixIcon: Icon(
                                  MdiIcons.keyVariant,
                                  color: Color(0xFF414141),
                                  size: 20,
                                ),
                                hintText: 'password confirmation'.tr(),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                              controller: _passwordNewConfirmationController,
                              obscureText: true,
                            ),
                          ),
                        ),
                        SizedBox(height: 10,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ButtonTheme(
              minWidth: screenWidth!,
              height: 50,
              child: FlatButton(
                  key: ValueKey("editPrfBtn"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Constants.blueColor,
                  textColor: Colors.white,
                  child: Text(
                    'Edit'.tr(),
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    _onEditProfileBtnPressed();
                  }),
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
