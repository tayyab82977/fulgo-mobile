import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/clientCancelOrder_events.dart';
import 'package:xturbox/blocs/states/clientCancelOrder_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class ClientCancelOrderBloc extends Bloc<ClientCancelOrderEvents , ClientCancelOrderStates> {
  ClientCancelOrderBloc() : super(ClientCancelOrderInitial());

  UserRepository userRepository = UserRepository();

  @override
  Stream<ClientCancelOrderStates> mapEventToState(ClientCancelOrderEvents event)async* {

    bool isUserConnected = await NetworkUtilities.isConnected();

    if (isUserConnected == false) {
      yield ClientCancelOrderFailure(
          error: 'TIMEOUT');
      return;
    }

    if(event is CancelMyOrder){
      yield*  _handleCancelMyOrder(event);
    }

    if(event is ClientReversOrder){
      yield*  _handleReversMyOrder(event);
    }
    if (event is ClientEditOrder){
      yield*  _handleClientEditOrder(event);
    }

    if(event is GetShipmentDetails){

      yield* _handleGetShipmentDetails(event);

    }

    if(event is ZeroCod){

      yield* _handleZeroCod(event);

    }


    if(event is ZeroRC){

      yield* _handleZeroRc(event);

    }

    if(event is ClientCancelOrderEventsGenerateError){
      yield ClientCancelOrderFailure(
          error: "general"
      );
    }
  }

  Stream<ClientCancelOrderStates> _handleCancelMyOrder(CancelMyOrder event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCancelOrderFailure(
        error: 'TIMEOUT',
      );
      return;
    }
    else {

      yield ClientCancelOrderLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.CancelClientOrder(token: token , id: event.id);
      if(myResponseModel.responseData){
        yield ClientCancelOrderSuccess();
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
          yield*  _handleCancelMyOrder(event);

        }else{
          yield ClientCancelOrderFailure(
            error: "invalidToken",
          );

        }
      }
      else if(myResponseModel.statusCode == 505) {
        yield ClientCancelOrderFailure(
          error: "needUpdate",
        );
      }
      else{

        yield ClientCancelOrderFailure(
            error: 'error',
          errors:myResponseModel.errorsList,
        );

      }
    }

  }

  Stream<ClientCancelOrderStates> _handleReversMyOrder(ClientReversOrder event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCancelOrderFailure(
        error: 'TIMEOUT',
      );
      return;
    }
    else {

      yield ClientCancelOrderLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.reverseShipment(token: token , postOrder: event.ordersDataModelMix!  ,shipmentId: event.shipmentId);
      if(myResponseModel.responseData){
        yield ClientCancelOrderSuccess();
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
          yield*  _handleReversMyOrder(event);

        }else{
          yield ClientCancelOrderFailure(
            error: "invalidToken",
          );

        }
      }
      else if(myResponseModel.statusCode == 505) {
        yield ClientCancelOrderFailure(
          error: "needUpdate",
        );
      }
      else{

        yield ClientCancelOrderFailure(
            error: 'error',
          errors:myResponseModel.errorsList,
        );

      }
    }

  }


  Stream<ClientCancelOrderStates> _handleClientEditOrder(ClientEditOrder event)async*{

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientCancelOrderFailure(
        error: 'TIMEOUT',
      );
      return;
    }
    else {

      yield ClientCancelOrderLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel checkRequest = await EventsAPIs.ClientEditOrderCall(
          token:token,
          postOrder: event.ordersDataModelMix!
      );

      if(checkRequest.responseData){
        yield ClientCancelOrderSuccess();

      }
      else if (checkRequest.statusCode == 403){
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
          yield*  _handleClientEditOrder(event);

        }else{
          yield ClientCancelOrderFailure(
            error: "invalidToken",
          );

        }
      }
      else if(checkRequest.statusCode == 505) {
        yield ClientCancelOrderFailure(
          error: "needUpdate",
        );
      }
      else{

        yield ClientCancelOrderFailure(
            error: 'error',
            errors: checkRequest.errorsList
        );

      }
    }

  }

  Stream<ClientCancelOrderStates> _handleGetShipmentDetails (GetShipmentDetails event)async*{
    UserRepository userRepository = UserRepository() ;

    yield ShipmentDetailsLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await EventsAPIs.getShipmentDetails(token:token,id: event.id);
    if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){

      OrdersDataModelMix? ordersDataModel = myResponseModel.responseData;

      yield ShipmentDetailsLoaded(ordersDataModel: ordersDataModel);
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

        yield ShipmentDetailPop();
        yield* _handleGetShipmentDetails(event);

      }else{

        yield ShipmentDetailsError(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield ShipmentDetailsError(
        error: "needUpdate",
      );
    }
    else {

      yield ShipmentDetailsError(
          error: 'error',
        errorList: myResponseModel.errorsList
      );
    }


  }
  
  Stream<ClientCancelOrderStates> _handleZeroCod (ZeroCod event)async*{
    UserRepository userRepository = UserRepository() ;

    yield ShipmentDetailsLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await EventsAPIs.clientZeroCod(token:token,id: event.shipmentId);
    if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        yield ShipmentZeroActionSuccess();
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

        yield ShipmentDetailPop();
        yield* _handleZeroCod(event);

      }else{

        yield ShipmentDetailsError(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield ShipmentDetailsError(
        error: "needUpdate",
      );
    }
    else {

      yield ShipmentDetailsError(
          error: 'error',
          errorList: myResponseModel.errorsList,
      );
    }


  }
  
  Stream<ClientCancelOrderStates> _handleZeroRc (ZeroRC event)async*{
    UserRepository userRepository = UserRepository() ;

    yield ShipmentDetailsLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await EventsAPIs.clientZeroRC(token:token,id: event.shipmentId);
    if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
      yield ShipmentZeroActionSuccess();

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

        yield ShipmentDetailPop();
        yield* _handleZeroRc(event);

      }else{

        yield ShipmentDetailsError(
          error: "invalidToken",
        );

      }


    }
    else if(myResponseModel.statusCode == 505) {
      yield ShipmentDetailsError(
        error: "needUpdate",
      );
    }
    else {

      yield ShipmentDetailsError(
          error: 'error',
          errorList: myResponseModel.errorsList,

      );
    }


  }



}