import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/blocs/states/dashboard_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/userModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';
import 'package:xturbox/utilities/location.dart';

class ProfileBloc extends Bloc<ProfileEvents? , ProfileStates>{

  UserRepository userRepository = UserRepository();
  ProfileBloc() : super(DashboardInitial());

  @override
  Stream<ProfileStates> mapEventToState(ProfileEvents? event) async* {


    if (event is GetProfileData) {

      yield* _handleGetDashboardData(event);
    }

    if(event is DashboardEventsGenerateError){
      yield DashboardError(
          error: "general"
      );
    }


    }
  Stream<ProfileStates> _handleGetDashboardData(GetProfileData event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield DashboardError(
          error: 'TIMEOUT',
          failedEvent: event
      );
      return;
    }
    else{
      yield DashboardLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.FetchDashBoardData(token: token);

      if (myResponseModel.statusCode == 200) {
        SavedData.profileDataModel = myResponseModel.responseData ;
        if (myResponseModel.responseData.permission == '1' ||  myResponseModel.responseData.permission == '11') {

          userRepository.persistName(name: myResponseModel.responseData.name);
          UserRepository.name = myResponseModel.responseData.name;

          if(myResponseModel.responseData.national_id == null){
            yield NoNationalId();
            return;
          }
          SavedData.accountsList.where((element) => element.phone == myResponseModel.responseData.phone).first.name = myResponseModel.responseData.name ;
          UserModel.saveAccount(SavedData.accountsList);
          yield DashboardUserLoaded(
              dashboardDataModel: myResponseModel.responseData
          );
        }
        else {
          yield DashboardError(
              failedEvent: event,
              error: 'invalidToken'
          );
        }
      }
      else if (myResponseModel.statusCode == 403){
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if(myResponse.responseData != null && myResponse.statusCode == 201 || myResponse.statusCode == 200){
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleGetDashboardData(event);

        }else{

          yield DashboardError(
              error: "invalidToken",
              failedEvent: event
          );
        }




      }
      else if(myResponseModel.statusCode == 505) {
        yield DashboardError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else {
        yield DashboardError(
            failedEvent: event,
            error: 'error'
        );
      }

    }
  }

  }
