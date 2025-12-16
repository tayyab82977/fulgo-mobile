import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/shipmentDetails_events.dart';
import 'package:xturbox/blocs/states/shipmentDetails_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class ShipmentDetailsBloc extends Bloc<ShipmentDetailsEvents , ShipmentDetailsStates>{
  ShipmentDetailsBloc() : super(ShipmentDetailsInitial());

  @override
  Stream<ShipmentDetailsStates> mapEventToState(ShipmentDetailsEvents event)async* {
    bool isUserConnected = await NetworkUtilities.isConnected();

    if (isUserConnected == false) {
      yield ShipmentDetailsError(
          error: 'TIMEOUT');
      return;
    }

    if(event is GetShipmentDetails){

      yield* _handleGetShipmentDetails(event);

    }


    if(event is ShipmentDetailsEventsGenerateError){
      yield ShipmentDetailsError(
          error: "general"
      );
    }



  }

  Stream<ShipmentDetailsStates> _handleGetShipmentDetails (GetShipmentDetails event)async*{
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
          error: 'error'
      );
    }


  }

}