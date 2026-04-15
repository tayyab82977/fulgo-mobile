import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';

class MyPickupScreen extends StatefulWidget {
  @override
  _MyPickupScreenState createState() => _MyPickupScreenState();
}

class _MyPickupScreenState extends State<MyPickupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyPickup'.tr()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'This screen is being migrated to GetX',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please use the alternative screens for now',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
