
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/LoginBloc.dart';
import 'package:xturbox/blocs/bloc/dashboard_bloc.dart';
import 'package:xturbox/blocs/events/LoginEvents.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/blocs/events/phoneConfirm_events.dart';
import 'package:xturbox/blocs/states/phoneConfirm_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class PhoneConfirmBloc extends Bloc<PhoneConfirmEvents,PhoneConfirmStates>{
  PhoneConfirmBloc() : super(PhoneConfirmInitial());
  UserRepository userRepository = UserRepository();
  ProfileBloc dashboardBloc = ProfileBloc();
  LoginBloc loginBloc = LoginBloc();

  Future<int> getToken(String phone , String password)async{
    loginBloc.add(LoginButtonPressed(phone: phone, password: password));
    return 5 ;

  }

  @override
  Stream<PhoneConfirmStates> mapEventToState(PhoneConfirmEvents event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PhoneConfirmError(
        error: "TIMEOUT",
      );
    }

    if (event is AskForSMS){
      yield PhoneConfirmLoading();
      int checkAsking = await EventsAPIs.askForSMS(
          name: event.name,
          nationalId: event.nationalId,
          password: event.password,
          lastName: event.lastName,
          firstName: event.firstName,
          companyName: event.companyName,
          vatNumber: event.vatNumber,
          phone : event.phone);
      if(checkAsking == 201){
        yield CodeSendingSuccess();
      }
      else {
        yield CodeSendingError();
      }
    }

    if(event is CodeConfirmation){

      yield PhoneConfirmLoading();
      MyResponseModel myResponseModel = await EventsAPIs.CodeConfirmation(phone: event.phone , code: event.code);
      if(myResponseModel.responseData){

        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel token = await UserRepository.LoginAPI(
          username: event.phone,
          password: password,
        );
        if(token.responseData != null && token.statusCode == 201 || token.statusCode == 200 ){
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: token.responseData);
          await  userRepository.persistPhone(username: event.phone!);
          await userRepository.persistPassword(password: password);

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield PhoneConfirmSuccess();
        }else {
          yield FailedToLogin();
        }

      }
      else if (myResponseModel.statusCode == 403){
        yield PhoneConfirmError(
          error: "error2",
        );

      }
      else if(myResponseModel.statusCode == 505) {
        yield PhoneConfirmError(
          error: "needUpdate",
        );
      }

      else {
        yield PhoneConfirmError();
      }




    }

    if(event is ConfirmationReset){
      yield PhoneConfirmInitial();
    }
  }




}