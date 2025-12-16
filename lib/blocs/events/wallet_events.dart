abstract class WalletEvents {}


class TransferConfirm extends WalletEvents {
  String value ;
  String code ;
  TransferConfirm({required this.value , required this.code});
}

class TransferRequest extends WalletEvents {
  String value ;
  TransferRequest({required this.value});
}