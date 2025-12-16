


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/resources_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/states/authentication_state.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/ResponseViewModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/userModel.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent , AuthenticationState>{
   final UserRepository userRepository = UserRepository();
  AuthenticationBloc() : super(AuthenticationUninitialized());
  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {

    bool loggedIn ;


    ResourcesData? resourcesData ;
    if (event is AppStarted) {
      ResourcesBloc resourcesBloc = ResourcesBloc();



        final bool hasToken = await userRepository.hasToken();

        if (hasToken) {

          // String serverName  = await userRepository.getServerName();
          String phone = await userRepository.getAuthPhone();
          String password = await userRepository.getAuthPassword();
          UserRepository.name = await userRepository.getAuthName();
          // EventsAPIs.url = serverName ;
          Constants.savedVersion = await userRepository.getSavedVersion();

          if(Constants.savedVersion == null ){
            Constants.savedVersion = Constants.appVersion ;
          }
          bool isUserConnected = await NetworkUtilities.isConnected();

          if (isUserConnected == false) {
            yield AuthenticationError(
                error:"TIMEOUT",
                failedEvent: event
            );
            return;
          }

          MyResponseModel token = await UserRepository.LoginAPI(
              username: phone,
              password: password
          );



          if(token != null){
            userRepository.persistToken(token: token.responseData);
            SavedData.token = "Bearer " + token.responseData ;

            bool checkSavedAccount = await UserModel.checkSavedAccounts();
            if(checkSavedAccount)
              SavedData.accountsList = await UserModel.getSavedAccounts();
            else
              SavedData.accountsList.add(UserModel(name: "" ,phone: phone, password: password, token: SavedData.token, selected: "1" ));
              UserModel.saveAccount(SavedData.accountsList);

            loggedIn = true ;
          }else{
            loggedIn = false ;

            // yield AuthenticationUnauthenticated(
            //     resourcesData: resourcesData
            // );
          }


        } else {
          loggedIn = false ;

          Constants.savedVersion = Constants.appVersion ;

          // yield AuthenticationUnauthenticated(
          //     resourcesData: resourcesData
          // );
        }



    }

    if (event is LoggedIn) {
      yield AuthenticationLoading(
        resourcesData: resourcesData
      );
      await userRepository.persistToken(token: event.token!);
      SavedData.token = "Bearer " + event.token.toString() ;

      SavedData.token = event.token.toString() ;
      yield AuthenticationAuthenticated(
        resourcesData: resourcesData
      );
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading(
        resourcesData: resourcesData
      );
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated(
        resourcesData: resourcesData
      );
    }

    if(event is Decision){
      String? token = await userRepository.getAuthToken();
      if(token != null){
        yield AuthenticationAuthenticated(
            resourcesData: resourcesData
        );
      }else{
        yield AuthenticationUnauthenticated(
            resourcesData: resourcesData
        );
      }
    }

  }

}