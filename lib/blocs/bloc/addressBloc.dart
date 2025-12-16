
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/address_events.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/states/address_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import '../../UserRepo.dart';

class AddressBloc extends Bloc<AddressEvents , AddressStates> {
  AddressBloc() : super(AddressInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<AddressStates> mapEventToState(AddressEvents event)async* {
   if(event is GetAddress){

   yield*  _handleFetchingAddress(event);
   }

   if(event is DeleteAddress){

     yield*  _handleDeletingAddress(event);

   }

   if(event is AddressGenerateError){
     yield AddressError(
         error: "general",

     );
   }



  }

  Stream<AddressStates> _handleFetchingAddress(
      AddressEvents event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield AddressError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield AddressLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.FetchDashBoardData(token: token);

      if(myResponseModel.statusCode == 200){
        if(myResponseModel.responseData.permission == '1' || myResponseModel.responseData.permission == '11'){
          userRepository.persistName(name: myResponseModel.responseData.name);
          UserRepository.name = myResponseModel.responseData.name ;
          SavedData.profileDataModel = myResponseModel.responseData ;
          yield AddressLoaded (
              addressList: myResponseModel.responseData.addresses
          );
        }
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
          SavedData.token = "Bearer " + myResponseModel.responseData ;

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield*  _handleFetchingAddress(event);
        }else{
          yield AddressError(
              error: "invalidToken",
              failedEvent: event
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield AddressError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else {

        yield AddressError(
            failedEvent: event,
            error: 'error'
        );
      }
    }

  }


  Stream<AddressStates> _handleDeletingAddress(
      DeleteAddress event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield AddressError(
          error: 'TIMEOUT');
      return;
    }
    yield AddressLoading();
    String? token = await userRepository.getAuthToken();
    MyResponseModel myResponseModel = await  EventsAPIs.AddAddresses(
        token: token,
        list: event.adressList!
    );
    if(myResponseModel.responseData){

      yield DashboardEditAddressSuccess();

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
        SavedData.token = "Bearer " + token.responseData ;

        authenticationBloc.add(LoggedIn(token: token.responseData));
        yield*  _handleDeletingAddress(event);
      }else{
        yield AddressError(
            error: "invalidToken",
            failedEvent: event,
            errorsList: myResponseModel.errorsList

        );

      }



    }
    else if(myResponseModel.statusCode == 505) {
      yield AddressError(
          error: "needUpdate",
          failedEvent: event,
          errorsList: myResponseModel.errorsList

      );

    }else{
      yield AddressError(
          failedEvent: event,
          error: 'error',
          errorsList: myResponseModel.errorsList


      );
    }


  }


}