import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/captainOrders_events.dart';
import 'package:xturbox/blocs/states/captainOrders_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/ListAndName.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';

class CaptainOrdersBloc extends Bloc<CaptainOrdersEvents , CaptainOrdersStates> {
  CaptainOrdersBloc() : super(CaptainOrdersInitial());

  UserRepository userRepository = UserRepository();
  // List<ListAndNames> hopeList = new List();


  @override
  Stream<CaptainOrdersStates> mapEventToState(CaptainOrdersEvents event) async*{

    if (event is GetCaptainOrders){

        yield* _handleGetCaptainOrders(event);
    }

    if(event is CaptainOrdersEventsGenerateError){
      yield CaptainOrdersError(
          error: "general"
      );
    }



  }
  Stream<CaptainOrdersStates> _handleGetCaptainOrders(
      GetCaptainOrders event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield CaptainOrdersError(
          error: 'TIMEOUT');
      return;
    }else {
      yield CaptainOrdersLoading();

      String? token = await userRepository.getAuthToken();

      MyResponseModel myResponseModel = await EventsApiCaptain.getCaptainOrders(token: token);

      if(myResponseModel.statusCode == 200 && myResponseModel.responseData !=null){

        yield CaptainOrdersLoaded(
            newForCapOrders: myResponseModel.responseData
        );

      }else if (myResponseModel.statusCode == 204){

        yield CaptainOrdersEmpty(
            refresh: event
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
          yield* _handleGetCaptainOrders(event);
        }else{
          yield CaptainOrdersError(
              error: "invalidToken",
              failedEvent: event
          );

        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield CaptainOrdersError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else{

        yield CaptainOrdersError(
            failedEvent: event,
            error: 'error'
        );
      }
    }
  }


}