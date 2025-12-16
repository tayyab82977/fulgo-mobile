abstract class SwitchAccountEvents {}


class SwitchingAccount extends SwitchAccountEvents {
  String phone ;
  String password ;
  SwitchingAccount({required this.phone , required this.password });
}