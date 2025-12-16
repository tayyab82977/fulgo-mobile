abstract class DrawerClientStates {}


class DrawerClientInitial extends DrawerClientStates {}
class DrawerClientLoading extends DrawerClientStates {}
class DrawerClientSuccess extends DrawerClientStates {}
class DrawerClientError extends DrawerClientStates {
  String? error ;
  DrawerClientError({this.error});
}
