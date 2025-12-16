
abstract class TicketsEvents {}


class GetTickets extends TicketsEvents {}
class PostTickets extends TicketsEvents {
  String shipmentId ;
  String cat ;
  String subject ;
  String description ;

  PostTickets({required this.description ,required this.subject , required this.cat , required this.shipmentId});
}


