

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/clientPayments_events.dart';
import 'package:xturbox/blocs/states/clientPayments_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/PaymentsAndProfile.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class ClientPaymentsBloc extends Bloc<ClientPaymentsEvents , ClientPaymentsStates>{
  ClientPaymentsBloc() : super(ClientPaymentsInitial());
  UserRepository userRepository = UserRepository() ;

  @override
  Stream<ClientPaymentsStates> mapEventToState(ClientPaymentsEvents event) async*{
    if (event is GetClintPayments){

      yield* _handleGetClintPayments(event);
    }

    if(event is ClientPaymentsEventsGenerateError){
      yield ClientPaymentsError(
          error: "general"
      );
    }


  }

  Stream<ClientPaymentsStates> _handleGetClintPayments(GetClintPayments event)async*{

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ClientPaymentsError(
          error: 'TIMEOUT',
          failedEvent: event
      );
      return;
    }
    else {
      yield ClientPaymentsLoading();
      PaymentsAndProfile paymentsAndProfile = PaymentsAndProfile();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.GetMyPayments(token: token);
      if (myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        paymentsAndProfile.clientPaymentsDataList = myResponseModel.responseData ;
        MyResponseModel myResponseModelProfile = await EventsAPIs.FetchDashBoardData(token: token);
        if (myResponseModelProfile.statusCode == 200) {
          if (myResponseModelProfile.responseData.permission == '1' || myResponseModelProfile.responseData.permission == '11' ) {
            userRepository.persistName(name: myResponseModelProfile.responseData.name);
            UserRepository.name = myResponseModelProfile.responseData.name;
            paymentsAndProfile.dashboardDataModel = myResponseModelProfile.responseData ;


            yield ClientPaymentsLoaded(
                paymentsAndProfile: paymentsAndProfile
            );
          }
          else {
            yield ClientPaymentsError(
                failedEvent: event,
                error: 'error'
            );
          }
        }
        else {
          yield ClientPaymentsError(
              failedEvent: event,
              error: 'error'
          );
        }





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

          yield* _handleGetClintPayments(event);

        }else{

          yield ClientPaymentsError(
            error: "invalidToken",
          );
        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield ClientPaymentsError(
          error: "needUpdate",
        );
      }
      else {
        yield ClientPaymentsError(
            failedEvent: event,
            error: 'error'
        );
      }

    }

  }



}