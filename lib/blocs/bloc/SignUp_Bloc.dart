

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xturbox/blocs/events/LoginEvents.dart';
import 'package:xturbox/blocs/events/SignUp_Events.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/states/SignUp_States.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/signUpData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';
import 'LoginBloc.dart';
import 'authentication_bloc.dart';

class SignUpBloc extends Bloc<SignUpEvents , SignUpStates>{
  SharedPreferences? preferences ;
  // final UserRepository userRepository;
  // final AuthenticationBloc authenticationBloc ;
  // final LoginBloc loginBloc ;

  SignUpBloc() : super(SignUpInitial());

  UserRepository userRepository = UserRepository();
 LoginBloc loginBloc = LoginBloc();
  @override
  Stream<SignUpStates> mapEventToState(SignUpEvents event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield SignUpFailure(
          errors: ['please check your internet connection and try again']
      );
      return;
    }

    if(event is RegisterButtonPressed){
      bool isUserConnected = await NetworkUtilities.isConnected();
      if (isUserConnected == false) {
        yield SignUpFailure(
            error: "TIMEOUT",
            failedEvents: event
        );
      }else{
        yield SignUpLoading();
        final MyResponseModel myResponseModel = await UserRepository.registerFunction(
            password: event.password,  phone: event.phone, name: event.name ,firstName: event.firstName , lastName: event.lastName ,
            nationalId: event.national_id,vatNumber: event.vatNumber , companyName: event.companyName
        );

        if(myResponseModel.responseData && myResponseModel.statusCode == 201){
          userRepository.persistPhone(username: event.phone);
          userRepository.persistPassword(password: event.password);
          userRepository.persistName(name:event.name);




          yield SignUpSuccess();

        }
        else if (myResponseModel.statusCode == 403){
          yield SignUpFailure(
              error: "errors",
          );

        }
        else if(myResponseModel.statusCode == 505) {
          yield SignUpFailure(
              error: "needUpdate",
          );

        }
        else {
          yield SignUpFailure(errors: myResponseModel.errorsList , error: 'error',failedEvents: event);
        }
      }

      }

    }
  }

