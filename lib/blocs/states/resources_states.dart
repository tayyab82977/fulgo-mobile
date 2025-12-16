import 'package:xturbox/blocs/events/resources_events.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';

abstract class ResourcesStates {}


class ResourcesInitial extends ResourcesStates {}
class ResourcesLoading extends ResourcesStates {}
class ApplicationUpdated extends ResourcesStates {}
class InValidToken extends ResourcesStates {}
class ResourcesLoaded extends ResourcesStates {

  ResourcesData? resourcesData ;
  ResourcesLoaded({this.resourcesData});
}

class ResourcesError extends ResourcesStates {
  String? error ;
  ResourcesEvents? failedEvent ;
  ResourcesError({this.error,this.failedEvent});
}