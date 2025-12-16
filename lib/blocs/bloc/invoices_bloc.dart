import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/invoices_events.dart';
import 'package:xturbox/blocs/states/invoices_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/invoices_lists_model.dart';
import 'package:xturbox/data_providers/models/invoices_model.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class InvoicesBloc extends Bloc<InvoicesEvents , InvoicesStates> {
  InvoicesBloc() : super(InvoicesInitial());

  UserRepository userRepository = UserRepository();


  @override
  Stream<InvoicesStates> mapEventToState(InvoicesEvents event)async* {
    if(event is GetInvoices){

      yield*  _handleFetchingInvoices(event);
    }


  }

  Stream<InvoicesStates> _handleFetchingInvoices(
      InvoicesEvents event) async* {

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield InvoicesError(
          error: 'TIMEOUT');
      return;
    }
    else{

      yield InvoicesLoading();
      String? token = await userRepository.getAuthToken();
      MyResponseModel myResponseModel = await EventsAPIs.getInvoices(token: token);

      if(myResponseModel.statusCode == 200 || myResponseModel.statusCode == 204){
        yield InvoicesLoaded (
            invoicesListsModel: myResponseModel.responseData
        );
      }

      // else if (myResponseModel.statusCode == 204){
      //   yield InvoicesLoaded (
      //       invoicesListsModel: InvoicesListsModel.empty(growable: true)
      //   );
      // }
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

          authenticationBloc.add(LoggedIn(token: token.responseData));
          yield*  _handleFetchingInvoices(event);
        }else{
          yield InvoicesError(
              error: "invalidToken",
              failedEvent: event
          );

        }



      }
      else if(myResponseModel.statusCode == 505) {
        yield InvoicesError(
            error: "needUpdate",
            failedEvent: event
        );

      }
      else {

        yield InvoicesError(
            failedEvent: event,
            error: 'error'
        );
      }
    }

  }


}