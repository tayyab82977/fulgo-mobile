import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xturbox/data_providers/models/NationalAddreesModel.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/geoCodingDataModel.dart';

abstract class EditProfileEvents {}


class PutProfileRequest extends EditProfileEvents{
  final String? password;
  final String email ;
  final String name ;
  final String? id ;
  final String? firstName ;
  final String? lastName ;
  final String? phone2 ;
  final String national_id ;
  final String companyName ;
  final String vatNumber ;
  final String cer ;
  final bool? changeUsername ;

  PutProfileRequest({
    required this.id,
    required this.phone2,
    required this.password,
    required this.email,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.national_id,
    required this.changeUsername,
    required this.companyName,
    required this.cer,
    required this.vatNumber,



  });
}


class AddBank extends EditProfileEvents {
  String? id ;
  String? name ;
  String? bankName ;
  String? iban ;

  AddBank({this.iban , this.id , this.bankName , this.name});


}

class AddNationalAddress extends EditProfileEvents {
  NationalAddressModel nationalAddressModel ;

  AddNationalAddress({required this.nationalAddressModel});
}


class EditBank extends EditProfileEvents {
  String? id ;
  String? name ;
  String? bankName ;
  String? iban ;

  EditBank({this.iban , this.id , this.bankName , this.name});


}
class AddAddress extends EditProfileEvents {
  String? id ;
  List<Addresses>? addressList ;
  String? cityName ;
  String? lat ;
  String? long ;


  AddAddress({this.addressList , this.id, this.lat , this.long , this.cityName});


}

class EditProfileEventsGenerateError extends EditProfileEvents{}
