import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/checkIn_events.dart';
import 'package:xturbox/blocs/states/checkIn_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';

import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

// to check attendance of the captain
class CheckInBloc extends Bloc<CheckInEvents, CheckInStates> {
  CheckInBloc() : super(CheckInInitial());
  UserRepository userRepository = UserRepository();
  @override
  Stream<CheckInStates> mapEventToState(CheckInEvents event) async* {
    if (event is IamActive) {
      yield* _handleIamActive(event);
    }
    if (event is IamNotActive) {
      yield* _handleIamNotActive(event);
    }

    if (event is CheckInEventsGenerateError) {
      yield CheckInFailure(error: "general");
    }

    if (event is GetCaptainProfileForDrawer) {
      yield* _handleGetDashboardData(event);
    }
  }

  Stream<CheckInStates> _handleIamActive(IamActive event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield CheckInFailure(error: 'TIMEOUT', failedEvent: event);
      return;
    } else {
      yield CheckInLoading();
      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel =
          await EventsApiCaptain.checkIn(token: token, signature: '2');
      if (myResponseModel.responseData) {
        yield CheckInActiveSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel token = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (token.responseData != null && token.statusCode == 201 ||
            token.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: token.responseData);

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield* _handleIamActive(event);
        } else {
          yield CheckInFailure(error: "invalidToken", failedEvent: event);
        }
      } else if (myResponseModel.statusCode == 505) {
        yield CheckInFailure(error: "needUpdate", failedEvent: event);
      } else {
        yield CheckInFailure(failedEvent: event, error: 'error');
      }
    }
  }

  Stream<CheckInStates> _handleIamNotActive(IamNotActive event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield CheckInFailure(error: 'TIMEOUT', failedEvent: event);
      return;
    } else {
      print('Hello from I am NOT Active event');
      yield CheckInLoading();
      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel =
          await EventsApiCaptain.checkIn(token: token, signature: '1');
      print('check out statuscode ${myResponseModel.statusCode}');
      print('check out responseData ${myResponseModel.responseData}');
      if (myResponseModel.responseData) {
        yield CheckInNotActiveSuccess();
      } else if (myResponseModel.statusCode == 403) {
        print('ana wslt 403');
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel token = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (token.responseData != null && token.statusCode == 201 ||
            token.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: token.responseData);

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield* _handleIamNotActive(event);
        } else {
          yield CheckInFailure(error: "invalidToken", failedEvent: event);
        }
      } else if (myResponseModel.statusCode == 505) {
        yield CheckInFailure(error: "needUpdate", failedEvent: event);
      } else {
        CheckInFailure(failedEvent: event, error: 'error');
      }
    }
  }

  Stream<CheckInStates> _handleGetDashboardData(
      GetCaptainProfileForDrawer event) async* {
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel =
        await EventsAPIs.FetchDashBoardData(token: token);

    if (myResponseModel.statusCode == 200) {
      if (myResponseModel.responseData.permission == '4') {
        userRepository.persistName(name: myResponseModel.responseData.name);
        SavedData.profileDataModel = myResponseModel.responseData ;
        UserRepository.name = myResponseModel.responseData.name;

        yield ProfileLoadedForDrawer(
            dashboardDataModel: myResponseModel.responseData);
      }
    }
  }
}
