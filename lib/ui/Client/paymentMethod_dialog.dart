import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/paymentMethod_bloc.dart';
import 'package:xturbox/blocs/events/paymentMethod_events.dart';
import 'package:xturbox/blocs/states/paymentMethod_states.dart';
import 'package:xturbox/ui/custom%20widgets/customCheckBox.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/utilities/Constants.dart';

import '../../data_providers/models/memberBalanceModel.dart';
import '../../data_providers/models/savedData.dart';


class PaymentMethodDialog extends StatefulWidget {

  final ValueChanged<PaymentMethods> paymentMethod ;
   PaymentMethodDialog({required this.paymentMethod}) ;

  @override
  _PaymentMethodDialogState createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  bool receiverPayCheckedValue = false;
  bool deductFromOfferCheckedValue = false;
  bool payAtPickupChecked = false;
  bool deductFromCod = false;
  @override
  Widget build(BuildContext context) {

    _resetValues(List<PaymentMethods>? paymentMethods  ,String? selectedId){

      paymentMethods?.forEach((element) {
        if(element.id != selectedId){
          element.selected = false ;
        }
      });

    }
    return BlocProvider(
        create: (context)=>PaymentMethodBloc()..add(GetPaymentMethod()),

      child: Dialog(

        child: BlocConsumer<PaymentMethodBloc,PaymentMethodStates>(
          builder: (context,state){
            if(state is PaymentMethodLoaded){
              return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Constants.blueColor,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("Payment method".tr(),style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
                        ),
                      ),
                      Flexible(
                        child: RefreshIndicator(
                          onRefresh: ()async{
                            BlocProvider.of<PaymentMethodBloc>(context).add(GetPaymentMethod());
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 3,
                                  direction: Axis.horizontal,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Constants.blueColor,
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Balance".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                            Text( " "+state.clientBalanceModel.balance.toString()+ " "+"SR".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                          ],
                                        ),
                                      ),
                                    ),
                                    state.clientBalanceModel.wallet != null ?
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Constants.blueColor,
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Wallet".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                            Text( " "+(state.clientBalanceModel.wallet?.deposit.toString() ??"")+ " "+"SR".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                          ],
                                        ),
                                      ),
                                    ) : SizedBox(),

                                    // (state.clientBalanceModel.offer?.isNotEmpty ?? false) ? Container(
                                    //   decoration: BoxDecoration(
                                    //       color: Constants.blueColor,
                                    //       borderRadius: BorderRadius.circular(8)
                                    //   ),
                                    //   child: Column(
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       Padding(
                                    //         padding: const EdgeInsets.symmetric(horizontal: 8),
                                    //         child: Text("Offers".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //       ),
                                    //       Row(
                                    //         mainAxisAlignment: MainAxisAlignment.start,
                                    //         mainAxisSize: MainAxisSize.min,
                                    //         children: [
                                    //           for(int i = 0 ; i < (state.clientBalanceModel.offer?.length ?? 0) ; i++)
                                    //             Padding(
                                    //               padding: const EdgeInsets.all(8.0),
                                    //               child: Row(
                                    //                 crossAxisAlignment: CrossAxisAlignment.center,
                                    //                 mainAxisSize: MainAxisSize.min,
                                    //                 children: [
                                    //                   Text(state.clientBalanceModel.offer?[i].distance ??"",style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                   Text( " "+(state.clientBalanceModel.offer?[i].count ??"" ),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //         ],
                                    //       ),
                                    //
                                    //     ],
                                    //   ),
                                    // ) : SizedBox(),
                                    // (state.clientBalanceModel.packageOffer?.isNotEmpty ?? false) ? Container(
                                    //   decoration: BoxDecoration(
                                    //       color: Constants.blueColor,
                                    //       borderRadius: BorderRadius.circular(8)
                                    //   ),
                                    //   child: Column(
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       Padding(
                                    //         padding: const EdgeInsets.symmetric(horizontal: 8),
                                    //         child: Text("Package Offers".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //       ),
                                    //       Row(
                                    //         mainAxisAlignment: MainAxisAlignment.start,
                                    //         mainAxisSize: MainAxisSize.min,
                                    //         children: [
                                    //           for(int i = 0 ; i < (state.clientBalanceModel.packageOffer?.length ?? 0) ; i++)
                                    //             Flexible(
                                    //               child: Container(
                                    //                 decoration: BoxDecoration(
                                    //                   border: Border.all(color: Colors.white)
                                    //                 ),
                                    //                 child: Padding(
                                    //                   padding: const EdgeInsets.all(8.0),
                                    //                   child: Wrap(
                                    //                     children: [
                                    //                       Flexible(child: Text(state.clientBalanceModel.packageOffer?[i].distance ??"",style: TextStyle(fontSize: 15,color: Colors.white),)),
                                    //                       Flexible(child: Row(
                                    //                         children: [
                                    //                           Text( "Packaging".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                           Text( " "+(state.clientBalanceModel.packageOffer?[i].package ??"" ),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                         ],
                                    //                       )),
                                    //                       Flexible(child: Row(
                                    //                         children: [
                                    //                           Text( "Weight".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                           Text( " "+(state.clientBalanceModel.packageOffer?[i].weight ??"" ),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                         ],
                                    //                       )),
                                    //                       Flexible(child: Row(
                                    //                         children: [
                                    //                           Text( "Count".tr(),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                           Text( " "+(state.clientBalanceModel.packageOffer?[i].count ??"" ),style: TextStyle(fontSize: 15,color: Colors.white),),
                                    //                         ],
                                    //                       )),
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //         ],
                                    //       ),
                                    //
                                    //     ],
                                    //   ),
                                    // ) : SizedBox()
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children:state.clientBalanceModel.paymentMethods?.map((e){
                                  return  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          e.selected = !(e.selected ?? true)  ;
                                          widget.paymentMethod(e);
                                          _resetValues(state.clientBalanceModel.paymentMethods, e.id);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: AutoSizeText(
                                              e.name ?? "",
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: e.selected ?? false
                                                      ? Constants.blueColor
                                                      : Colors.black87),
                                            ),
                                          ),

                                          SizedBox(width: 8),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              unselectedWidgetColor:
                                              Colors.black54,
                                            ),
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CustomCheckBox(
                                                checkedColor:
                                                Constants.blueColor,
                                                unCheckedColor: Colors.grey,
                                                backgroundColor: Colors.white,
                                                checked: e.selected,
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  );
                                }).toList() ?? [],
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  )
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CustomLoading(),
                )),
              ],
            );
          },
          listener: (context,state){},
        ),

      ),

    );
  }
}
