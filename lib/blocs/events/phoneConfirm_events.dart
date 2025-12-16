
abstract class PhoneConfirmEvents {}

class AskForSMS extends PhoneConfirmEvents{
  final String? phone;
  final String? password;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? nationalId;
  final String? companyName;
  final String? vatNumber;
  AskForSMS({this.phone,this.password,this.firstName,this.name,this.lastName,this.nationalId,this.vatNumber,this.companyName});
}
class ConfirmationReset extends PhoneConfirmEvents{}

class CodeConfirmation extends PhoneConfirmEvents{
  final String? phone;
  final String? code;
  CodeConfirmation({this.phone , this.code});
}