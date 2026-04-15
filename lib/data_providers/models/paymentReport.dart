import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/paymentCalculations.dart';

import 'ProfileDataModel.dart';

class PaymentReport {

  double? tote ;

  List<Credit>? creditList ;

  List<OrdersDataModelMix>? newAcceptedList;

  PaymentReport({this.tote , this.creditList , this.newAcceptedList});

}