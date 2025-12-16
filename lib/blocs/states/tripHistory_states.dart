import 'package:xturbox/data_providers/models/tripModel.dart';

abstract class TripHistoryStates {}


class TripHistoryInitial extends TripHistoryStates {}
class TripHistoryLoading extends TripHistoryStates {}
class TripHistoryLoaded extends TripHistoryStates {
  List<TripModel> list ;
  TripHistoryLoaded({required this.list});
}
class TripHistoryError extends TripHistoryStates {
  String? error ;
  List<String>? errorList ;
  TripHistoryError({this.errorList,this.error});
}