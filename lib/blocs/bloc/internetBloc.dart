// import 'dart:async';

//
// import 'package:connectivity/connectivity.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:xturbox/blocs/states/internet_state.dart';
// import 'package:xturbox/blocs/events/internet_event.dart';
// import 'package:bloc/bloc.dart';
//
// class InternetBloc extends Bloc<InternetEvent, InternetState> {
//   StreamSubscription _streamSubscription;
//
//   InternetBloc() : super(Initial()) {
//     _streamSubscription = Connectivity()
//         .onConnectivityChanged
//         .listen((ConnectivityResult result) {
//       if (result == ConnectivityResult.mobile ||
//           result == ConnectivityResult.wifi) {
//         emit(Connected());
//       } else {
//         emit(Disconnected());
//       }
//     });
//   }
//
//   @override
//   Stream<InternetState> mapEventToState(InternetEvent event) async* {
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<void> close() {
//     _streamSubscription.cancel();
//     return super.close();
//   }
// }
