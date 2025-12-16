
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/editProfile_events.dart';
import 'package:xturbox/blocs/states/editProfile_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/geoCodingDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/userModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class EditProfileBloc extends Bloc<EditProfileEvents, EditProfileStates>{
  EditProfileBloc() : super(EditInitial());
  UserRepository userRepository = UserRepository();

  @override
  Stream<EditProfileStates> mapEventToState(EditProfileEvents event) async* {

    if(event is PutProfileRequest){

     yield* _handlePutProfileRequest(event);

    }

    if(event is AddBank){

     yield* _handleAddBank(event);

    }

    if(event is AddNationalAddress){

      yield* _handleAddNationalAddress(event);

    }

    if(event is EditBank){

      yield*  _handleEditBank(event);

    }

    if(event is AddAddress){

      yield* _handleAddAddress(event);

    }

    if(event is EditProfileEventsGenerateError){
      yield EditError(
          error: "general"
      );
    }

  }

  Stream<EditProfileStates> _handlePutProfileRequest(PutProfileRequest event)async*{

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield EditError(
          error: 'TIMEOUT',
          failedEvent: event,
          errorList: []
      );
      return;
    }
    else {
      yield EditLoading();
      MyResponseModel myResponseModel = await  EventsAPIs.EditProfile(
          name: event.name,  email: event.email, phone2: event.phone2,
          changeUserName: event.changeUsername, password: event.password , id: event.id,
          national_id: event.national_id,
          firstName: event.firstName , lastName: event.lastName,
        companyName: event.companyName,vatNumber: event.vatNumber,cer: event.cer
      );
      if(myResponseModel.responseData){

        userRepository.persistPassword(password: event.password!);
        SavedData.accountsList.where((element) => element.phone == SavedData.profileDataModel.phone).first.password = event.password! ;
        UserModel.saveAccount(SavedData.accountsList);

        yield EditSuccess();

      }
      // if token expires or deleted regenerate an new token
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

          yield* _handlePutProfileRequest(event);

        }else{
          yield EditError(
            error: "invalidToken",
          );
        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield EditError(
          error: "needUpdate",
        );
      }
      else{
        yield EditError(
            errorList: myResponseModel.errorsList,
            error: 'error',
            failedEvent: event
        );
      }

    }

  }


  Stream<EditProfileStates> _handleAddBank(AddBank event)async*{

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield EditError(
          error: 'TIMEOUT',
          failedEvent: event
      );
      return;
    }
    else{
      yield EditLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await  EventsAPIs.AddBankData(
          token: token,
          bankName: event.bankName,
          name: event.name,
          iban: event.iban
      );
      if(myResponseModel.responseData){

        yield EditSuccess();

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

          yield* _handleAddBank(event);

        }else{
          yield EditError(
            error: "invalidToken",
          );
        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield EditError(
          error: "needUpdate",
        );
      }
      else{
        yield EditError(
            errorList: myResponseModel.errorsList,
            error: 'error',
            failedEvent: event
        );
      }
    }

  }

  Stream<EditProfileStates> _handleAddNationalAddress(AddNationalAddress event)async*{

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield EditError(
          error: 'TIMEOUT',
          failedEvent: event
      );
      return;
    }
    else{
      yield EditLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await  EventsAPIs.addNationalAddress(
        nationalAddressModel: event.nationalAddressModel
      );
      if(myResponseModel.responseData){

        yield EditSuccess();

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

          yield* _handleAddNationalAddress(event);

        }else{
          yield EditError(
            error: "invalidToken",
          );
        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield EditError(
          error: "needUpdate",
        );
      }
      else{
        yield EditError(
            errorList: myResponseModel.errorsList,
            error: 'error',
            failedEvent: event
        );
      }
    }

  }



  Stream<EditProfileStates> _handleAddAddress(AddAddress event)async*{

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield EditError(
          error: 'TIMEOUT',
          failedEvent: event
      );
      return;
    }
    else {

      yield EditLoading();




      String? token = await userRepository.getAuthToken();
      print('the token $token');

      MyResponseModel myResponseModel = await  EventsAPIs.AddAddresses(
          token: token,
          list: event.addressList!
      );
      if(myResponseModel.responseData){

        yield EditSuccess();

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

          yield* _handleAddAddress(event);

        }else{
          yield EditError(
            error: "invalidToken",
            errorList: myResponse.errorsList
          );
        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield EditError(
          error: "needUpdate",
        );
      }else{
        yield EditError(
            errorList: myResponseModel.errorsList,

        );
      }
    }

  }

  Stream<EditProfileStates> _handleEditBank(EditBank event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield EditError(
          error: 'TIMEOUT',
          failedEvent: event
      );

      return;
    }
    else{
      yield EditLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await  EventsAPIs.editBank(
          token: token,
          bankName: event.bankName,
          name: event.name,
          iban: event.iban
      );
      if(myResponseModel.responseData){

        yield EditSuccess();

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

          yield* _handleEditBank(event);

        }else{
          yield EditError(
            error: "invalidToken",
          );
        }

      }
      else if(myResponseModel.statusCode == 505) {
        yield EditError(
          error: "needUpdate",
        );
      }
      else{
        yield EditError(
            errorList: myResponseModel.errorsList,
            error: 'error',
            failedEvent: event
        );
      }
    }
  }




}