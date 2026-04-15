import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/clientPaymentsDataModel.dart';

class PaymentsAndProfile {
  
  ProfileDataModel? dashboardDataModel ;
  List<ClientPaymentsDataModel>? clientPaymentsDataList ;
  
  PaymentsAndProfile({this.clientPaymentsDataList , this.dashboardDataModel});
  
}