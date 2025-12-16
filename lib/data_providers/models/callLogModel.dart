class CallLogModel {

  String? number;
  String? sender;
  String? receiver;
  int? duration;
  int? timestamp;


  CallLogModel({
    this.number,
    this.duration,
    this.timestamp,
    this.sender,
    this.receiver,
  });


  Map<String, dynamic> toJson() => {
    "number": number,
    "sender": sender,
    "receiver": receiver,
    "duration": generateDurationString(duration),
    "time": DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0).toString(),

  };
  generateDurationString(int? duration){
    int minutes = ((duration ?? 0) / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    int seconds = (duration ?? 0) % 60  ;
    String secondsStr = (seconds).toString().padLeft(2, '0');
    return minutesStr+":"+secondsStr ;
  }



}