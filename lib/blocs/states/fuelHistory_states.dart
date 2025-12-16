import 'package:xturbox/data_providers/models/fuel.dart';

abstract class FuelHistoryStates {}


class FuelHistoryInitial extends FuelHistoryStates {}
class FuelHistoryLoading extends FuelHistoryStates {}
class FuelHistoryLoaded extends FuelHistoryStates {
  List<FuelEntryModel> list ;
  FuelHistoryLoaded({required this.list});
}
class FuelHistoryError extends FuelHistoryStates {
  String? error ;
  List<String>? errorList ;
  FuelHistoryError({this.errorList,this.error});
}