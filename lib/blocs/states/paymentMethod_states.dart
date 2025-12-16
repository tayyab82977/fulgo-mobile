import 'package:xturbox/data_providers/models/memberBalanceModel.dart';

abstract class PaymentMethodStates {}


class PaymentMethodInitial extends PaymentMethodStates {}
class PaymentMethodLoading extends PaymentMethodStates {}
class PaymentMethodLoaded extends PaymentMethodStates {
  ClientBalanceModel clientBalanceModel ;
  PaymentMethodLoaded({required this.clientBalanceModel});
}
class PaymentMethodError extends PaymentMethodStates {
  String? error ;
  List<String>? errorsList ;
  PaymentMethodError({this.errorsList,this.error});
}
