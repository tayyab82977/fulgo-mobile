
import 'package:xturbox/data_providers/models/violation.dart';

abstract class ViolationsStates {}


class ViolationsInitial extends ViolationsStates {}
class ViolationsLoading extends ViolationsStates {}
class ViolationsLoaded extends ViolationsStates {
  List<ViolationModel> list ;
  ViolationsLoaded({required this.list});
}
class ViolationsError extends ViolationsStates {
  String? error ;
  List<String>? errorList ;
  ViolationsError({this.errorList,this.error});
}