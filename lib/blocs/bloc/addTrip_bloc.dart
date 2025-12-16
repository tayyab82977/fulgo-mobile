import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/addTrip_events.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';

import 'package:xturbox/blocs/states/addTrip_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class AddTripBloc extends Bloc<AddTripEvents , AddTripStates> {
  AddTripBloc() : super(AddTripInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<AddTripStates> mapEventToState(AddTripEvents event)async* {

    if(event is AddNewTrip){
      yield*  _handleAddNewTrip(event);

    }
    if(event is UpdateTripEnd){
      yield*  _handleUpdateTripEnd(event);
    }
  }

  Stream<AddTripStates> _handleAddNewTrip(AddNewTrip event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield AddTripError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield AddTripLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.createTrip(tripModel: event.tripModel);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){
        print('AddTripAdded from bloc');
        yield AddTripAdded(
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
          yield*  _handleAddNewTrip(event);
        }else{
          yield AddTripError(
            error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield AddTripError(
          error: "needUpdate",
        );

      }
      else {

        yield AddTripError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }

  Stream<AddTripStates> _handleUpdateTripEnd(UpdateTripEnd event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield AddTripError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield AddTripLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.setTripEnd(tripModel: event.tripModel);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){

        yield AddTripUpdated(
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
          yield*  _handleUpdateTripEnd(event);
        }else{
          yield AddTripError(
            error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield AddTripError(
          error: "needUpdate",
        );

      }
      else {

        yield AddTripError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
}
