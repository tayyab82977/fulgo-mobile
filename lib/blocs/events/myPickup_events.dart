import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class MyPickupEvents {}


class GetMyPickup extends MyPickupEvents {}
class BulkStoreOut extends MyPickupEvents {

  List<OrdersDataModelMix> list ;
  BulkStoreOut({required this.list});

}
class MyPickupEventsGenerateError extends MyPickupEvents{}

