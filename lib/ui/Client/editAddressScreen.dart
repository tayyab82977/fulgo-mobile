import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:xturbox/blocs/bloc/addressBloc.dart';
import 'package:xturbox/blocs/events/address_events.dart';
import 'package:xturbox/data_providers/models/geoCodingDataModel.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:xturbox/blocs/events/editProfile_events.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:xturbox/blocs/bloc/editProfile_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/blocs/states/editProfile_states.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/Client/addressScreen.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/location.dart';

import '../custom widgets/custom_loading.dart';
import '../custom widgets/drawerClient.dart';
import '../custom widgets/myAppBar.dart';

class EditAddressScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  List<Addresses>? addressList ;
  Addresses? addresses ;
  AddressBloc addressBloc ;
  EditAddressScreen({this.resourcesData, this.addresses , this.addressList , required this.addressBloc});

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  double? screenWidth, screenHeight, width, height;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  var _formKey = GlobalKey<FormState>();
  final _addressTitleController = TextEditingController();
  final _addressDescriptionController = TextEditingController();
  final FocusNode addressTitleFocus = FocusNode();
  final FocusNode addressCommentFocus = FocusNode();
  final FocusNode addressDescriptionFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode zoneFocus = FocusNode();
  ErCity? _currentCitySelected ;
  Neighborhoods? _currentZone ;
  bool locationSelected = false ;
  PickResult? _pickedLocation;
  String? mapUrlGeneral ;
  bool savedTitle = false ;

  List<AddressTitleAndIcon> listAddressTitle = [
    AddressTitleAndIcon(title: 'HomeTitle'.tr() , icon:Icon(Icons.home , color: Colors.black54,)),
    AddressTitleAndIcon(title: 'Work'.tr() , icon:Icon(Icons.work, color: Colors.black54,)),
    AddressTitleAndIcon(title: 'Other'.tr() , icon:Icon(MdiIcons.officeBuildingOutline, color: Colors.black54,)),
  ];

  AddressTitleAndIcon? _currentSelectedAddressTitle = AddressTitleAndIcon() ;


  // List<ErCity> sederCities = new List();

  List<ErCity> senderCities = [];

  getAddressData(){
    // sederCities.addAll(widget.resourcesData.city.where((element) => element.send == "1"));
    List<ErCity> receiverCities = [];
    senderCities.addAll(widget.resourcesData!.city!.where((element) => element.send == "1" && element.neighborhoods!.length > 0 ).toList());
    if(widget.addresses != null){

      if(widget.addresses!.comment == 'Other' ||widget.addresses!.comment == 'آخر' ||widget.addresses!.comment == 'اخر'  ){
       savedTitle = true ;
       _currentSelectedAddressTitle = listAddressTitle[2] ;
       _addressTitleController.text = _currentSelectedAddressTitle!.title!;

      }else if(widget.addresses!.comment == 'Home'|| widget.addresses!.comment == 'HomeTitle'  || widget.addresses!.comment == 'المنزل'  ) {
        savedTitle = false ;
        _currentSelectedAddressTitle = listAddressTitle[0] ;

      }else{
        savedTitle = false ;
        _currentSelectedAddressTitle = listAddressTitle[1] ;

      }




      for (int i = 0 ; i < widget.resourcesData!.city!.length ; i ++ ){
        for(int x = 0 ; x < widget.resourcesData!.city![i].neighborhoods!.length ; x++){
          if (widget.addresses!.city == widget.resourcesData!.city![i].neighborhoods![x].id){
            _currentCitySelected = widget.resourcesData!.city![i] ;
            _currentZone = widget.resourcesData!.city![i].neighborhoods![x] ;
          }
        }
      }

      _addressTitleController.text = widget.addresses!.title! ;
      _addressDescriptionController.text = widget.addresses!.description! ;
      mapUrlGeneral = widget.addresses!.map ;
      setState(() {
        locationSelected = widget.addresses!.map == '' ? false : true ;

      });

    }

    else {
      _currentSelectedAddressTitle = listAddressTitle[0];
      _addressTitleController.text = listAddressTitle[0].title!;

    }

  }
  final searchBoxCityController = TextEditingController();
  final searchBoxZoneController = TextEditingController();

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      print('launcher success');

      await launch(url);
    } else {
      print('launcher failed');

      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    addressTitleFocus.dispose();
    addressCommentFocus.dispose();
   addressDescriptionFocus.dispose();
   cityFocus.dispose();
   zoneFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {

    try{
      getAddressData();

    }
    catch(e){
      ComFunctions.showToast(color: Colors.red , text: "Something went wrong please try again".tr());
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
      child: BlocConsumer<EditProfileBloc , EditProfileStates>(
        builder: (context , state){
          if(state is EditLoading){
            return CreateAddAddressScreen(
              loading: true, editProfileBloc: BlocProvider.of<EditProfileBloc>(context)

            );
          }
         else if(state is EditError){
            return CreateAddAddressScreen(
              loading: false ,
              editProfileBloc: BlocProvider.of<EditProfileBloc>(context)
            );
          }
          return CreateAddAddressScreen(
            loading: false,
            editProfileBloc: BlocProvider.of<EditProfileBloc>(context)

          );
        },
        listener: (context,state){
          if (state is EditSuccess){
           Navigator.pop(context);
            widget.addressBloc.add(GetAddress());

          }
          else if (state is EditError){
            if(state.error == 'TIMEOUT'){

              GeneralHandler.handleNetworkError(context);

            }
            else if(state.error == "invalidToken"){
              GeneralHandler.handleInvalidToken(context);
            }
            else if (state.error == "general"){
              GeneralHandler.handleGeneralError(context);
            }
            else if (state.error == 'needUpdate'){
              GeneralHandler.handleNeedUpdateState(context);
            }else {

              _onWidgetDidBuild(context, () {
                _drawerKey.currentState!.showSnackBar(
                  SnackBar(
                    content: Container(
                      height: (state.errorList?.length ??0 )*30,
                      child: ListView.builder(
                          itemCount: state.errorList?.length ??0 ,
                          itemBuilder:(context , i){
                           return Text(state.errorList?[i] ?? "");
                          } ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            }
          }
        },
      ),
    );
  }
  Widget CreateAddAddressScreen({required bool loading , EditProfileBloc? editProfileBloc}){
    return Scaffold(
      key: _drawerKey,
      backgroundColor: Constants.clientBackgroundGrey,
      body: Column(children: [
        const ClientAppBar(),
        Expanded(
          child: Form(
            key: _formKey,
            child: Container(
                color: Constants.clientBackgroundGrey,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: screenWidth! * 0.03,
                      left: screenWidth! * 0.03,
                      top: screenHeight! * 0.01),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        Padding(
                          padding:
                          EdgeInsets.symmetric(horizontal: screenWidth! * 0.015),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/new-address.svg",
                                    placeholderBuilder: (context) =>
                                        CustomLoading(),
                                    height: 38.0,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'New address'.tr(),
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),

                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight!*0.05,),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            children: [
                              Container(
                                height: screenHeight! * 0.06,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    // TODO: Change this drop down button to the dropDownSearch package.
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<AddressTitleAndIcon>(
                                          items: listAddressTitle
                                              .map((AddressTitleAndIcon dropDownStringItem) {
                                            return DropdownMenuItem<AddressTitleAndIcon>(
                                              value: dropDownStringItem,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                                    child: dropDownStringItem.icon,
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    dropDownStringItem.title!.tr(),
                                                    style: TextStyle(
                                                        color:Colors.black87, fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (AddressTitleAndIcon? newValue) {

                                              _currentSelectedAddressTitle = newValue;
                                              print(_currentSelectedAddressTitle?.title);
                                              if(_currentSelectedAddressTitle!.title == 'Other' ||_currentSelectedAddressTitle!.title == 'آخر' ||_currentSelectedAddressTitle!.title == 'اخر' ){
                                                setState(() {
                                                  savedTitle = true ;
                                                  _addressTitleController.clear();
                                                });


                                              }else {
                                                setState(() {
                                                  _addressTitleController.text =_currentSelectedAddressTitle!.title!;
                                                  savedTitle = false ;
                                                });

                                              }

                                          },
                                          value: _currentSelectedAddressTitle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight!*0.02,),
                              savedTitle ?
                              Column(
                                children: [
                                  Container(
                                    child: TextFormField(
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'please add your address name'.tr();
                                        }
                                        if(value.length > 20){
                                          return 'max 20 characters'.tr();
                                        }
                                        return null;
                                      },
                                      decoration:
                                      kTextFieldDecoration2
                                          .copyWith(

                                          hintText:
                                          'Address name'.tr()),
                                      controller:
                                      _addressTitleController,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight!*0.02,),
                                ],
                              ) : Container(),


                              Container(
                                height: screenHeight! * 0.08,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 15),
                                        child: Text(
                                          'City'.tr(),
                                          style:
                                          TextStyle(fontSize: 14, color: Colors.black87),
                                        )),
                                    senderCities.length > 0 ?
                                    Expanded(
                                      child: DropdownSearch<ErCity?>(
                                        dropdownSearchDecoration: kTextFieldDecoration2.copyWith(
                                        ),
                                        searchBoxDecoration: kTextFieldDecoration.copyWith(
                                            hintText: "City name ..".tr(),
                                            suffixIcon: Icon(Icons.search)
                                        ),
                                        label: "",
                                        maxHeight: screenHeight!*0.8,
                                        items: senderCities,
                                        searchBoxController: searchBoxCityController,
                                        showSearchBox: true,
                                        selectedItem: _currentCitySelected,
                                        itemAsString: (ErCity? u) => u?.name?? "",
                                        emptyBuilder: (context , string){
                                          return Center(child: Text('No results'.tr()));
                                        },
                                        mode:Mode.BOTTOM_SHEET ,
                                        enabled: true,
                                        onChanged: (value){
                                          setState(() {
                                            _currentCitySelected = value;
                                            _currentZone = Neighborhoods();
                                          });
                                        },
                                        clearButton: Icon(Icons.close),
                                      ),
                                    ) : Container(),




                                    // Expanded(
                                    //   child: DropdownButtonHideUnderline(
                                    //     child: DropdownButtonFormField<ErCity>(
                                    //       decoration: InputDecoration.collapsed(hintText: ''),
                                    //       focusNode: cityFocus,
                                    //       onTap:(){
                                    //         FocusScope.of(context).requestFocus(zoneFocus);
                                    //       },
                                    //       items: widget.resourcesData.city.where((element) => element.send == "1" && element.neighborhoods.length > 0  ).toList()
                                    //           .map((ErCity dropDownStringItem) {
                                    //         return DropdownMenuItem<ErCity>(
                                    //           value: dropDownStringItem,
                                    //           child: Container(
                                    //             width: screenWidth*0.6,
                                    //             child: AutoSizeText(
                                    //               dropDownStringItem.name,
                                    //               style: TextStyle(
                                    //                   color: Colors.black87, fontSize: 15),
                                    //             ),
                                    //           ),
                                    //         );
                                    //       }).toList(),
                                    //       onChanged: (ErCity newValue) {
                                    //         setState(() {
                                    //           _currentCitySelected = newValue;
                                    //           _currentZone = _currentCitySelected.neighborhoods.first;
                                    //         });
                                    //       },
                                    //       value: _currentCitySelected,
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight!*0.02,),

                              Container(
                                height: screenHeight! * 0.08,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [

                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        'Neighborhood'.tr(),
                                        style:
                                        TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ),
                                    senderCities.length > 0 ?
                                    Expanded(
                                      child: DropdownSearch<Neighborhoods?>(
                                        dropdownSearchDecoration: kTextFieldDecoration2.copyWith(
                                            hintText: ""
                                        ),
                                        searchBoxDecoration: kTextFieldDecoration.copyWith(
                                            hintText: "Neighborhood name..".tr(),
                                            suffixIcon: Icon(Icons.search)
                                        ),
                                        label: "",
                                        maxHeight: screenHeight!*0.8,
                                        items: _currentCitySelected?.neighborhoods,
                                        searchBoxController: searchBoxZoneController,
                                        showSearchBox: true,
                                        selectedItem: _currentZone,
                                        itemAsString: (Neighborhoods? u) => u?.name ?? "",
                                        emptyBuilder: (context , string){
                                          return Center(child: Text('No results'.tr()));
                                        },
                                        mode:Mode.BOTTOM_SHEET ,
                                        enabled: true,
                                        onChanged: (value){
                                          setState(() {
                                            _currentZone = value;
                                          });
                                        },
                                        clearButton: Icon(Icons.close),
                                      ),
                                    ) : Container(),
                                    // Expanded(
                                    //   child: DropdownButtonHideUnderline(
                                    //
                                    //     child: DropdownButtonFormField<Neighborhoods>(
                                    //       decoration: InputDecoration.collapsed(hintText: ''),
                                    //       focusNode: zoneFocus,
                                    //       items: _currentCitySelected.neighborhoods
                                    //           .map((Neighborhoods dropDownStringItem) {
                                    //         return DropdownMenuItem<Neighborhoods>(
                                    //           value: dropDownStringItem,
                                    //           child: Container(
                                    //             width: screenWidth*0.5,
                                    //             child: AutoSizeText(
                                    //               dropDownStringItem.name,
                                    //               style: TextStyle(
                                    //                   color: Colors.black87, fontSize: 15),
                                    //             ),
                                    //           ),
                                    //         );
                                    //       }).toList(),
                                    //       onChanged: (Neighborhoods newValue) {
                                    //         setState(() {
                                    //           _currentZone = newValue;
                                    //         });
                                    //       },
                                    //       value: _currentZone,
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),

                              SizedBox(height: screenHeight!*0.02,),
                              locationSelected ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL(mapUrlGeneral!);
                                    },
                                    child: Container(
                                      width: screenWidth!*0.7,
                                      height: screenHeight! * 0.06,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Color(0xFF56D340), width: 2),
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Image.asset(
                                              "assets/images/GOOGLE MAP ICON.png",
                                              // height: 18.0,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Saved Location'.tr(),
                                            style: TextStyle(
                                              color: Color(0xFF56D340),
                                              fontSize: 17,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(icon: Icon(Icons.delete_forever_outlined , color: Color(0xFFF4693F),), onPressed: (){
                                    setState(() {
                                      locationSelected = false ;
                                      mapUrlGeneral = '';
                                      _addressDescriptionController.clear();
                                    });

                                  })
                                ],
                              ) :
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlacePicker(
                                        apiKey: Constants.googleMabiApiKey,   // Put YOUR OWN KEY here.
                                        onPlacePicked: (result) {
                                          Navigator.of(context).pop();
                                        },
                                        // initialPosition: LatLng(Constants.latitude, Constants.longitude),
                                        initialPosition: LatLng(21.4858, 39.1925),
                                        strictbounds: true,
                                        onGeocodingSearchFailed: (e){

                                        },
                                        enableMapTypeButton: false,
                                        autocompleteRadius: 800000,
                                        selectInitialPosition: true,
                                        searchForInitialValue: false,
                                        useCurrentLocation: true,
                                        onAutoCompleteFailed: (e){
                                        },
                                        autocompleteLanguage:"ar",
                                        selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
                                          return isSearchBarFocused
                                              ? Container()
                                              : FloatingCard(
                                            bottomPosition: 40.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                            leftPosition: 10.0,
                                            rightPosition: 10.0,
                                            width: 500,
                                            elevation: 5,
                                            borderRadius: BorderRadius.circular(12.0),
                                            child:
                                            Padding(
                                              padding: EdgeInsets.only(top: 10, bottom: 10),
                                              child: selectedPlace != null ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(2.0),
                                                    child: Text(
                                                      selectedPlace.formattedAddress!,
                                                      style: TextStyle(fontSize: 18),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextButton(
                                                    child: Text('Save'.tr()),
                                                    onPressed: () {
                                                      setState(() {
                                                        _pickedLocation = selectedPlace;
                                                        locationSelected = true ;
                                                        _addressDescriptionController.text = selectedPlace.formattedAddress.toString();
                                                        mapUrlGeneral = 'https://www.google.com/maps/search/?api=1&query=${_pickedLocation!.geometry!.location.lat},${_pickedLocation!.geometry!.location.lng}';
                                                      });
                                                      Navigator.of(context).pop();

                                                    },
                                                  ),
                                                ],
                                              )
                                                  : Center(child: CustomLoading()),
                                            ),
                                          );
                                        }, centerForSearching: Constants.sauidArabia,
                                      ),
                                    ),
                                  );

                                  // LocationResult result = await Pick(
                                  //   context,
                                  //   Constants.googleMabiApiKey,
                                  //   automaticallyAnimateToCurrentLocation: true,
                                  //   myLocationButtonEnabled: true,
                                  //   layersButtonEnabled: true,
                                  //   initialCenter: LatLng(21.4858, 39.1925),
                                  //   countries: ['SA'],
                                  //   desiredAccuracy: LocationAccuracy.best,
                                  //   hintText: EasyLocalization.of(context).locale == Locale("en") ? "search" : "البحث",
                                  //   language:EasyLocalization.of(context).locale == Locale("en") ? "en" : 'ar',
                                  //
                                  // );
                                  // print("result = $result");
                                  // setState(() {
                                  //   if(result != null){
                                  //     _pickedLocation = result;
                                  //     locationSelected = true ;
                                  //     _addressDescriptionController.text = _pickedLocation.address;
                                  //     mapUrlGeneral = 'https://www.google.com/maps/search/?api=1&query=${_pickedLocation.latLng.latitude},${_pickedLocation.latLng.longitude}';
                                  //
                                  //   }
                                  //   // else{
                                  //   //   locationSelected = false ;
                                  //   //   mapUrlGeneral = '';
                                  //   //
                                  //   // }
                                  //
                                  //
                                  // });
                                },
                                child: Container(
                                  width: screenWidth,
                                  height: screenHeight! * 0.06,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Color(0xFFf79b7f), width: 2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Image.asset(
                                          "assets/images/GOOGLE MAP ICON.png",
                                          // height: 18.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Position on Google Maps'.tr(),
                                        style: TextStyle(
                                          color: Color(0xFFF4693F),
                                          fontSize: 17,
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: 2,
                                      // ),
                                      // Text(
                                      //   '(required)'.tr(),
                                      //   style: TextStyle(
                                      //     color: Color(0xFFF4693F),
                                      //     fontSize: 11,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight!*0.02,),
                              _addressDescriptionController.text.isNotEmpty ?
                              Padding(
                                padding: EdgeInsets.only(bottom: screenHeight!*0.02),
                                child: Container(
                                    width: screenWidth,
                                    height: screenHeight! * 0.06,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: AutoSizeText("${_addressDescriptionController.text}",
                                        maxLines: 3,),
                                    )
                                ),
                              ): Container(),
                              // TextFormField(
                              //   maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              //   keyboardType: TextInputType.multiline,
                              //   maxLines: 4,// when user presses enter it will adapt to it
                              //
                              //   // validator: (String value) {
                              //   //   if (value.isEmpty) {
                              //   //     return 'please add your address description'.tr();
                              //   //   }
                              //   //   return null;
                              //   // },
                              //   decoration:
                              //   kTextFieldDecoration2
                              //       .copyWith(
                              //       hintText:
                              //       'Write the address'.tr()),
                              //   controller:
                              //   _addressDescriptionController,
                              // ),
                              // SizedBox(height: screenHeight!*0.02,),


                           loading ?   Padding(
                             padding: const EdgeInsets.all(5.0),
                             child: Center(
                               child: CustomLoading(),
                             ),
                           ) : ButtonTheme(
                             minWidth: screenWidth!,
                             height: 50,
                             child: FlatButton(
                                 shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12.0),),
                                 color: Constants.blueColor,
                                 textColor: Colors.white,
                                 child: Text(
                                   'Save Address'.tr(),
                                   style: TextStyle(
                                     fontSize: 17,
                                   ),
                                 ),
                                 onPressed: ()async {
                                        if (_formKey.currentState!.validate()) {
                                          if(_currentZone?.id == null || _currentCitySelected?.id == null  ){
                                            _onWidgetDidBuild(context, () {
                                              _drawerKey.currentState!.showSnackBar(
                                                SnackBar(
                                                  content: Text('please select the city and the neighborhood'.tr() , style: TextStyle(
                                                      color: Colors.white
                                                  ),),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            });

                                          }else {
                                            if (widget.addresses == null) {
                                              if(mapUrlGeneral == '' || locationSelected == false){
                                                _onWidgetDidBuild(context, () {
                                                  _drawerKey.currentState!.showSnackBar(
                                                    SnackBar(
                                                      content: Text('please select the location on google map'.tr() , style: TextStyle(
                                                          color: Colors.white
                                                      ),),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                });
                                              }
                                              else {
                                                bool isUserConnected = await NetworkUtilities.isConnected();
                                                if (isUserConnected == true) {
                                                  widget.addressList!.add(Addresses(
                                                    comment: _currentSelectedAddressTitle!.title,
                                                    city: _currentZone!.id,
                                                    description:
                                                    _addressDescriptionController
                                                        .text,
                                                    map: locationSelected
                                                        ? mapUrlGeneral
                                                        : '',
                                                    title: _addressTitleController
                                                        .text,
                                                    // icon: _currentSelectedAddressTitle.icon,

                                                  ));
                                                }


                                                editProfileBloc!.add(AddAddress(
                                                  // lat: _pickedLocation.latLng.latitude.toString(),
                                                  // long: _pickedLocation.latLng.longitude.toString(),
                                                    cityName: _currentCitySelected!.name,
                                                    addressList:
                                                    widget.addressList));

                                              }

                                            }
                                            else {
                                              if(mapUrlGeneral == '' || locationSelected == false){

                                                _onWidgetDidBuild(context, () {
                                                  _drawerKey.currentState!.showSnackBar(
                                                    SnackBar(
                                                      content: Text('please select the location on google map'.tr() , style: TextStyle(
                                                          color: Colors.white
                                                      ),),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                });

                                              }else {
                                                widget.addresses!.city =
                                                    _currentZone!.id;
                                                widget.addresses!.map =
                                                    mapUrlGeneral;
                                                widget.addresses!.comment = _currentSelectedAddressTitle!.title;
                                                widget.addresses!.title =
                                                    _addressTitleController.text;
                                                widget.addresses!.description =
                                                    _addressDescriptionController
                                                        .text;
                                                widget.addresses!.key = _currentSelectedAddressTitle!.title;
                                                widget.addresses!.icon = _currentSelectedAddressTitle!.icon;
                                                editProfileBloc!.add(AddAddress(addressList: widget.addressList));

                                              }


                                            }
                                          }


                                        }
                                      }),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ]),
    );
  }
  void _onWidgetDidBuild(BuildContext context, Function callback) {

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }
}

class AddressTitleAndIcon extends Equatable {
  String? title ;
  Icon? icon ;

  AddressTitleAndIcon({this.icon , this.title});
@override
List<Object?> get props => [title, icon ];



}
