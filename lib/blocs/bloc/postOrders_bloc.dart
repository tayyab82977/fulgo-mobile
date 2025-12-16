
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/postOrder_events.dart';
import 'package:xturbox/blocs/states/postOrders_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class PostOrderBloc extends Bloc<PostOrdersEvent, PostOrdersStates> {
  PostOrderBloc() : super(PostOrderInitial());
 UserRepository userRepository = UserRepository();
  @override
  Stream<PostOrdersStates> mapEventToState(PostOrdersEvent event) async* {

    if (event is PostNewOrder){

     yield* _handlePostNewOrder(event);
    }
    if (event is AddB2cOrder){

      yield* _handleAddB2cOrder(event);
    }

    if (event is EditOrder){

      yield* _handleEditOrder(event);
    }
    if(event is PostOrdersEventGenerateError){
      yield PostOrderError(
        error: "general"
      );
    }

  }

  Stream<PostOrdersStates> _handlePostNewOrder (PostNewOrder event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PostOrderError(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield PostOrderLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel checkRequest = await EventsAPIs.PostNewOrder(
          token:token,
          postOrder: event.postOrderDataModel!
      );

      if(checkRequest.responseData){
        yield PostOrderSuccess();

      }

      else if (checkRequest.statusCode == 403){

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

          yield* _handlePostNewOrder(event);

        }else{

          yield PostOrderError(
            error: "invalidToken",
          );


        }

      }
      else if(checkRequest.statusCode == 505) {
        yield PostOrderError(
          error: "needUpdate",
        );
      }
      else {
        yield  PostOrderError(
            errors: checkRequest.errorsList,
            failedEvent: event
        );

      }
    }
  }
  Stream<PostOrdersStates> _handleAddB2cOrder (AddB2cOrder event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PostOrderError(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield PostOrderLoading();
      MyResponseModel checkRequest = await EventsAPIs.addOrderB2c(
          pickupList: event.ordersList
      );
      if(checkRequest.responseData){
        yield PostOrderSuccess();

      }

      else if (checkRequest.statusCode == 403){

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
          yield PopLoading();
          yield* _handleAddB2cOrder(event);

        }else{

          yield PostOrderError(
            error: "invalidToken",
          );


        }

      }
      else if(checkRequest.statusCode == 505) {
        yield PostOrderError(
          error: "needUpdate",
        );
      }
      else {
        yield  PostOrderError(
            errors: checkRequest.errorsList,
            failedEvent: event
        );

      }
    }
  }
  Stream<PostOrdersStates> _handleEditOrder (EditOrder event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PostOrderError(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else{
      yield PostOrderLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel checkRequest = await EventsAPIs.ClientEditOrderCall(
          token:token,
          postOrder: event.ordersDataModelMix!
      );

      if(checkRequest.responseData){
        yield EditOrderSuccess();

      }

      else if (checkRequest.statusCode == 403){

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

          yield* _handleEditOrder(event);

        }else{

          yield PostOrderError(
            error: "invalidToken",
          );


        }

      }
      else if(checkRequest.statusCode == 505) {
        yield PostOrderError(
          error: "needUpdate",
        );
      }
      else {
        yield  PostOrderError(
            errors: checkRequest.errorsList,
            failedEvent: event
        );

      }
    }
  }

}