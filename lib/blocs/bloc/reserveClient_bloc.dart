 import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/reserveClient_events.dart';
import 'package:xturbox/blocs/states/reserveClient_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class ReserveClientBloc extends Bloc<ReserveClientEvents , ReserveClientStates> {
  ReserveClientBloc() : super(ReserveClientInitial());
  UserRepository userRepository = UserRepository();
  @override
  Stream<ReserveClientStates> mapEventToState(ReserveClientEvents event)async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ReserveClientFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }

    if(event is ReserveClient){

     yield* _handleReserveClient(event);
    }
    
    if(event is RecordPickupIssue){
      yield* _handleRecordPickupIssue(event);
    }


    if(event is CaptainCancelThisClient){

      yield* _handleCaptainCancelThisClient(event);

    }

    if(event is ReserveClientEventsGenerateError){
      yield ReserveClientFailure(
          error: "general"
      );
    }

  }


  Stream<ReserveClientStates> _handleReserveClient(ReserveClient event)async* {
    yield ReserveClientLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await EventsApiCaptain.reserveClient(
        token: token,
        id: event.id
    );

    if(myResponseModel.responseData){
      yield ReserveClientSuccess();

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

        yield* _handleReserveClient(event);

      }else{

        yield ReserveClientFailure(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield ReserveClientFailure(
        error: "needUpdate",
      );
    }
    else {

      yield ReserveClientFailure(
          failedEvent: event,
          error: 'error',
          errorList: myResponseModel.errorsList
      );

    }
  }

  Stream<ReserveClientStates> _handleCaptainCancelThisClient(CaptainCancelThisClient event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield CancelClientFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else {

      yield ReserveClientLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsApiCaptain.captainCancelClient(
          token: token , id: event.id
      );

      if(myResponseModel.responseData){

        yield CancelClientSuccess();

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

          yield* _handleCaptainCancelThisClient(event);

        }else{

          yield ReserveClientFailure(
            error: "invalidToken",
          );

        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield ReserveClientFailure(
          error: "needUpdate",
        );
      }
      else {

        yield CancelClientFailure(
            failedEvent: event,
            error: 'error',
            errorList: myResponseModel.errorsList

        );

      }
    }
  }
  Stream<ReserveClientStates> _handleRecordPickupIssue(RecordPickupIssue event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield CancelClientFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else {

      yield ReserveClientLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsApiCaptain.pickupIssue(
        acceptedList: event.orderList! ,  reasonId: event.reasonId
      );

      if(myResponseModel.responseData){

        yield CancelClientSuccess();

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

          yield* _handleRecordPickupIssue(event);

        }else{

          yield ReserveClientFailure(
            error: "invalidToken",
          );

        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield ReserveClientFailure(
          error: "needUpdate",
        );
      }
      else {

        yield CancelClientFailure(
            failedEvent: event,
            error: 'error',
            errorList: myResponseModel.errorsList

        );

      }
    }
  }


}