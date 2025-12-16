abstract class LocationCheckEvents {}

class LocationCheck extends LocationCheckEvents {}

class SetTheState extends LocationCheckEvents {
  bool? permissionGranted ;
  SetTheState({this.permissionGranted});
}