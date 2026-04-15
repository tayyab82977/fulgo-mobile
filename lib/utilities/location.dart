// import 'package:location/location.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as geo;

import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/utilities/Constants.dart';

class LocationServices {

  static Future<bool> checkLocationPermission() async {
    geo.Location location = geo.Location() ;

   bool _serviceEnabled = await location.serviceEnabled() ;
    geo.PermissionStatus? permissionStatus = await location.hasPermission();

    print(_serviceEnabled.toString() + " _serviceEnabled");
    print(permissionStatus.name + " permissionStatus");

    if(_serviceEnabled && permissionStatus == geo.PermissionStatus.granted){

      return true ;

    }else{

      return false ;

    }




  }


  static void getLiveLocation() async {
  UserRepository userRepository = UserRepository() ;

  String? token = await userRepository.getAuthToken();
  print('location function is on');

  geo.Location location = geo.Location() ;
  bool? _serviceEnabled = false ;
  _serviceEnabled = await location.serviceEnabled() ;
  location.enableBackgroundMode(enable: false);

  if(!_serviceEnabled){
    _serviceEnabled = await location.requestService() ;
    if(_serviceEnabled){

      geo.PermissionStatus? permissionStatus = await location.hasPermission();

      // if(permissionStatus == geo.PermissionStatus.denied ){
      //
      //   permissionStatus = await location?.requestPermission();
      //
      //   if(permissionStatus == geo.PermissionStatus.granted ){
      //     return ;
      //   }
      //
      // }

    }



    }
  print("live lcoation");
  geo.LocationData? locationData = await location.getLocation();
  EventsApiCaptain.postCaptainLocation(lat: locationData.latitude.toString() , long: locationData.longitude.toString() , token:token );
  print(locationData.longitude);
  print(locationData.latitude);




  }


}