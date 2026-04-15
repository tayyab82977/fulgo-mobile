import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/controllers/tickets_controller.dart';

class TicketsScreen extends StatefulWidget {
  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final TicketsController _ticketsController = Get.put(TicketsController());

  @override
  void initState() {
    super.initState();
    _ticketsController.getTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickets'.tr()),
      ),
      body: Obx(() {
        if (_ticketsController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (_ticketsController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading tickets'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _ticketsController.getTickets(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (_ticketsController.ticketsList.value?.isEmpty ?? true) {
          return Center(child: Text('No tickets found'));
        }
        
        return ListView.builder(
          itemCount: _ticketsController.ticketsList.value?.length ?? 0,
          itemBuilder: (context, index) {
            final ticket = _ticketsController.ticketsList.value![index];
            return ListTile(
              title: Text(ticket.subject ?? ''),
              subtitle: Text(ticket.status ?? ''),
              onTap: () {
                // Navigate to ticket details
              },
            );
          },
        );
      }),
    );
  }
}
