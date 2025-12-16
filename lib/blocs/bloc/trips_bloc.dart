import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/trips_events.dart';
import 'package:xturbox/blocs/states/trips_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class TripsBloc extends Bloc<TripsEvents , TripsStates> {
  TripsBloc() : super(TripsInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<TripsStates> mapEventToState(TripsEvents event)async* {
    if(event is GetTrip){
      yield*  _handleGetTrip(event);
    }

  }

  Stream<TripsStates> _handleGetTrip(GetTrip event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield TripsError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield TripsLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.getLastTrip();

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){

        yield TripsLoaded (
            tripModel: myResponseModel.responseData
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
          yield*  _handleGetTrip(event);
        }else{
          yield TripsError(
              error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield TripsError(
            error: "needUpdate",
        );

      }
      else {

        yield TripsError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
}
