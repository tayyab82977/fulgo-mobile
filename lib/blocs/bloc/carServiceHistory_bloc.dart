import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/carServiceHistory_events.dart';
import 'package:xturbox/blocs/states/carServiceHistory_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class CarSrvHistoryBloc extends Bloc<CarSrvHistoryEvents , CarSrvHistoryStates> {
  CarSrvHistoryBloc() : super(CarSrvHistoryInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<CarSrvHistoryStates> mapEventToState(CarSrvHistoryEvents event)async* {
    if(event is GetCarSrvHistory){

      yield*  _handleFetchingCarSrvHistory(event);
    }


  }

  Stream<CarSrvHistoryStates> _handleFetchingCarSrvHistory(
      CarSrvHistoryEvents event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield CarSrvHistoryError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield CarSrvHistoryLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.getCarSrvHistory();

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        yield CarSrvHistoryLoaded (
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
          var authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: token.responseData);

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield*  _handleFetchingCarSrvHistory(event);
        }else{
          yield CarSrvHistoryError(
            error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield CarSrvHistoryError(
          error: "needUpdate",
        );

      }
      else {

        yield CarSrvHistoryError(
            error: 'error',
            errorList: myResponseModel.errorsList
        );
      }
    }

  }


}