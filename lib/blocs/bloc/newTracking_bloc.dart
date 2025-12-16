import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/events/newTracking_events.dart';
import 'package:xturbox/blocs/states/newTracking_states.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/utilities/NetworkUtilities.dart';

class NewTrackingBloc extends Bloc<NewTrackingEvents , NewTrackingStates>{
  NewTrackingBloc() : super(NewTrackingInitial());

  @override
  Stream<NewTrackingStates> mapEventToState(NewTrackingEvents event)async* {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      yield NewTrackingError(
        error: 'TIMEOUT',
      );

      return;
    }

    if (event is GetNewTracking){
      // yield TrackingLoading();
      yield*  _handelGetTracking(event);
    }


    // if(event is TrackingEventsGenerateError){
    //   yield TrackingError(
    //       error: "general"
    //   );
    // }

  }

  Stream<NewTrackingStates> _handelGetTracking(GetNewTracking event)async*{
    yield NewTrackingLoading();
    MyResponseModel myResponseModel = await EventsAPIs.getTracking(id: event.id);
    if (myResponseModel.statusCode == 200){
      yield NewTrackingLoaded(
          trackingList: myResponseModel.responseData
      );

    }
    else if (myResponseModel.statusCode == 204){
      yield NewTrackingError(
        error: "inValidShipment",
      );
    }
    else if(myResponseModel.statusCode == 505) {
      yield NewTrackingError(
        error: "needUpdate",
      );
    }
    else {
      yield NewTrackingError(
          error: 'error'
      );
    }

  }


}