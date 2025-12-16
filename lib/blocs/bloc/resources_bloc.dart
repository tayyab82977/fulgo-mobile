import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/resources_events.dart';
import 'package:xturbox/blocs/states/resources_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/ResponseViewModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

import 'authentication_bloc.dart';

class ResourcesBloc extends Bloc<ResourcesEvents,ResourcesStates>{
  ResourcesBloc() : super(ResourcesInitial());



  ResourcesData? _resourcesData = ResourcesData();
  UserRepository userRepository = UserRepository();



   ResourcesData? getResources(){
    return _resourcesData;
  }
  @override
  Stream<ResourcesStates> mapEventToState(ResourcesEvents event) async* {


     if(event is GetResourcesData){

        yield* _handleGetResourcesData(event);

     }

     if(event is ResourcesEventsGenerateError){
       yield ResourcesError(
           error: "general"
       );
     }



  }
  Stream<ResourcesStates> _handleGetResourcesData(GetResourcesData event)async*{
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield ResourcesError(
          error: "TIMEOUT",
          failedEvent: event
      );
    }
    else {

      yield ResourcesLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel responseViewModel = await EventsAPIs.getResourcesData(
          token: token
      );

      if(responseViewModel.statusCode == 200){

        _resourcesData=responseViewModel.responseData ;
        SavedData.resourcesData = responseViewModel.responseData ;
        yield ResourcesLoaded(
            resourcesData: responseViewModel.responseData
        );
      }
      else if (responseViewModel.statusCode == 403){
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

          yield* _handleGetResourcesData(event);


        }else{
          yield ResourcesError(
              error: "invalidToken",
              failedEvent: event
          );

        }
      }
      else if(responseViewModel.statusCode == 505) {
        yield ResourcesError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else {
        yield ResourcesError(
            error: "error",
            failedEvent: event
        );
      }
    }
  }



}