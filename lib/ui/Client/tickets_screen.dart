import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xturbox/blocs/bloc/tickets_bloc.dart';
import 'package:xturbox/blocs/events/tickets_events.dart';
import 'package:xturbox/blocs/states/tickets_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/tickets_model.dart';
import 'package:xturbox/ui/custom%20widgets/ErrorView.dart';
import 'package:xturbox/ui/custom%20widgets/home_button.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/Client/tickets_add.dart';
import 'package:xturbox/ui/Client/tiketsHistory_screen.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';

import '../custom widgets/custom_loading.dart';


class TicketsScreen extends StatefulWidget {
  final ResourcesData resourcesData ;
  TicketsScreen({required this.resourcesData});
  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {

  double? screenWidth , screenHeight , width , height ;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  String total = "" ;
  TextEditingController editingControllerToStore = TextEditingController();
  List<TicketsModel> ticketsList1 = [];
  List<TicketsModel> ticketsList2 = [];

  void filterSearchResults(String query , List<TicketsModel> list1 , List<TicketsModel> list2   ) {
    List<TicketsModel> dummySearchList = [];
    dummySearchList.addAll(list2);
    if(query.isNotEmpty) {
      List<TicketsModel> dummyListData = [];
      dummySearchList.forEach((item) {
        if(item.id!.contains(query) || item.shipment!.contains(query) || item.subject!.contains(query) || item.ticketCategoryName!.contains(query) ) {
          dummyListData.add(item);
        }
      });
      setState(() {
        list1.clear();
        list1.addAll(dummyListData);


      });
      return;
    } else {
      setState(() {
        list1.clear();
        list1.addAll(list2);

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return BlocProvider(
      create: (context)=>TicketsBloc()..add(GetTickets()),
      child: Scaffold(
        backgroundColor: Constants.clientBackgroundGrey,
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  const ClientAppBar(),
                  Expanded(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: screenWidth!*0.03),
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/ticket.svg",
                                    placeholderBuilder: (context) => CustomLoading(),
                                    height: 38.0,
                                  ),
                                  SizedBox(width: 15,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('My Tickets'.tr(),
                                        style:TextStyle(
                                            fontSize: 17,
                                            height: 0.3,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        children: [
                                          Text( total ,
                                            style:TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff4c8ff8)
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          Text('Ticket'.tr(),
                                            style:TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff4c8ff8)
                                            ),
                                          ),
                                        ],
                                      ),


                                    ],

                                  )
                                ],
                              ),
                              FlatButton(
                                height: 30,
                                color:Constants.blueColor ,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.all(0),
                                highlightColor: Colors.black,
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddTicketScreen(
                                            resourcesData: widget.resourcesData,
                                          )));
                                },
                                child: Center(child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8 , vertical: 5),
                                  child: AutoSizeText('New Ticket'.tr(),
                                    style: TextStyle(color: Colors.white, fontSize: 14),),
                                )),


                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Padding(
                            padding: EdgeInsets.only(left: 12, right:12 , top: 8),
                            child: TextFormField(
                                autofocus: false,
                                onChanged: (value){
                                  filterSearchResults(value , ticketsList1 , ticketsList2 );
                                  total = ticketsList1.length.toString();

                                },
                                controller: editingControllerToStore,
                                decoration: kTextFieldDecoration2.copyWith(
                                  hintText: 'Search'.tr(),
                                  hintStyle: TextStyle(fontSize: 12),
                                  suffixIcon: Icon(Icons.search , color: Constants.blueColor,),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  ),

                                )
                            ),
                          ),
                          SizedBox(height: 20,),
                          Expanded(
                            child: BlocConsumer<TicketsBloc , TicketsStates>(
                              builder: (context , state){
                                if(state is TicketsLoaded){
                                  return  RefreshIndicator(
                                    onRefresh: ()async{
                                      BlocProvider.of<TicketsBloc>(context).add(GetTickets());
                                    },
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: ticketsList1.length,
                                        itemBuilder: (context , i){
                                          return _ticketsCard(ticketsList1[i]);
                                        }),
                                  );
                                }
                                else if (state is TicketsError){
                                  return ErrorView(
                                    errorMessage: "",
                                    retryAction: (){
                                      BlocProvider.of<TicketsBloc>(context).add(GetTickets());
                                    },
                                  );
                                }
                               return Center(child: CustomLoading(),);
                              },
                              listener: (context , state){
                                if(state is TicketsLoaded){
                                  state.ticketsList.forEach((element) {
                                    element.ticketCategoryName = IdToName.idToName("ticketCategory", element.categoryId ?? "");
                                  });
                                  setState(() {
                                    ticketsList1 = state.ticketsList.map((element)=>element).toList();
                                    ticketsList2 = state.ticketsList.map((element)=>element).toList();
                                    total = ticketsList1.length.toString();
                                  });

                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: HomeButton()),
          ],
        ),
      ),
    );
  }

  _ticketsCard(TicketsModel ticketsModel){
    String? status = IdToName.idToName("ticketStatus", ticketsModel.status ?? "");
    return GestureDetector(
      onTap: (){
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return TicketHistoryScreen(
                ticketId: ticketsModel.id ?? "",
                ticketsModel: ticketsModel,
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)
          ),
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( ticketsModel.id ??"", style: TextStyle(color: Colors.black , fontSize: 14 , fontWeight: FontWeight.bold ,),),

                            Text( ticketsModel.subject ??"", style: TextStyle(color: Colors.black , fontSize: 16 , fontWeight: FontWeight.bold),),
                            Text(ticketsModel.ticketCategoryName ?? "", style: TextStyle(color: Constants.blueColor , fontSize: 16 ,),maxLines: 2,),

                          ],
                        )),
                        Container(
                          decoration: BoxDecoration(
                              color: ticketsModel.status == "3" ? Colors.green.withOpacity(0.7) : ticketsModel.status == "1" ?  Constants.redColor.withOpacity(0.7) : Constants.blueColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(status ?? "", style: TextStyle(color: Colors.white , fontSize: 13 ,),maxLines: 2,),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Text("Shipment Id".tr() + " : " + ticketsModel.shipment.toString(), style: TextStyle(color: Colors.black , fontSize: 16),),
                    Text( ticketsModel.description ?? "", style: TextStyle(color: Colors.black , fontSize: 16),),
                    SizedBox(height: 10,),
                    //TODO fix here ..
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Text(DateFormat('yyyy-MM-dd').format(DateFormat("yyyy-MM-dd").parse(ticketsModel.createdAt ?? "2023-01-01 20:29:02")) , style: TextStyle(color: Colors.black38 , fontSize: 14),textAlign: TextAlign.start,),
                    //   ],
                    // ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
