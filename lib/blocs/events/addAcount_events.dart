abstract class AddAccountEvents {}


class AddingAccount extends AddAccountEvents {
  String phone ;
  String password ;
  AddingAccount({required this.phone , required this.password });
}