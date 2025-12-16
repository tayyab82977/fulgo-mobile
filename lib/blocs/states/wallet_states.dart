

abstract class WalletStates {}


class WalletInitial extends WalletStates {}
class WalletLoading extends WalletStates {}
class RequestSuccess extends WalletStates {}

class WalletSetSuccess extends WalletStates {
  List<double> balanceWallet ;
  WalletSetSuccess({required this.balanceWallet});
}
class WalletError extends WalletStates {
  List<String>? errorList ;
  String? error;
  WalletError({this.errorList , this.error});
}