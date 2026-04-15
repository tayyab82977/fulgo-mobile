import 'package:get/get.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';

class AcceptedOrderController extends GetxController {
  
  var acceptedOrdersList = <OrdersDataModelMix>[].obs;
  var notAcceptedOrdersList = <OrdersDataModelMix>[].obs;

  void acceptOrder({
    required List<OrdersDataModelMix> accepted,
    required List<OrdersDataModelMix> notAccepted
  }) {
    acceptedOrdersList.value = accepted;
    notAcceptedOrdersList.value = notAccepted;
  }
}
