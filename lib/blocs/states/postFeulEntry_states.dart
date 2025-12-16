
abstract class PostFuelEntryStates {}


class PostFuelEntryInitial extends PostFuelEntryStates{}
class PostFuelEntryLoading extends PostFuelEntryStates{}

class PostFuelEntryAddSuccess extends PostFuelEntryStates{}
class PostFuelEntryError extends PostFuelEntryStates{

  String? error ;
  List<String>? errorList ;

  PostFuelEntryError({this.errorList , this.error});
}