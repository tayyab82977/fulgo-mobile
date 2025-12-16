abstract class ODOMeterEvents {}


class SetODOMeterValue extends ODOMeterEvents {
  String type ;
  String value ;
  String? id ;
  SetODOMeterValue({required this.value , required this.type , this.id});
}