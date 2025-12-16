import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/tickets_events.dart';
import 'package:xturbox/blocs/states/tickets_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class TicketsBloc extends Bloc<TicketsEvents ,TicketsStates> {
 TicketsBloc() : super(TicketsInitial());

  // List<ListAndNames> hopeList = new List();


  @override
  Stream<TicketsStates> mapEventToState(TicketsEvents event) async*{

    UserRepository userRepository = UserRepository();

    if (event is GetTickets){

      yield* _handleGetTickets(event);
    }

    if (event is PostTickets){

      yield* _handlePostTickets(event);
    }

    }



  }
  Stream<TicketsStates> _handleGetTickets(GetTickets event) async* {
  bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield TicketsError(
          error: 'TIMEOUT');
      return;
    }else {
      yield TicketsLoading();

      String token = await userRepository.getAuthToken() ?? SavedData.token ;
      MyResponseModel myResponseModel = await EventsAPIs.getTickets(
        token: token
      );

      if(myResponseModel.statusCode == 200 && myResponseModel.responseData !=null){

        yield TicketsLoaded(
          ticketsList: myResponseModel.responseData
        );

      }
      else if(myResponseModel.statusCode == 204){
        yield TicketsLoaded(
          ticketsList: []
        );
      }
      else if (myResponseModel.statusCode == 403){

        UserRepository userRepository = UserRepository();
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
          yield* _handleGetTickets(event);
        }else{
          yield TicketsError(
              error: "invalidToken",
              failedEvent: event
          );

        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield TicketsError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else{

        yield TicketsError(
            failedEvent: event,
            error: 'error'
        );
      }
    }
  }



  Stream<TicketsStates> _handlePostTickets(PostTickets event) async* {
  bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield TicketsError(
          error: 'TIMEOUT');
      return;
    }else {
      yield TicketsLoading();
     String token = await userRepository.getAuthToken() ?? SavedData.token ;

      MyResponseModel myResponseModel =  await EventsAPIs.postNewTicket(shipment: event.shipmentId, subject: event.subject, description: event.description, cat: event.cat ,
      token: token

      );

      if(myResponseModel.responseData){

        yield TicketsAddSuccess();

      }
      else if (myResponseModel.statusCode == 403){

        UserRepository userRepository = UserRepository();
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
          yield* _handlePostTickets(event);
        }else{
          yield TicketsError(
              error: "invalidToken",
              failedEvent: event
          );

        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield TicketsError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else{

        yield TicketsError(
            failedEvent: event,
            error: 'error'
        );
      }
    }
  }


