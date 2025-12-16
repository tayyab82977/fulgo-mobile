abstract class ClientCreditEvents {}


class GetClientCredit2 extends ClientCreditEvents {
  String? id ;
  GetClientCredit2({this.id});
}

class GetClientCredit2GenerateError extends ClientCreditEvents{}

