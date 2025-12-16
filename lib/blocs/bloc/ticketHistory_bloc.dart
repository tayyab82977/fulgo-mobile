import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/ticketHistory_events.dart';
import 'package:xturbox/blocs/states/ticketHistory_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/tickets_model.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class TicketsHistoryBloc extends Bloc<TicketsHistoryEvents , TicketsHistoryStates> {
  TicketsHistoryBloc() : super(TicketsHistoryInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<TicketsHistoryStates> mapEventToState(TicketsHistoryEvents event)async* {
    if(event is GetTicketsHistory){

      yield*  _handleFetchingTicketsHistory(event);
    }


  }

  Stream<TicketsHistoryStates> _handleFetchingTicketsHistory(
      GetTicketsHistory event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield TicketsHistoryError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield TicketsHistoryLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.getTicketsHistory(token: token ,
      ticketId: event.ticketId
      );

      if(myResponseModel.statusCode == 200){
        yield TicketsHistoryLoaded (
            list: myResponseModel.responseData
        );
      }
      else if (myResponseModel.statusCode == 204){
        yield TicketsHistoryLoaded (
            list: <TicketsHistoryModel>[]
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
          yield*  _handleFetchingTicketsHistory(event);
        }else{
          yield TicketsHistoryError(
              error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield TicketsHistoryError(
            error: "needUpdate",
        );

      }
      else {

        yield TicketsHistoryError(
            error: 'error'
        );
      }
    }

  }


}