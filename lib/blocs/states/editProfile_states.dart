import 'package:xturbox/blocs/events/editProfile_events.dart';
import 'package:xturbox/ui/Client/editProfile.dart';

abstract class EditProfileStates {}


class EditInitial extends EditProfileStates{}
class EditLoading extends EditProfileStates{}
class EditSuccess extends EditProfileStates{}
class EditPhone extends EditProfileStates{}
class InValidToken extends EditProfileStates{}
class ApplicationUpdated extends EditProfileStates{}
class EditError   extends EditProfileStates{
  String? error ;
  List<String>? errorList ;
  EditProfileEvents? failedEvent ;
  EditError({this.errorList,this.error,this.failedEvent});
}