import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/bulkPickup_events.dart';
import 'package:xturbox/blocs/states/bulkPickup_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class BulkPickupBloc extends Bloc<BulkPickupEvents , BulkPickupStates> {
  BulkPickupBloc() : super(BulkPickupInitial());

  UserRepository userRepository = UserRepository();

  @override
  Stream<BulkPickupStates> mapEventToState(BulkPickupEvents event)async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield BulkPickupFailure(
          error: "TIMEOUT",
          failedEvent: event,

      );
    }

    if (event is BulkPickupThisList){

      yield* _handleBulkPickupThisList(event);


    }

    if (event is ReturnThisList){

      yield* _handleReturnThisList(event);


    }

    if(event is GetShipmentData){

    yield* _handleGetShipmentData(event);
    }
    if(event is GetReceipt){
      yield* _handleGetReceipt(event);
    }


    if(event is GetClientCredit){
      yield* _handleGetClientCredit(event);
    }

    if(event is SendConfirmationMsg){
      yield* _handleSendConfirmationMsg(event);
    }

    if(event is BulkPickupEventsGenerateError){
      yield BulkPickupFailure(
          error: "general"
      );
    }



  }
  Stream<BulkPickupStates> _handleSendConfirmationMsg(SendConfirmationMsg event)async*{

    yield BulkPickupLoading();

    MyResponseModel myResponseModel = await EventsApiCaptain.setMsgType(
        receiverId: event.receiverId,
        receiverPhone: event.receiverPhone,
        msgType: event.msgType
    );

    if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
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

        authenticationBloc.add(LoggedIn(token: myResponse.responseData));

        yield* _handleSendConfirmationMsg(event);

      }else{

        yield BulkPickupFailure(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield BulkPickupFailure(
        error: "needUpdate",
      );
    }
    else {

      yield BulkPickupFailure(
          error: myResponseModel.errorsList!.first,
          errorList: myResponseModel.errorsList
      );

    }

  }
  Stream<BulkPickupStates> _handleBulkPickupThisList(BulkPickupThisList event)async*{

    yield BulkPickupLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await EventsApiCaptain.captainPickup(
      memberId: event.memberId,
      amount: event.amount,
      receipt: event.receipt,
      pickupList: event.list!,
      creditList: event.creditList,
      paymentMethodId: event.paymentMethodId,
      token: token,
      msgCode: event.msgCodee


    );

    if(myResponseModel.statusCode == 200 ||myResponseModel.statusCode == 204  ){
      yield BulkPickupSuccess(
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

        authenticationBloc.add(LoggedIn(token: myResponse.responseData));

        yield* _handleBulkPickupThisList(event);

      }else{

        yield BulkPickupFailure(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield BulkPickupFailure(
        error: "needUpdate",
      );
    }
    else {

      yield BulkPickupFailure(
          error: myResponseModel.errorsList!.first,
          errorList: myResponseModel.errorsList
      );

    }

  }
  Stream<BulkPickupStates> _handleGetReceipt(GetReceipt event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCreditFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield BulkPickupLoading();
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

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleGetReceipt(event);

        }else{

          yield BulkPickupFailure(
            error: "invalidToken",
          );

        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield BulkPickupFailure(
          error: "needUpdate",
        );
      }
      else {
        yield BulkPickupFailure(
            error: 'error',
            errorList: myResponseModel.errorsList,
            failedEvent: event
        );
      }

    }
  }

  Stream<BulkPickupStates> _handleReturnThisList(ReturnThisList event)async*{

    yield BulkPickupLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await EventsApiCaptain.returnShipmentsToClient(
      memberId: event.memberId,
      amount: event.amount,
      receipt: event.receipt,
      pickupList: event.list ?? List<OrdersDataModelMix>.empty(growable: true),
      methodId: event.paymentMethodId.toString(),
      token: token,
      code: event.code.toString()

    );

    if(myResponseModel.statusCode == 200 ||  myResponseModel.statusCode == 204 ){
      yield ReturnShipmentsSuccess();

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

        yield* _handleReturnThisList(event);

      }else{

        yield BulkPickupFailure(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield BulkPickupFailure(
        error: "needUpdate",
      );
    }
    else {

      yield BulkPickupFailure(
          error: myResponseModel.errorsList!.first,
          errorList: myResponseModel.errorsList
      );

    }

  }



  Stream<BulkPickupStates> _handleGetClientCredit(GetClientCredit event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCreditFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield BulkPickupLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel ;
    if(event.returnToClient){

      myResponseModel = await EventsApiCaptain.getReturnCharges(
          acceptedList: event.acceptedList!,
          token: token,
          memberId: event.id,
      );
    } else {
      myResponseModel = await EventsApiCaptain.getClientCredit(
          acceptedList: event.acceptedList!,
          token: token,
          memberId: event.id
      );
    }


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
  Stream<BulkPickupStates> _handleGetShipmentData(GetShipmentData event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCreditFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield BulkPickupLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = MyResponseModel<OrdersDataModelMix>();
      if(event.type == "bulkPickup"){
         myResponseModel = await EventsApiCaptain.getShipmentByIdBulkPickup(
          token: token,
          id: event.shipmentId,
        );

      }else {
        myResponseModel = await EventsApiCaptain.getShipmentByIdReturnToClient(
          token: token,
          id: event.shipmentId,
        );
      }


      if(myResponseModel.statusCode == 200){
        print("yes new one loaded ");
        yield NewShipmentLoaded(
          ordersDataModelMix: myResponseModel.responseData
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

          yield* _handleGetShipmentData(event);

        }else{

          yield NewShipmentFailure(
            error: "invalidToken",
          );

        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield NewShipmentFailure(
          error: "needUpdate",
        );
      }
      else {
        yield NewShipmentFailure(
            error: 'error',
            errorList: myResponseModel.errorsList,
            failedEvent: event
        );
      }

    }
  }



}