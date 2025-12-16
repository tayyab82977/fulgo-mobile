import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/paymentMethod_events.dart';
import 'package:xturbox/blocs/states/paymentMethod_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvents , PaymentMethodStates> {
  PaymentMethodBloc() : super(PaymentMethodInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<PaymentMethodStates> mapEventToState(PaymentMethodEvents event)async* {
    if(event is GetPaymentMethod){

      yield*  _handleFetchingPaymentMethod(event);
    }


  }

  Stream<PaymentMethodStates> _handleFetchingPaymentMethod(
      PaymentMethodEvents event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PaymentMethodError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield PaymentMethodLoading();
      MyResponseModel myResponseModel = await EventsAPIs.getPaymentMethods();
      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        yield PaymentMethodLoaded (
            clientBalanceModel: myResponseModel.responseData
        );
      }

      // else if (myResponseModel.statusCode == 204){
      //   yield PaymentMethodLoaded (
      //       PaymentMethodListsModel: PaymentMethodListsModel.empty(growable: true)
      //   );
      // }
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
          yield*  _handleFetchingPaymentMethod(event);
        }else{
          yield PaymentMethodError(
              error: "invalidToken",
              errorsList: myResponseModel.errorsList
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield PaymentMethodError(
            error: "needUpdate",
            errorsList: myResponseModel.errorsList
        );

      }
      else {

        yield PaymentMethodError(
            errorsList: myResponseModel.errorsList,
            error: 'error'
        );
      }
    }

  }


}