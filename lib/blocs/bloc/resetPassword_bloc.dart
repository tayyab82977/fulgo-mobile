import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/resetPassword_events.dart';
import 'package:xturbox/blocs/states/resetPassword_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvents , ResetPasswordStates> {
  ResetPasswordBloc() : super(ResetPasswordInitial());

  @override
  Stream<ResetPasswordStates> mapEventToState(ResetPasswordEvents event)async* {


    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ResetPasswordError(
          error: 'TIMEOUT');
      return;
    }


    if (event is GetCode){

      yield* _handleGetCode(event);
    }

    if (event is ChangeMyPassword){

      yield* _handleChangeMyPassword(event);

    }
  }

  Stream<ResetPasswordStates> _handleGetCode(GetCode event)async*{


    yield ResetPasswordLoading();
    MyResponseModel myResponseModel = await EventsAPIs.getCode(phone: event.phone);
    if (myResponseModel.responseData){
      yield ResetPasswordCodeSent();
    }
    else{
      yield ResetPasswordError(error: 'codeNotSent' , errorList: myResponseModel.errorsList);

    }


  }

  Stream<ResetPasswordStates> _handleChangeMyPassword(ChangeMyPassword event)async*{
    UserRepository userRepository = UserRepository();
    yield ResetPasswordLoading();
    MyResponseModel myResponseModel = await EventsAPIs.changePassword(
      phone: event.phone,
      password: event.password,
      code: event.code
    );
    if (myResponseModel.responseData){
      await  userRepository.persistPhone(username: event.phone!);
      await userRepository.persistPassword(password: event.password!);

      final MyResponseModel myResponse = await UserRepository.LoginAPI(
        username: event.phone,
        password: event.password,
      );

      if(myResponse.responseData != null && myResponse.statusCode == 201 || myResponse.statusCode == 200){
        AuthenticationBloc authenticationBloc = AuthenticationBloc();

        await userRepository.persistToken(token: myResponse.responseData);

        SavedData.token = "Bearer " + myResponse.responseData.toString() ;
        authenticationBloc.add(LoggedIn(token: myResponse.responseData));

        yield ResetPasswordPasswordChanged();


      }else{

        yield ResetPasswordPasswordSemiChanged();

      }




    }else {
      yield ResetPasswordError(error: 'noChangePass', errorList: myResponseModel.errorsList);
    }

  }

}