import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/myPickupActions_events.dart';
import 'package:xturbox/blocs/states/myPickupActions_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/apis/EventsApiCaptian.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/callLogModel.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class PickupActionsBloc extends Bloc<PickupActionsEvents, PickupActionsStates> {
  PickupActionsBloc() : super(PickupActionsInitial());
  UserRepository userRepository = UserRepository();

  @override
  Stream<PickupActionsStates> mapEventToState(
      PickupActionsEvents event) async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    }

    String? token = await userRepository.getAuthToken();

    if (event is DeliverShipment) {
      yield* _handleDeliverShipment(event);

    }
    if (event is StoreOutShipment) {
      yield* _handleStoreOutShipment(event);
    }
    if (event is ReActiveShipment) {
      yield* _handleReActiveShipment(event);
    }
    if (event is DispatchIssueShipment) {
      yield* _handleDispatchIssueShipment(event);
    }
    if (event is CancelShipment) {
      yield* _handleCancelShipment(event);
    }

    if (event is RejectShipment) {
      yield* _handleRejectShipment(event);
    }
    if (event is RescheduleShipment) {
      yield* _handleRescheduleShipment(event);
    }
    if (event is LostShipment) {
      yield* _handleLostShipment(event);
    }
    if (event is DamagedShipment) {
      yield* _handleDamagedShipment(event);
    }
    if (event is PostponeShipment) {
      yield* _handlePostponeShipment(event);
    }
    if (event is GetTheReceipt) {
      yield* _handleGetTheReceipt(event);
    }
    if (event is SendConfirmationMsg) {
      yield* _handleSendConfirmationMsg(event);
    }

    if (event is PickupActionsEventsGenerateError) {
      yield PickupActionsFailure(error: "general");
    }
  }
  Stream<PickupActionsStates> _handleSendConfirmationMsg(SendConfirmationMsg event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();
      MyResponseModel myResponseModel =
      await EventsApiCaptain.setMsgType(
          receiverId: event.receiverId,
          receiverPhone: event.receiverPhone,
           msgType: event.msgType
      );
      if (myResponseModel.statusCode == 200 ||myResponseModel.statusCode == 201||myResponseModel.statusCode == 204 ) {
        yield MsgSentSuccessfully();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleSendConfirmationMsg(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        print("Yes here ");
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }
  Stream<PickupActionsStates> _handleGetTheReceipt(GetTheReceipt event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      // yield PickupActionsLoading();
      MyResponseModel myResponseModel =
      await EventsApiCaptain.getReceipt(
          storeId: event.storeId,
          paymentMethod: event.method,
      );
      if (myResponseModel.statusCode == 200 ||myResponseModel.statusCode == 201 ) {
        yield ReceiptLoadedSuccess(receipt: myResponseModel.responseData);
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleGetTheReceipt(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleDeliverShipment(DeliverShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();
      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainDeliverShipment(
              token: token,
              id: event.id,
              amount: event.amount,
              paymentMethodId: event.paymentMethodId,
              code: event.code,
              receipt: event.receipt);
      if (myResponseModel.responseData) {
        yield PickupActionSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleDeliverShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleCancelShipment(CancelShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();

      // Iterable<CallLogEntry> entries = await CallLog.query(
      //   dateTimeFrom: DateTime.now().subtract(Duration(hours: 12))
      // );
      String courierPhone = await userRepository.getWorkingMobile();

      List<CallLogModel> logHistory = [] ;
      // for (CallLogEntry entry in entries) {
      //     if(entry.number == "0"+ (event.shipment.receiverPhone ?? "")){
      //     // if(entry.number == "0541090350"){
      //       logHistory.add(CallLogModel( number: entry.number , duration: entry.duration , timestamp: entry.timestamp ,
      //       sender: courierPhone , receiver: event.shipment.receiverPhone
      //       ));
      //     }
      // }
      // if(logHistory.isEmpty){
      //   yield NoCallNoCancel();
      //   return;
      // }

      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainCancelShipment(
              token: token, id: event.shipment.id, cancelId: event.cancelId , logHistory: logHistory);
      if (myResponseModel.responseData) {
        yield PickupActionSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleCancelShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleStoreOutShipment(StoreOutShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();
      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainStoreOutShipment(
              token: token, id: event.id);
      if (myResponseModel.responseData) {
        yield PickupActionSoreOutSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleStoreOutShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }
  Stream<PickupActionsStates> _handleReActiveShipment(ReActiveShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();
      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainReActiveShipment(token: token, id: event.shipment.id);
      if (myResponseModel.responseData) {
        yield PickupReActiveSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleReActiveShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleDispatchIssueShipment(DispatchIssueShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();
      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainDispatchShipment(
              token: token, id: event.id);
      if (myResponseModel.responseData) {
        print("yes PickupActionDispatchIssueSuccess ");
        yield PickupActionDispatchIssueSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleDispatchIssueShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handlePostponeShipment(PostponeShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();

      // Iterable<CallLogEntry> entries = await CallLog.query(
      //     dateTimeFrom: DateTime.now().subtract(Duration(hours: 12))
      // );
      String courierPhone = await userRepository.getWorkingMobile();

      List<CallLogModel> logHistory = [] ;
      // for (CallLogEntry entry in entries) {
      //   if(entry.number == "0"+ (event.shipment.receiverPhone ?? "")){
      //     // if(entry.number == "0541090350"){
      //     logHistory.add(CallLogModel( number: entry.number , duration: entry.duration , timestamp: entry.timestamp ,
      //         sender: courierPhone , receiver: event.shipment.receiverPhone
      //     ));
      //   }
      // }

      if(logHistory.isEmpty){
        yield NoCallNoCancel();
        return;
      }


      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainPostponeShipment(
              token: token, id: event.shipment.id, reason: event.reason , date: event.date , logHistory: logHistory);
      if (myResponseModel.responseData) {
        yield PickupActionSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handlePostponeShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleRejectShipment(RejectShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();

      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainRejectShipment(
              token: token, id: event.id, reason: event.reason);
      if (myResponseModel.responseData) {
        yield PickupActionSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleRejectShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleRescheduleShipment(RescheduleShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();

      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainRescheduleShipment(
              token: token, id: event.id, reason: event.reason);
      if (myResponseModel.responseData) {
        yield PickupActionSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleRescheduleShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleLostShipment(LostShipment event) async* {String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();

      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainLostShipment(
              token: token, id: event.id);
      if (myResponseModel.responseData) {
        yield PickupActionSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleLostShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }

  Stream<PickupActionsStates> _handleDamagedShipment(DamagedShipment event) async* {
    String? token = await userRepository.getAuthToken();

    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield PickupActionsFailure(error: 'TIMEOUT');
      return;
    } else {
      yield PickupActionsLoading();

      MyResponseModel myResponseModel =
          await EventsApiCaptain.captainDamagedShipment(
              token: token, id: event.id);
      if (myResponseModel.responseData) {
        yield PickupActionSuccess();
      } else if (myResponseModel.statusCode == 403) {
        String phone = await userRepository.getAuthPhone();
        String password = await userRepository.getAuthPassword();

        final MyResponseModel myResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (myResponse.responseData != null && myResponse.statusCode == 201 ||
            myResponse.statusCode == 200) {
          AuthenticationBloc authenticationBloc = AuthenticationBloc();

          await userRepository.persistToken(token: myResponse.responseData);

          authenticationBloc.add(LoggedIn(token: myResponse.responseData));

          yield* _handleDamagedShipment(event);
        } else {
          yield PickupActionsFailure(
            error: "invalidToken",
          );
        }
      } else if (myResponseModel.statusCode == 505) {
        yield PickupActionsFailure(
          error: "needUpdate",
        );
      } else {
        yield PickupActionsFailure(
            error: "error", errorList: myResponseModel.errorsList);
      }
    }
  }
}
