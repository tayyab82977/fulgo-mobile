import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/pickup_evevnts.dart';
import 'package:xturbox/blocs/states/pickup_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class PickUpBloc extends Bloc<PickUpEvents , PickUpStates> {
  PickUpBloc() : super(PickupInitial());

  UserRepository userRepository = UserRepository();

  @override
  Stream<PickUpStates> mapEventToState(PickUpEvents event)async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }

    if (event is PickUpThisList){

     yield* _handlePickUpThisList(event);


    }



    if(event is GetClientCredit){
        yield* _handleGetClientCredit(event);
    }
    if(event is GetReceipt){
      yield* _handleGetReceipt(event);
    }

    if(event is PickUpEventsGenerateError){
      yield PickupFailure(
          error: "general"
      );
    }

    if(event is SendConfirmationMsg){
      yield* _handleSendConfirmationMsg(event);
    }



  }

  Stream<PickUpStates> _handleSendConfirmationMsg(SendConfirmationMsg event)async*{

    yield PickupLoading();

    MyResponseModel myResponseModel = await EventsApiCaptain.setMsgType(
        receiverId: event.receiverId,
        receiverPhone: event.receiverPhone,
        msgType: event.msgType
    );

    if(myResponseModel.statusCode == 200 ||myResponseModel.statusCode == 204  ){
      yield MsgSentSuccessfully();

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
        SavedData.token = "Bearer " + myResponseModel.responseData ;


        authenticationBloc.add(LoggedIn(token: myResponse.responseData));

        yield* _handleSendConfirmationMsg(event);

      }else{

        yield PickupFailure(
          error: "invalidToken",
          errorList: myResponse.errorsList
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield PickupFailure(
        error: "needUpdate",

      );
    }
    else {

      yield PickupFailure(
          error: myResponseModel.errorsList?.first,
          errorList: myResponseModel.errorsList
      );

    }

  }
  Stream<PickUpStates> _handlePickUpThisList(PickUpThisList event)async*{

    yield PickupLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await EventsApiCaptain.captainPickup(
      memberId: event.memberId,
      amount: event.amount,
      receipt: event.receipt,
      pickupList: event.pickupList!,
      creditList: event.creditList,
      paymentMethodId: event.paymentMethodId,
      token: token,
      msgCode: event.msgCodee


    );

    if(myResponseModel.statusCode == 200){
      yield PickupSuccess(
          pickupReport: myResponseModel.responseData
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
        SavedData.token = "Bearer " + myResponseModel.responseData ;

        authenticationBloc.add(LoggedIn(token: myResponse.responseData));

        yield* _handlePickUpThisList(event);

      }else{

        yield PickupFailure(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield PickupFailure(
        error: "needUpdate",
      );
    }
    else {

      yield PickupFailure(
        error: myResponseModel.errorsList!.first
      );

    }

  }



  Stream<PickUpStates> _handleGetClientCredit(GetClientCredit event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCreditFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield PickupLoading();
      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel = await EventsApiCaptain.getClientCredit(
          acceptedList: event.acceptedList!,
          token: token,
          memberId: event.id
      );
      if(myResponseModel.statusCode == 200){
        yield ClientCreditSuccess(
            calculations: myResponseModel.responseData
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
          SavedData.token = "Bearer " + myResponseModel.responseData ;

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleGetClientCredit(event);

        }else{

          yield ClientCreditFailure(
            error: "invalidToken",
          );

        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield ClientCreditFailure(
          error: "needUpdate",
        );
      }
      else {
        yield ClientCreditFailure(
            error: 'error',
            errorList: myResponseModel.errorsList,
            failedEvent: event
        );
      }

    }
  }
  Stream<PickUpStates> _handleGetReceipt(GetReceipt event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCreditFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield PickupLoading();
      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel = await EventsApiCaptain.getReceipt(
          storeId: event.storeId,
          paymentMethod: event.method,
      );
      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201 ){
        yield ReceiptLoaded(
            receipt: myResponseModel.responseData
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
          SavedData.token = "Bearer " + myResponseModel.responseData ;

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleGetReceipt(event);

        }else{

          yield ClientCreditFailure(
            error: "invalidToken",
          );

        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield ClientCreditFailure(
          error: "needUpdate",
        );
      }
      else {
        yield ClientCreditFailure(
            error: 'error',
            errorList: myResponseModel.errorsList,
            failedEvent: event
        );
      }

    }
  }

}