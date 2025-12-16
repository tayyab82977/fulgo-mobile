import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/myReserve_events.dart';
import 'package:xturbox/blocs/states/myReserve_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class MyReservesBloc extends Bloc<MyReservesEvents , MyReservesStates> {
  MyReservesBloc() : super(MyReservesInitial());

  UserRepository userRepository = UserRepository();

  @override
  Stream<MyReservesStates> mapEventToState(MyReservesEvents event) async* {
    if (event is GetMyReserves) {

    yield* _handleGetMyReserves(event);

    }

    if(event is MyReservesEventsGenerateError){
      yield MyReservesFailure(
          error: "general"
      );
    }
  }
  Stream<MyReservesStates> _handleGetMyReserves(GetMyReserves event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield MyReservesFailure(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else {
      yield MyReservesLoading();

      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsApiCaptain.getCaptainReserves(token: token);
      if(myResponseModel.statusCode == 200 ||myResponseModel.statusCode == 204 ){

        yield MyReservesLoaded(
            ordersList: myResponseModel.responseData
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

          yield* _handleGetMyReserves(event);

        }else{

          yield MyReservesFailure(
            error: "invalidToken",
          );

        }


      }
      else if(myResponseModel.statusCode == 505) {
        yield MyReservesFailure(
          error: "needUpdate",
        );
      }
      else {

        yield MyReservesFailure(
            error: 'error',
            failedEvent: event
        );

      }
    }
  }

}