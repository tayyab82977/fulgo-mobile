import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/tripHistory_events.dart';
import 'package:xturbox/blocs/states/tripHistory_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class TripHistoryBloc extends Bloc<TripHistoryEvents , TripHistoryStates> {
  TripHistoryBloc() : super(TripHistoryInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<TripHistoryStates> mapEventToState(TripHistoryEvents event)async* {
    if(event is GetTripHistory){

      yield*  _handleFetchingTripHistory(event);
    }


  }

  Stream<TripHistoryStates> _handleFetchingTripHistory(
      TripHistoryEvents event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield TripHistoryError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield TripHistoryLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.getAllTrips();

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        yield TripHistoryLoaded (
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
          yield*  _handleFetchingTripHistory(event);
        }else{
          yield TripHistoryError(
            error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield TripHistoryError(
          error: "needUpdate",
        );

      }
      else {

        yield TripHistoryError(
            error: 'error',
            errorList: myResponseModel.errorsList
        );
      }
    }

  }


}