import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/events/LoginEvents.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/states/LoginStates.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/userModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';
import 'authentication_bloc.dart';

class LoginBloc extends Bloc <LoginEvent , LoginState> {

  static String? geToken ;
  UserRepository userRepository = UserRepository();
/*  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;*/
  LoginBloc() : super(LoginInitial());


  @override
  Stream<LoginState> mapEventToState(LoginEvent event)async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield LoginFailure(
          error: 'TIMEOUT',
      );
      return;
    }


    if (event is LoginButtonPressed) {
      bool isUserConnected = await NetworkUtilities.isConnected();
      if (isUserConnected == false) {
        yield LoginFailure(
            error: 'TIMEOUT',
        );
        return;
      }else{

        yield LoginLoading();

        final MyResponseModel myResponseModel = await UserRepository.LoginAPI(
          username: event.phone,
          password: event.password,
        );
        if(myResponseModel.responseData != null && myResponseModel.statusCode == 201 || myResponseModel.statusCode == 200){
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistPhone(username: event.phone);
          await userRepository.persistPassword(password: event.password);

          SavedData.token = "Bearer " + myResponseModel.responseData ;
          bool checkSavedAccount = await UserModel.checkSavedAccounts();
          if(checkSavedAccount){
            SavedData.accountsList = await UserModel.getSavedAccounts();
          }
          UserModel newAccount = UserModel(phone: event.phone, password: event.password, token: SavedData.token,name: "", selected: "1");

          if( !SavedData.accountsList.contains(newAccount)){
            SavedData.accountsList.add(UserModel(phone: event.phone, password: event.password, token: SavedData.token,name: "", selected: "1"));
          }
          UserModel.saveAccount(SavedData.accountsList);


          authenticationBloc.add(LoggedIn(token: myResponseModel.responseData));
          print(SavedData.accountsList.length);
          yield LoginSuccess();
        }
        else if (myResponseModel.statusCode == 403){
          yield LoginFailure(
            error: "error2",
          );

        }
        else if(myResponseModel.statusCode == 505) {
          yield LoginFailure(
            error: "needUpdate",
          );
        }

        else {
          yield LoginFailure(error: 'please check your email and password');
        }
      }


    }
    if (event is LoginReset){
      yield LoginInitial();
    }
  }
}