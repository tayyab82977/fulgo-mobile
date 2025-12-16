abstract class ResetPasswordEvents {}



class GetCode extends ResetPasswordEvents {
  String? phone ;
  GetCode({this.phone});
}

class ChangeMyPassword extends ResetPasswordEvents {
  String? password ;
  String? passConf ;
  String? code ;
  String? phone;

  ChangeMyPassword({this.code , this.password , this.phone , this.passConf});

}
