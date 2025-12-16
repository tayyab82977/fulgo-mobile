import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xturbox/blocs/bloc/tickets_bloc.dart';
import 'package:xturbox/blocs/events/tickets_events.dart';
import 'package:xturbox/blocs/states/tickets_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/ui/Client/tickets_screen.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import '../custom widgets/home_button.dart';
import '../custom widgets/myAppBar.dart';


class AddTicketScreen extends StatefulWidget {
  final ResourcesData resourcesData ;
  AddTicketScreen({required this.resourcesData});
  @override
  _AddTicketScreenState createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {

  double? screenWidth , screenHeight , width , height ;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  final _shipmentIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  Cancellation? _selectedTicketCat;


  @override
  void initState() {
    try{
      _selectedTicketCat = SavedData.resourcesData.ticketCategory?.first ;
    }catch(e){}
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return ProgressHUD(
      backgroundColor: Constants.blueColor,
      child: BlocProvider(
        create: (context) => TicketsBloc(),
        child: Scaffold(
          backgroundColor: Constants.clientBackgroundGrey,
          key: _drawerKey,
          body: Column(
            children: [
              Expanded(
                flex: 6,
                child: Form(
                  key:_formKey ,
                  child: Column(
                    children: [
                      const ClientAppBar(),
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal:screenWidth!*0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/ticket.svg",
                                  placeholderBuilder: (context) =>
                                      CustomLoading(),
                                  height: 38.0,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New Ticket'.tr(),
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),

                                  ],
                                )
                              ],
                            ),
                            EasyLocalization.of(context)!.locale == Locale('en')?
                            MaterialButton(
                              minWidth: 40,
                              height: screenHeight! * 0.055,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 5,),
                                  Text('Back'.tr(),
                                      style: TextStyle(
                                        color: Colors.black,
                                      )),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ):
                            MaterialButton(
                              minWidth: 40,
                              height: screenHeight! * 0.055,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [


                                  Text('Back'.tr(),
                                      style: TextStyle(
                                        color: Colors.black,
                                      )),
                                  SizedBox(width: 5,),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: BlocConsumer<TicketsBloc , TicketsStates>(
                          builder: (context , state ){
                            return _createAddTicketScreen( BlocProvider.of<TicketsBloc>(context));
                          },
                          listener: (context , state){
                            if(state is TicketsLoading){
                              final progress = ProgressHUD.of(context);
                              progress?.show();
                            }
                            else if (state is TicketsAddSuccess){
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context)=>TicketsScreen(resourcesData: widget.resourcesData)
                              ));
                            }
                            else {
                              final progress = ProgressHUD.of(context);
                              progress?.dismiss();
                            }

                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),

        ),
      ),
    );
  }
  _createAddTicketScreen(TicketsBloc ticketsBloc){
    return Container(
      color: Constants.clientBackgroundGrey,
      child: Padding(
        padding: EdgeInsets.only(right: screenWidth!*0.03, left: screenWidth!*0.03, top: screenHeight!*0.01 ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Shipment number".tr(), style: TextStyle(fontSize: 16 , color: Colors.black)),
                    SizedBox(height: 5,),
                    TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'please enter the shipment id'.tr();
                        }
                        return null;
                      },
                      decoration:
                      kTextFieldDecoration2.copyWith(),
                      controller: _shipmentIdController,
                    ),
                    SizedBox(height: 10,),
                    Text("Category".tr(), style: TextStyle(fontSize: 16 , color: Colors.black)),
                    SizedBox(height: 5,),
                    Container(
                      width: width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Cancellation>(
                            onTap: (){
                              FocusScope.of(context).unfocus();
                            },
                            items: SavedData.resourcesData.ticketCategory?.map((Cancellation
                            dropDownStringItem) {
                              return DropdownMenuItem<Cancellation>(
                                value: dropDownStringItem,
                                child: Text(
                                   dropDownStringItem.name ?? "",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14),
                                ) ,
                              );
                            }).toList(),
                            onChanged: (Cancellation? newValue) {
                              setState(() {
                                _selectedTicketCat = newValue!;
                              });
                            },
                            value: _selectedTicketCat,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text("Subject".tr(), style: TextStyle(fontSize: 16 , color: Colors.black)),
                    SizedBox(height: 5,),
                    TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'please enter the subject'.tr();
                        }
                        return null;
                      },
                      decoration:
                      kTextFieldDecoration2.copyWith(),
                      controller: _titleController,
                    ),
                    SizedBox(height: 10,),
                    Text("Description".tr(), style: TextStyle(fontSize: 16 , color: Colors.black)),
                    SizedBox(height: 5,),
                    TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'please enter the description'.tr();
                        }
                        return null;
                      },
                      decoration: kTextFieldDecoration2.copyWith(),
                      maxLines: 5,
                      controller: _descriptionController,
                    ),


                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ButtonTheme(
                minWidth: screenWidth!,
                height: 50,
                child: FlatButton(
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: Constants.blueColor,
                    textColor: Colors.white,
                    child: Text(
                      'Add Ticket'.tr(),
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        ticketsBloc.add(PostTickets(
                            cat: _selectedTicketCat?.id.toString() ?? "" , description: _descriptionController.text,
                            shipmentId: _shipmentIdController.text, subject: _titleController.text));
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
