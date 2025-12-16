

import 'ProfileDataModel.dart';

class AddressesList {

List<Addresses>? addressesList ;
AddressesList({this.addressesList});

Map<String, dynamic> toJson() => <String, dynamic>{
  '"addresses"': addressesList,
};



}