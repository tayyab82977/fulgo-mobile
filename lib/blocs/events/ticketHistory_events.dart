abstract class TicketsHistoryEvents {}


class GetTicketsHistory extends TicketsHistoryEvents {
  String ticketId ;
  GetTicketsHistory({required this.ticketId});
}