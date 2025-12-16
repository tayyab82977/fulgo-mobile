abstract class TrackingEvents {}

class GetTracking extends TrackingEvents {
  String? id ;
  GetTracking({this.id});
}

class TrackingEventsGenerateError extends TrackingEvents{}
