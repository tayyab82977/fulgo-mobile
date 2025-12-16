import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/violations_events.dart';
import 'package:xturbox/blocs/states/violations_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';
import 'authentication_bloc.dart';

class ViolationsBloc extends Bloc<ViolationsEvents , ViolationsStates> {
  ViolationsBloc() : super(ViolationsInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<ViolationsStates> mapEventToState(ViolationsEvents event)async* {
    if(event is GetViolations){

      yield*  _handleFetchingViolations(event);
    }


  }

  Stream<ViolationsStates> _handleFetchingViolations(
      ViolationsEvents event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ViolationsError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield ViolationsLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.getViolations();

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        yield ViolationsLoaded (
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
          yield*  _handleFetchingViolations(event);
        }else{
          yield ViolationsError(
            error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield ViolationsError(
          error: "needUpdate",
        );

      }
      else {

        yield ViolationsError(
            error: 'error',
            errorList: myResponseModel.errorsList
        );
      }
    }

  }


}