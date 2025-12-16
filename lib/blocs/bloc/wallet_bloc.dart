import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/wallet_events.dart';
import 'package:xturbox/blocs/states/wallet_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class WalletBloc extends Bloc<WalletEvents , WalletStates> {
  WalletBloc() : super(WalletInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<WalletStates> mapEventToState(WalletEvents event)async* {
    if(event is TransferRequest){
      yield*  _handleTransferRequest(event);
    }

    if(event is TransferConfirm){
      yield*  _handleTransferConfirm(event);
    }
  }

  Stream<WalletStates> _handleTransferRequest(TransferRequest event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield WalletError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield WalletLoading();
      MyResponseModel myResponseModel = await EventsAPIs.transferRequest( value: event.value);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){
        yield RequestSuccess();
      }
      else if (myResponseModel.statusCode == 403){

        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel token = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if(token.responseData != null && token.statusCode == 201 || token.statusCode == 200){
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: token.responseData);

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield*  _handleTransferRequest(event);
        }else{
          yield WalletError(
              error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield WalletError(
            error: "needUpdate",
        );

      }
      else {

        yield WalletError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
  Stream<WalletStates> _handleTransferConfirm(TransferConfirm event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield WalletError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield WalletLoading();
      MyResponseModel myResponseModel = await EventsAPIs.transferConfirm(code: event.code, value: event.value);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){
        SavedData.profileDataModel.amount = myResponseModel.responseData?[0] ?? SavedData.profileDataModel.amount;
        SavedData.profileDataModel.wallet = myResponseModel.responseData?[1] ?? SavedData.profileDataModel.wallet ;
        yield WalletSetSuccess (
          balanceWallet: myResponseModel.responseData
        );
      }
      else if (myResponseModel.statusCode == 403){

        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel token = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if(token.responseData != null && token.statusCode == 201 || token.statusCode == 200){
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: token.responseData);

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield*  _handleTransferConfirm(event);
        }else{
          yield WalletError(
              error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield WalletError(
            error: "needUpdate",
        );

      }
      else {

        yield WalletError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
}
