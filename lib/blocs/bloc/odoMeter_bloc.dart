import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/odoMeter_events.dart';
import 'package:xturbox/blocs/states/odoMeter_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class ODOMeterBloc extends Bloc<ODOMeterEvents , ODOMeterStates> {
  ODOMeterBloc() : super(ODOMeterInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<ODOMeterStates> mapEventToState(ODOMeterEvents event)async* {
    if(event is SetODOMeterValue){
      yield*  _handleSetODOMeter(event);
    }
  }

  Stream<ODOMeterStates> _handleSetODOMeter(SetODOMeterValue event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ODOMeterError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield ODOMeterLoading();
      MyResponseModel myResponseModel = await EventsApiCaptain.setMeterValue(type: event.type, value: event.value,id: event.id);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){
       if(SavedData.profileDataModel.meterYesterday?.end.toString() == "0"){
         print('yesterday case');
         SavedData.profileDataModel.meterYesterday = myResponseModel.responseData ;
       }else{
         print('today case');
         SavedData.profileDataModel.meter = myResponseModel.responseData ;
       }
        yield ODOMeterSetSuccess (
          meter: myResponseModel.responseData
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
          yield*  _handleSetODOMeter(event);
        }else{
          yield ODOMeterError(
              error: "invalidToken",
              failedEvent: event
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield ODOMeterError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else {

        yield ODOMeterError(
            failedEvent: event,
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
}
