import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/postCarServices_events.dart';
import 'package:xturbox/blocs/states/postCarServices_states.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class PostCarSrvBloc extends Bloc<PostCarSrvEvents ,PostCarSrvStates> {
  PostCarSrvBloc() : super(PostCarSrvInitial());

  // List<ListAndNames> hopeList = new List();


  @override
  Stream<PostCarSrvStates> mapEventToState(PostCarSrvEvents event) async*{

    UserRepository userRepository = UserRepository();


    if (event is PostCarSrv){

      yield* _handlePostCarSrv(event);
    }

  }



}
Stream<PostCarSrvStates> _handlePostCarSrv(PostCarSrv event) async* {
  bool isUserConnected = await NetworkUtilities.isConnected();
  if (isUserConnected == false) {
    yield PostCarSrvError(
        error: 'TIMEOUT');
    return;
  }else {
    yield PostCarSrvLoading();
    String token = await userRepository.getAuthToken() ?? SavedData.token ;

    MyResponseModel myResponseModel =  await EventsApiCaptain.postNewCarSrvEntry(fuelEntryModel: event.fuelEntryModel);

    if(myResponseModel.responseData){

      yield PostCarSrvAddSuccess();

    }
    else if (myResponseModel.statusCode == 403){

      UserRepository userRepository = UserRepository();
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
        yield* _handlePostCarSrv(event);
      }else{
        yield PostCarSrvError(
          error: "invalidToken",
        );

      }

    }
    else if(myResponseModel.statusCode == 505) {
      yield PostCarSrvError(
        error: "needUpdate",
      );

    }
    else{

      yield PostCarSrvError(
          error: 'error',
          errorList: myResponseModel.errorsList
      );
    }
  }
}
