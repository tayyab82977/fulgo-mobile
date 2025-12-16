import 'package:xturbox/data_providers/models/fuel.dart';

abstract class PostCarSrvEvents {}


class PostCarSrv extends PostCarSrvEvents {
  FuelEntryModel fuelEntryModel ;
  PostCarSrv({required this.fuelEntryModel });
}
