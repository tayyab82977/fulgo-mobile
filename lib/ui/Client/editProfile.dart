import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart' as intl;

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/edit_profile_controller.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/ResponseViewModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/main.dart';
import 'package:Fulgox/ui/common/Confirmation.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/custom%20widgets/drawerClient.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/ui/custom%20widgets/my_container.dart';
import 'package:Fulgox/ui/common/dashboard.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:collection/collection.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/utilities/fieldValidations.dart';

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

  final AuthController _authController = Get.find<AuthController>();
  final EditProfileController _editProfileController = Get.put(EditProfileController());
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
          _companyNameController.text ==
              SavedData.profileDataModel.companyName &&
          _vatNumberController.text == SavedData.profileDataModel.vatNumber &&
          _cerController.text == SavedData.profileDataModel.cer &&
          _lNameController.text == SavedData.profileDataModel.lastName) {
        _onWidgetDidBuild(context, () {
          ScaffoldMessenger.of(context).showSnackBar(
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
        _editProfileController.putProfileRequest(
            id: widget.dashboardDataModel!.id,
            email: _emailController.text.toString(),
            password:
                changePasswordTWO ? _passwordNewController.text : password,
            name: _nameController.text.toString(),
            phone2: _phoneController2.text,
            firstName: _fNameController.text,
            lastName: _lNameController.text,
            national_id: widget.dashboardDataModel!.national_id != null &&
                    widget.dashboardDataModel!.national_id != "" &&
                    widget.dashboardDataModel!.national_id != "0"
                ? widget.dashboardDataModel!.national_id.toString()
                : _idController.text.toString(),
            cer: _cerController.text,
            vatNumber: _vatNumberController.text,
            companyName: _companyNameController.text,
            changeUsername: checkUsername);
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
    return Scaffold(
        backgroundColor: Constants.clientBackgroundGrey,
        key: _drawerKey,
        body: Obx(() {
          if (_editProfileController.success.value) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              _editProfileController.success.value = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data updated'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashboardScreen(
                              resourcesData: widget.resourcesData,
                            )));
              });
            });
          }

          if (_editProfileController.errorMessage.value != '') {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              String error = _editProfileController.errorMessage.value;
              _editProfileController.errorMessage.value = '';
              if (error == 'TIMEOUT') {
                GeneralHandler.handleNetworkError(context);
              } else if (error == "general") {
                GeneralHandler.handleGeneralError(context);
              } else if (error == "invalidToken") {
                GeneralHandler.handleInvalidToken(context);
              } else if (error == 'needUpdate') {
                GeneralHandler.handleNeedUpdateState(context);
              } else if (error == 'error') {
                ComFunctions.showList(
                  context: context, list: _editProfileController.errorsList.cast<String>().toList());
              } else {
                 ComFunctions.showToast(text: error.tr());
              }
            });
          }

          return Stack(
            children: [
              Column(
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
                                    child: CreateEditProfileScreen(),
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
              if (_editProfileController.isLoading.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black26,
                    child: Center(child: CustomLoading()),
                  ),
                )
            ],
          );
        }),
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
                    child: Text("Store Name".tr() + " " + "(*)"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      child: TextFormField(
                        onChanged: (value) {
                          _formKey.currentState!.validate();
                        },
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Please enter your store name'.tr();
                          }
                          if (value.contains(' ')) {
                            return 'Store can not contain spaces'.tr();
                          }
                          if (!FieldValidation.validaStoreName(value)) {
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
                    child: Text("First Name".tr() + " " + "(*)"),
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
                        onChanged: (v) {
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
                    child: Text("Last Name".tr() + " " + "(*)"),
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
                        onChanged: (v) {
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
                    child: Text("National id".tr() + " " + "(*)"),
                  ),
                  widget.dashboardDataModel?.national_id != null &&
                          widget.dashboardDataModel?.national_id != "" &&
                          widget.dashboardDataModel?.national_id != "0"
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
                            onChanged: (v) {
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
                      ? Text('Cancel change password'.tr())
                      : Text('Change Password'.tr()),
                ),
              )
            ]),
      ),
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }
}
