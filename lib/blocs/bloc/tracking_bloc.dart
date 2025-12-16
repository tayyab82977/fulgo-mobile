import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/events/tracking_events.dart';
import 'package:xturbox/blocs/states/tracking_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class TrackingBloc extends Bloc<TrackingEvents , TrackingStates>{
  TrackingBloc() : super(TrackingInitial());

  @override
  Stream<TrackingStates> mapEventToState(TrackingEvents event)async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield TrackingError(
          error: 'TIMEOUT',
      );

      return;
    }

    if (event is GetTracking){
      // yield TrackingLoading();
    yield*  _handelGetTracking(event);
    }


    if(event is TrackingEventsGenerateError){
      yield TrackingError(
          error: "general"
      );
    }

  }

  Stream<TrackingStates> _handelGetTracking(GetTracking event)async*{
    yield TrackingLoading();
    MyResponseModel myResponseModel = await EventsAPIs.getTracking(id: event.id);
    if (myResponseModel.statusCode == 200){
      yield TrackingLoaded(
          trackingList: myResponseModel.responseData
      );

    }
    else if (myResponseModel.statusCode == 204){
      yield TrackingError(
        error: "inValidShipment",
      );
    }
    else if(myResponseModel.statusCode == 505) {
      yield TrackingError(
        error: "needUpdate",
      );
    }
    else {
      yield TrackingError(
          error: 'error'
      );
    }

  }


}