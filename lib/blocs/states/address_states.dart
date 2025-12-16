import 'package:xturbox/blocs/events/address_events.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';

abstract class AddressStates {}


class AddressInitial extends AddressStates {}
class AddressLoading extends AddressStates {}
class AddressLoaded extends AddressStates {
  List <Addresses>? addressList ;
  AddressLoaded({this.addressList});
}
class AddressError extends AddressStates {
  AddressEvents? failedEvent ;
  String? error ;
  List<String>? errorsList ;
  AddressError({this.failedEvent,this.error,this.errorsList});
}

class DashboardEditAddressSuccess extends AddressStates {}
class ApplicationUpdated extends AddressStates {}
class InValidToken extends AddressStates {}
class NoInternet extends AddressStates {}
