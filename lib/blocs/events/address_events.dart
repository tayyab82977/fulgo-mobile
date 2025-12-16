import 'package:xturbox/data_providers/models/ProfileDataModel.dart';

abstract class AddressEvents {}


class GetAddress extends AddressEvents {}
class DeleteAddress extends AddressEvents {
  List<Addresses>? adressList ;
  DeleteAddress({this.adressList});
}
class AddressGenerateError extends AddressEvents{}

