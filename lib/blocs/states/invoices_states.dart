import 'package:xturbox/blocs/events/invoices_events.dart';
import 'package:xturbox/data_providers/models/invoices_lists_model.dart';
import 'package:xturbox/data_providers/models/invoices_model.dart';

abstract class InvoicesStates {}


class InvoicesInitial extends InvoicesStates {}
class InvoicesLoading extends InvoicesStates {}
class InvoicesLoaded extends InvoicesStates {
  InvoicesListsModel? invoicesListsModel ;
  InvoicesLoaded({this.invoicesListsModel});
}
class InvoicesError extends InvoicesStates {
  InvoicesEvents? failedEvent ;
  String? error ;
  InvoicesError({this.failedEvent,this.error});
}
