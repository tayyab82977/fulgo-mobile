import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/states/nationalId_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../events/nationalId_events.dart';
import 'authentication_bloc.dart';

class NationalIdBloc extends Bloc<NationalIdEvents , NationalIdStates> {
  NationalIdBloc() : super(NationalIdInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<NationalIdStates> mapEventToState(NationalIdEvents event)async* {
    if(event is SetNationalIdValue){
      yield*  _handleSetNationalId(event);
    }
  }

  Stream<NationalIdStates> _handleSetNationalId(SetNationalIdValue event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield NationalIdError(
          error: 'TIMEOUT');
      return;
    }
    else{
      print('hello from id bloc');
      yield NationalIdLoading();
      MyResponseModel myResponseModel = await EventsAPIs.EditProfile(national_id: event.value , onlyNational: true);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){
        yield NationalIdSetSuccess ();
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
          yield*  _handleSetNationalId(event);
        }else{
          yield NationalIdError(
              error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield NationalIdError(
            error: "needUpdate",
        );

      }
      else {

        yield NationalIdError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
}
