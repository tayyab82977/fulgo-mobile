


import 'package:xturbox/data_providers/models/fuel.dart';

abstract class CarSrvHistoryStates {}


class CarSrvHistoryInitial extends CarSrvHistoryStates {}
class CarSrvHistoryLoading extends CarSrvHistoryStates {}
class CarSrvHistoryLoaded extends CarSrvHistoryStates {
  List<FuelEntryModel> list ;
  CarSrvHistoryLoaded({required this.list});
}
class CarSrvHistoryError extends CarSrvHistoryStates {
  String? error ;
  List<String>? errorList ;
  CarSrvHistoryError({this.errorList,this.error});
}