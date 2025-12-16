import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {

  geo.Location? _location ;
  geo.Location? get location => _location ;

  LatLng? _locationPosition ;
  LatLng? get locationPosition => _locationPosition ;


  bool locationServiceActive = true ;

  locationProvider(){
    _location = geo.Location() ;


  }

  getUserLocation() async{
   bool? _serviceEnabled = false ;
   _serviceEnabled = await location?.serviceEnabled() ;

   if(!(_serviceEnabled ?? false)){
     _serviceEnabled = await location?.requestService() ;
     if(!(_serviceEnabled ?? true)){

       geo.PermissionStatus? permissionStatus = await location?.hasPermission();

       if(permissionStatus == geo.PermissionStatus.denied ){

         permissionStatus = await location?.requestPermission();

         if(permissionStatus == geo.PermissionStatus.granted ){
           return ;
         }

       }


       location?.onLocationChanged.listen((geo.LocationData currentLocation) {

          _locationPosition = LatLng(currentLocation.latitude ?? 0, currentLocation.longitude ?? 0) ;
       });
       print(_locationPosition);

       notifyListeners();

     }



   }





  }






}