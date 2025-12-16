

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/myPickup_events.dart';
import 'package:xturbox/blocs/states/myPickup_states.dart';
import 'package:xturbox/blocs/states/pickup_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class MyPickupBloc extends Bloc<MyPickupEvents? , MyPickupStates>{
  MyPickupBloc() : super(MyPickupInitial());

  UserRepository userRepository = UserRepository();

  @override
  Stream<MyPickupStates> mapEventToState(MyPickupEvents? event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();

    if (isUserConnected == false) {
      yield MyPickupError(
        failedEvents: event
      );
      return;
    }


    if(event is GetMyPickup){

      yield* _handleGetMyPickup(event);
    }

    if(event is BulkStoreOut){

      yield* _handleBulkStoreOut(event);
    }


    if(event is MyPickupEventsGenerateError){
      yield MyPickupError(
          error: "general"
      );
    }
  }
  Stream<MyPickupStates> _handleGetMyPickup(GetMyPickup event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield MyPickupError(
          error: 'TIMEOUT',
          failedEvents: event
      );
      return;
    }
    else {

      yield MyPickupLoading();
      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel = await EventsApiCaptain.getMyPickups(token: token);
      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){

        yield MyPickupLoaded(
            pickUpDataModel: myResponseModel.responseData
        );
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

          yield* _handleGetMyPickup(event);

        }else{

          yield MyPickupError(
            error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield MyPickupError(
          error: "needUpdate",
        );
      }
      else {
        yield MyPickupError(
            failedEvents: event,
            error: myResponseModel.errorsList?.first
        );

      }
    }
  }
  Stream<MyPickupStates> _handleBulkStoreOut(BulkStoreOut event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield MyPickupError(
          error: 'TIMEOUT',
          failedEvents: event
      );
      return;
    }
    else {

      yield MyPickupLoading();
      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel = await EventsApiCaptain.bulktoreOutShipment(token: token , list: event.list);
      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){

        yield BulkSoreOutSuccess();
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

          yield* _handleBulkStoreOut(event);

        }else{

          yield BulkStoreOutErrorError(
            error: "invalidToken",
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield BulkStoreOutErrorError(
          error: "needUpdate",
        );
      }
      else {
        yield BulkStoreOutErrorError(
            failedEvents: event,
            errorsList :myResponseModel.errorsList ?? List<String>.empty(growable: true) ,
            error: myResponseModel.errorsList?.first
        );

      }
    }
  }

}