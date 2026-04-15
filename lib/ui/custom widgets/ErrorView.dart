import 'package:flutter/material.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';

class ErrorView extends StatelessWidget {
  final String? errorMessage;
  final Function? retryAction;
  ErrorView({this.errorMessage, this.retryAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.warning,
              size: 50,
              color: Colors.red[800],
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.transparent),
              width: 250,
              child: ButtonTheme(
                height: 120,
                child: CustomButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(70),
                  ),
                  onPressed: retryAction as void Function()?,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey,
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Retry".tr(),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.refresh,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
