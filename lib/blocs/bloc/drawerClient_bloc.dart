

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/drawerClient_events.dart';
import 'package:xturbox/blocs/states/drawerClient_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class DrawerClientBloc extends Bloc<DrawerClientEvents , DrawerClientStates> {
  DrawerClientBloc() : super(DrawerClientInitial());

  @override
  Stream<DrawerClientStates> mapEventToState(DrawerClientEvents event) async* {
    if (event is CallCS) {
      yield* _handleCallCS(event);
    }

    if(event is DrawerClientEventsGenerateError){
      yield DrawerClientError(
          error: "general"
      );
    }
  }

  Stream<DrawerClientStates> _handleCallCS(CallCS event) async* {
    UserRepository userRepository = UserRepository();
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield DrawerClientError(
        error: 'TIMEOUT',
      );
      return;
    }
    else {
      yield DrawerClientLoading();
      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel = await EventsAPIs.callCstSupport(token: token , msg: event.reason);
      if (myResponseModel.responseData) {
        yield DrawerClientSuccess();
      }
      else if (myResponseModel.statusCode == 403) {
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
          yield* _handleCallCS(event);
        } else {
          yield DrawerClientError(
            error: "invalidToken",
          );
        }
      }
      else if (myResponseModel.statusCode == 505) {
        yield DrawerClientError(
          error: "needUpdate",
        );
      }
      else {
        yield DrawerClientError(
            error: 'error'
        );
      }
    }
  }

}
