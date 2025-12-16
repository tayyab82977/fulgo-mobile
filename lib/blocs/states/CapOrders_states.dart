abstract class CapOrdersStates {}


class CapOrdersInitial extends CapOrdersStates{}
class CapOrdersLoading extends CapOrdersStates{}
class CapOrdersLoaded  extends CapOrdersStates{}
class CapOrdersFailure extends CapOrdersStates{
  String? error ;
  CapOrdersFailure({this.error});

}
class ApplicationUpdated extends CapOrdersStates{}
class InValidToken extends CapOrdersStates{}