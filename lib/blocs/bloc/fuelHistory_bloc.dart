import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/fuelHistory_events.dart';
import 'package:xturbox/blocs/states/fuelHistory_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';
import 'authentication_bloc.dart';

class FuelHistoryBloc extends Bloc<FuelHistoryEvents , FuelHistoryStates> {
  FuelHistoryBloc() : super(FuelHistoryInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<FuelHistoryStates> mapEventToState(FuelHistoryEvents event)async* {
    if(event is GetFuelHistory){

      yield*  _handleFetchingFuelHistory(event);
    }


  }

  Stream<FuelHistoryStates> _handleFetchingFuelHistory(
      FuelHistoryEvents event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield FuelHistoryError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield FuelHistoryLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.getFuelHistory();

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        yield FuelHistoryLoaded (
            list: myResponseModel.responseData
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
          yield*  _handleFetchingFuelHistory(event);
        }else{
          yield FuelHistoryError(
              error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield FuelHistoryError(
            error: "needUpdate",
        );

      }
      else {

        yield FuelHistoryError(
            error: 'error',
            errorList: myResponseModel.errorsList
        );
      }
    }

  }


}