import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/ticketHistory_bloc.dart';
import 'package:xturbox/blocs/events/ticketHistory_events.dart';
import 'package:xturbox/blocs/states/ticketHistory_states.dart';
import 'package:xturbox/data_providers/models/tickets_model.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';



class TicketHistoryScreen extends StatefulWidget {
  String ticketId ;
  TicketsModel ticketsModel ;
  TicketHistoryScreen({ required this.ticketId , required this.ticketsModel});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=> TicketsHistoryBloc()..add(GetTicketsHistory(ticketId: widget.ticketId)),
      child: Dialog(
        backgroundColor:Constants.clientBackgroundGrey,
        child: Column(
          children: [
            SizedBox(height: 10,),
            Text( widget.ticketsModel.subject ?? "", style: TextStyle(color: Colors.black , fontSize: 22),),
            Expanded(
              child: BlocConsumer<TicketsHistoryBloc , TicketsHistoryStates>(
                builder: (context , state){
                  if(state is TicketsHistoryLoaded){
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: state.list?.isNotEmpty ?? false ?
                      ListView.builder(
                          itemCount: state.list?.length,
                          itemBuilder: ( context , i ){
                            return _ticketHistoryCard(state.list?[i]);
                          }
                        ): Center(
                          child: Text("We still working on your ticket".tr() , style: TextStyle(
                          color: Constants.blueColor , fontSize: 16
                      ),),
                        ),
                    );

                  }
                  else if (state is TicketsHistoryError ){
                    return ErrorView(
                      errorMessage: "Something went wrong please try again".tr(),
                      retryAction:(){
                        BlocProvider.of<TicketsHistoryBloc>(context).add(GetTicketsHistory(ticketId: widget.ticketId));
                      },
                    );
                  }
                  return Center(
                    child: CustomLoading(),
                  );
                },
                listener: (context , state){},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Constants.blueColor, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ok'.tr()),
              ),
            )
          ],
        ) ,
      ),
    );
  }

  _ticketHistoryCard(TicketsHistoryModel? ticketsHistoryModel) {
    String? status = IdToName.idToName("ticketStatus", ticketsHistoryModel?.statusId ?? "");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(  ticketsHistoryModel?.comment ?? "",style: TextStyle(fontSize: 15),),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //TODO fix here..
                  // Text(DateFormat('yyyy-mm-dd').format(DateFormat("yyyy-mm-dd").parse(ticketsHistoryModel?.updatedAt ?? "2023-01-01 20:29:02")) , style: TextStyle(color: Colors.black , fontSize: 16),),

                  Container(
                      decoration: BoxDecoration(
                          color: Constants.blueColor,
                          borderRadius: BorderRadius.circular(25)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(status ?? "" , style: TextStyle(color: Colors.white , fontSize: 12),),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
