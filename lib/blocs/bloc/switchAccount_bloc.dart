import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/addAcount_events.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/switchAccount_events.dart';
import 'package:xturbox/blocs/states/switchAccount_states.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/userModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class SwitchAccountBloc extends Bloc<SwitchAccountEvents , SwitchAccountStates> {
  SwitchAccountBloc() : super(SwitchAccountInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<SwitchAccountStates> mapEventToState(SwitchAccountEvents event)async* {
    if(event is SwitchingAccount){
      yield*  _handleSetSwitchAccount(event);
    }
  }

  Stream<SwitchAccountStates> _handleSetSwitchAccount(SwitchingAccount event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield SwitchAccountError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield SwitchAccountLoading();
      MyResponseModel myResponseModel = await UserRepository.LoginAPI(username: event.phone, password: event.password,);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 201){
        AuthenticationBloc authenticationBloc = AuthenticationBloc();
        authenticationBloc.add(LoggedIn(token: myResponseModel.responseData));
        await userRepository.persistPhone(username: event.phone);
        await userRepository.persistPassword(password: event.password);

        // SavedData.accountsList.add(UserModel(phone: event.phone, password: event.password, token: SavedData.token,name: "", selected: "1"));
        // UserModel.saveAccount(SavedData.accountsList);
        yield SwitchAccountSetSuccess ();
      }

      else {

        yield SwitchAccountError(
            error: 'error',
            errorList: myResponseModel.errorsList ?? []
        );
      }
    }

  }
}
