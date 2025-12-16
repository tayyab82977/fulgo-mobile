abstract class NationalIdEvents {}


class SetNationalIdValue extends NationalIdEvents {
  String value ;
  SetNationalIdValue({required this.value});
}