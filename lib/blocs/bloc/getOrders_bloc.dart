import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/gerOrders_events.dart';
import 'package:xturbox/blocs/states/getOrders_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/shipments_lists_model.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';
import 'authentication_bloc.dart';

class GetOrdersBloc extends Bloc<GetOrdersEvents , GetOrdersStates>{
  GetOrdersBloc() : super(GetOrdersInitial());


  UserRepository userRepository = UserRepository();
//  List<ImportantEventsViewModel> get getAllEvents => userNews;
//  List<ImportantEventsViewModel> get getEngEvents => userNews.where((element) => element.id == 22).toList();
//  List<ImportantEventsViewModel> get getArcEvents => userNews.where((element) => element.id == 73).toList();

  List<OrdersDataModelMix> allOrdersList = [];
  List<OrdersDataModelMix> activeOrdersList = [];
  List<OrdersDataModelMix> deadOrdersList = [];
  List<OrdersDataModelMix> doneOrdersList = [];

  @override
  Stream<GetOrdersStates> mapEventToState(GetOrdersEvents event)async*{



    if (event is GetOrders){


   yield* _handleGetOrders(event);

    }

    if(event is GetOfdOrders){
      yield* _handleGetOfdOrders(event);
    }

    if(event is GetOrdersEventsGenerateError){
      yield GetOrdersErrors(
          error: "general"
      );
    }

  }
  Stream<GetOrdersStates> _handleGetOrders(GetOrders event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield GetOrdersErrors(
          error: 'TIMEOUT',
          failedEvent: event
      );
      return;
    }
    else{

      yield GetOrdersLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.GetMyOrders(token:token);
      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){

        // ShipmentsListsModel shipmentsListsModel = myResponseModel.responseData;
        // allOrdersList.addAll(ordersDataModel);

        yield GetOrdersLoaded(
          shipmentsListsModel: myResponseModel.responseData,

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

          yield* _handleGetOrders(event);

        }else{

          yield GetOrdersErrors(
            error: "invalidToken",
          );

        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield GetOrdersErrors(
          error: "needUpdate",
        );
      }
      else {

        yield GetOrdersErrors(
            errorList: myResponseModel.errorsList,
            failedEvent: event,
            error: 'error'
        );
      }
    }
  }
  Stream<GetOrdersStates> _handleGetOfdOrders(GetOfdOrders event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield GetOrdersErrors(
          error: 'TIMEOUT',
          failedEvent: event
      );
      return;
    }
    else{

      yield GetOrdersLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.getOfdOrders(token:token);
      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){

        // ShipmentsListsModel shipmentsListsModel = myResponseModel.responseData;
        // allOrdersList.addAll(ordersDataModel);

        yield OfdOrdersLoaded(
          ofdOrdersList: myResponseModel.responseData,

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

          yield* _handleGetOfdOrders(event);

        }else{

          yield GetOrdersErrors(
            error: "invalidToken",
          );

        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield GetOrdersErrors(
          error: "needUpdate",
        );
      }
      else {

        yield GetOrdersErrors(
            errorList: myResponseModel.errorsList,
            failedEvent: event,
            error: 'error'
        );
      }
    }
  }

}