import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/events/acceptedOrder_events.dart';
import 'package:xturbox/blocs/states/acceptedOrder_states.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

class AcceptedOrderBloc extends Bloc<AcceptedOrderEvents, AcceptedOrderStates>{
  AcceptedOrderBloc() : super(AcceptedOrderInitial());

  @override
  Stream<AcceptedOrderStates> mapEventToState(AcceptedOrderEvents event) async*{
      List<OrdersDataModelMix> notAcceptedOrdersList = [] ;
     List<OrdersDataModelMix> acceptedOrdersList = [] ;

    if (event is AcceptThisOrder){
      yield AcceptedOrderLoaded(acceptedOrdersList: event.acceptedOrdersList, notAcceptedOrdersList: event.notAcceptedOrdersList);
    }
  }
}