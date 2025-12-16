import 'package:xturbox/blocs/events/postOrder_events.dart';

abstract class PostOrdersStates {}


class PostOrderInitial extends PostOrdersStates{}
class PostOrderLoading extends PostOrdersStates{}
class PostOrderSuccess extends PostOrdersStates{}
class EditOrderSuccess extends PostOrdersStates{}
class PopLoading extends PostOrdersStates{}
class ApplicationUpdated extends PostOrdersStates{}
class InValidToken extends PostOrdersStates{}
class PostOrderError extends PostOrdersStates{
  List<String?>? errors ;
  String? error ;
  PostOrdersEvent? failedEvent ;

  PostOrderError({this.errors,this.error , this.failedEvent});
}