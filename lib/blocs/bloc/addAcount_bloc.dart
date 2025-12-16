import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/addAcount_events.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/states/addAcount_states.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/userModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class AddAccountBloc extends Bloc<AddAccountEvents , AddAccountStates> {
  AddAccountBloc() : super(AddAccountInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<AddAccountStates> mapEventToState(AddAccountEvents event)async* {
    if(event is AddingAccount){
      yield*  _handleSetAddAccount(event);
    }
  }

  Stream<AddAccountStates> _handleSetAddAccount(AddingAccount event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield AddAccountError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield AddAccountLoading();
      MyResponseModel myResponseModel = await UserRepository.LoginAPI(username: event.phone, password: event.password,);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){
        AuthenticationBloc authenticationBloc = AuthenticationBloc();
        authenticationBloc.add(LoggedIn(token: myResponseModel.responseData));
        SavedData.accountsList.add(UserModel(phone: event.phone, password: event.password, token: SavedData.token,name: "", selected: "1"));
        await userRepository.persistPhone(username: event.phone);
        await userRepository.persistPassword(password: event.password);

        UserModel.saveAccount(SavedData.accountsList);
        yield AddAccountSetSuccess ();
      }

      else {

        yield AddAccountError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
}
