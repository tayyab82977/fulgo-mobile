import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/PostFuelEntry_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/tickets_events.dart';
import 'package:xturbox/blocs/states/postFeulEntry_states.dart';
import 'package:xturbox/blocs/states/tickets_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class PostFuelEntryBloc extends Bloc<PostFuelEntryEvents ,PostFuelEntryStates> {
  PostFuelEntryBloc() : super(PostFuelEntryInitial());

  // List<ListAndNames> hopeList = new List();


  @override
  Stream<PostFuelEntryStates> mapEventToState(PostFuelEntryEvents event) async*{

    UserRepository userRepository = UserRepository();


    if (event is PostFuelEntry){

      yield* _handlePostFuelEntry(event);
    }

  }



}



Stream<PostFuelEntryStates> _handlePostFuelEntry(PostFuelEntry event) async* {
  bool isUserConnected = await NetworkUtilities.isConnected();
  if (isUserConnected == false) {
    yield PostFuelEntryError(
        error: 'TIMEOUT');
    return;
  }else {
    yield PostFuelEntryLoading();
    String token = await userRepository.getAuthToken() ?? SavedData.token ;

    MyResponseModel myResponseModel =  await EventsApiCaptain.postNewFuelEntry(fuelEntryModel: event.fuelEntryModel);

    if(myResponseModel.responseData){

      yield PostFuelEntryAddSuccess();

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
        yield* _handlePostFuelEntry(event);
      }else{
        yield PostFuelEntryError(
            error: "invalidToken",
        );

      }

    }
    else if(myResponseModel.statusCode == 505) {
      yield PostFuelEntryError(
          error: "needUpdate",
      );

    }
    else{

      yield PostFuelEntryError(
          error: 'error',
          errorList: myResponseModel.errorsList
      );
    }
  }
}


