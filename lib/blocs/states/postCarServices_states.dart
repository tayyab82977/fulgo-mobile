abstract class PostCarSrvStates {}


class PostCarSrvInitial extends PostCarSrvStates{}
class PostCarSrvLoading extends PostCarSrvStates{}

class PostCarSrvAddSuccess extends PostCarSrvStates{}
class PostCarSrvError extends PostCarSrvStates{

  String? error ;
  List<String>? errorList ;

  PostCarSrvError({this.errorList , this.error});
}