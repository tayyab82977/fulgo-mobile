import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xturbox/utilities/Constants.dart';


class ConfirmationDialog extends StatefulWidget {
   VoidCallback function ;
   String name ;
   ConfirmationDialog({required this.function , required this.name}) ;

  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15,),
            Text('Are you sure you want to remove this account from accounts ?'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            Text(widget.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Constants.blueColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text("Cancel".tr(),style: TextStyle(color: Colors.white),)),
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Constants.redColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text("Remove".tr(),style: TextStyle(color: Colors.white),)),
                      ),
                    ),
                    onTap: (){
                      widget.function();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
