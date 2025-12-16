
import 'package:xturbox/data_providers/models/fuel.dart';

abstract class PostFuelEntryEvents {}


class PostFuelEntry extends PostFuelEntryEvents {
  FuelEntryModel fuelEntryModel ;
  PostFuelEntry({required this.fuelEntryModel });
}


