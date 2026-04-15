// import 'dart:io';
// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:Fulgox/utilities/isolates_workaround.dart';
// import 'package:test/test.dart';
// import 'package:faker/faker.dart';
//
// void main() {
//   group('Fulgo App', () {
//     // First, define the Finders and use them to locate widgets from the
//     // test suite. Note: the Strings provided to the `byValueKey` method must
//     // be the same as the Strings we used for the Keys in step 1.
//     final phoneLogin = find.byValueKey('phoneLogin');
//     final englishButton = find.byValueKey('englishButton');
//     final loginHomeButton = find.byValueKey('loginHomeButton');
//     final passWordLogin = find.byValueKey('passWordLogin');
//     final menuButton = find.byValueKey('menu');
//     final quickAccess = find.byValueKey('quickAccess');
//     final loginButton = find.byValueKey('loginButton');
//     final popMenu = find.byValueKey('popMenu');
//     final time = find.byValueKey('time');
//     final postOrder = find.byValueKey('postOrder');
//     final postOrderListView = find.byValueKey('addOrderScroll');
//     final receiverName = find.byValueKey('receiverName');
//     final receiverPhone = find.byValueKey('receiverPhone');
//     final receiverCity = find.byValueKey('receiverCity');
//     final receiverZone = find.byValueKey('receiverZone');
//     final receiverAddress = find.byValueKey('receiverAddress');
//     final receiverBuilding = find.byValueKey('receiverBuilding');
//     final receiverFloor = find.byValueKey('receiverFloor');
//     final receiverFlat = find.byValueKey('receiverFlat');
//     final rc = find.byValueKey('rc');
//     final addPackage = find.byValueKey('addPackage');
//     final fragile = find.byValueKey('fragile');
//     final cod = find.byValueKey('cod');
//     final codValue = find.byValueKey('codValue');
//     final packaging = find.byValueKey('packaging');
//     final comment = find.byValueKey('comment');
//     final savePackage = find.byValueKey('savePackage');
//     final newOrderSuccess = find.byValueKey('newOrderSuccess');
//
//     final home = find.byValueKey('home');
//     final profile = find.byValueKey('profile');
//     final payments = find.byValueKey('payments');
//     final myOrders = find.byValueKey('myOrders');
//     final myAddress = find.byValueKey('myAddress');
//     final myBank = find.byValueKey('myBank');
//     final route = find.byValueKey('route');
//     final profileName = find.byValueKey('profileName');
//     final profileMail = find.byValueKey('profileMail');
//     final editPrfBtn = find.byValueKey('editPrfBtn');
//     final orderCard = find.byValueKey('oderCard0');
//     final closeDetailedOrder = find.byValueKey('closeDtOrder');
//     final closeTracking = find.byValueKey('closeTracking');
//     final trackingBtn = find.byValueKey('trackingBtn');
//     final detailedOrderScroll = find.byValueKey('detailedOrderScroll');
//     final cancelShipment = find.byValueKey('cancelShipment');
//     final editShipment = find.byValueKey('editShipment');
//     final yesCancel = find.byValueKey('yesCancel');
//     final editSenderName = find.byValueKey('editSenderName');
//     final editRc = find.byValueKey('editRc');
//     final editOrderScroll = find.byValueKey('editOrderScroll');
//     final editReciName = find.byValueKey('editReciName');
//     final editShipmentBtn = find.byValueKey('editShipmentBtn');
//     final bankOwner = find.byValueKey('bankOwner');
//     final iban = find.byValueKey('iban');
//     final changeBankBtn = find.byValueKey('changeBankBtn');
//     final okBank = find.byValueKey('okBank');
//
//     var faker = new Faker();
//
//     FlutterDriver driver;
//     IsolatesWorkaround workaround;
//
//
//     // Connect to the Flutter driver before running any tests.
//     setUpAll(() async {
//       driver = await FlutterDriver.connect();
//       workaround = IsolatesWorkaround(driver);
//       await workaround.resumeIsolates();
//     });
//
//     // Close the connection to the driver after the tests have completed.
//
//     test('login process', () async {
//       // First, tap the button.
//
//
//       await driver.clearTimeline();
//
//       await driver.tap(englishButton);
//
//       // await driver.waitFor(find.text("You do not have account ?"));
//
//       //
//       await driver.tap(phoneLogin);
//       await driver.enterText("582224450");
//
//       await driver.tap(passWordLogin);
//       await driver.enterText("a");
//       await driver.tap(loginButton);
//
//
//
//
//     },
//         timeout: Timeout(
//         Duration(seconds: 40),
//     )
//     );
//
//
//     test('Add Shipment', () async {
//       // First, tap the button.
//
//
//       await driver.clearTimeline();
//
//       await driver.tap(quickAccess);
//       await driver.tap(time);
//       await driver.tap(find.text('ASAP'));
//       expect(await driver.getText(find.text('ASAP')), isNotNull);
//
//       await driver.tap(receiverName);
//       await driver.enterText(faker.person.name());
//       await driver.scroll(postOrderListView , 0, -200, Duration(milliseconds: 300));
//
//       await driver.tap(receiverPhone);
//       await driver.enterText(faker.randomGenerator.integer(599999999 , min:500000000 ).toString());
//
//       // await driver.tap(receiverCity);
//       // await driver.tap(find.text('Al Badai'));
//       // expect(await driver.getText(find.text('Al Badai')), isNotNull);
//       //
//       // await driver.tap(receiverZone);
//       // await driver.tap(find.text('al wusta'));
//       // expect(await driver.getText(find.text('al wusta')), isNotNull);
//
//       await driver.tap(receiverAddress);
//       await driver.enterText(faker.address.streetName());
//       await driver.scroll(postOrderListView , 0, -150, Duration(milliseconds: 300));
//
//       await driver.tap(receiverBuilding);
//       await driver.enterText(faker.randomGenerator.integer(100).toString());
//
//       await driver.tap(receiverFloor);
//       await driver.enterText(faker.randomGenerator.integer(100).toString());
//
//
//       await driver.tap(receiverFlat);
//       await driver.enterText(faker.randomGenerator.integer(100).toString());
//
//       await driver.scroll(postOrderListView , 0, -350, Duration(milliseconds: 300));
//
//       await driver.tap(rc);
//
//       await driver.tap(addPackage);
//       await driver.tap(fragile);
//       await driver.tap(cod);
//       await driver.tap(codValue);
//       await driver.enterText(faker.randomGenerator.integer(100).toString());
//
//       // await driver.tap(packaging);
//       // await driver.tap(find.text('Cold'));
//       // expect(await driver.getText(find.text('Cold')), isNotNull);
//
//       await driver.tap(comment);
//       await driver.enterText(faker.lorem.sentence());
//
//       await driver.tap(savePackage);
//
//       await driver.scroll(postOrderListView , 0, -300, Duration(milliseconds: 300));
//       await driver.tap(addPackage);
//       await driver.tap(cod);
//       await driver.tap(codValue);
//       await driver.enterText(faker.randomGenerator.integer(100).toString());
//       await driver.tap(comment);
//       await driver.enterText(faker.lorem.sentence());
//       await driver.tap(savePackage);
//
//       await driver.scroll(postOrderListView , 0, -300, Duration(milliseconds: 300));
//       await driver.tap(addPackage);
//       await driver.tap(comment);
//       await driver.enterText(faker.lorem.sentence());
//       await driver.tap(savePackage);
//
//       await driver.scroll(postOrderListView , 0, -350, Duration(milliseconds: 300));
//
//       await driver.tap(postOrder);
//       await driver.tap(newOrderSuccess);
//
//
//       await driver.waitFor(find.text("My Shipments"));
//     },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//     test('cancel Shipment', () async {
//       // First, tap the button.
//
//
//       await driver.clearTimeline();
//       await driver.tap(menuButton);
//       await driver.tap(myOrders);
//       await driver.waitFor(find.text("From : "));
//       await driver.tap(orderCard);
//
//       await driver.waitFor(find.text("Shipment information"));
//       await driver.tap(cancelShipment);
//       await driver.tap(yesCancel);
//
//       await driver.waitFor(find.text("My Shipments"));
//
//
//
//     },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//
//     test('edit Shipment', () async {
//       // First, tap the button.
//
//
//       await driver.clearTimeline();
//       await driver.tap(menuButton);
//       await driver.tap(myOrders);
//       await driver.waitFor(find.text("From : "));
//       await driver.tap(orderCard);
//
//       await driver.waitFor(find.text("Shipment information"));
//       await driver.tap(editShipment);
//
//       await driver.scroll(editOrderScroll , 0, -100, Duration(milliseconds: 300));
//
//       await driver.tap(editReciName);
//       await driver.enterText(faker.person.name());
//       await driver.scroll(editOrderScroll , 0, -500, Duration(milliseconds: 300));
//       await driver.tap(editRc);
//       await driver.tap(editShipmentBtn);
//
//       await driver.waitFor(find.text("My Shipments"));
//
//       },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//
//     test('open Shipment', () async {
//       // First, tap the button.
//
//
//       await driver.clearTimeline();
//       await driver.tap(menuButton);
//       await driver.tap(myOrders);
//       await driver.waitFor(find.text("From : "));
//       await driver.tap(orderCard);
//
//       await driver.waitFor(find.text("Shipment information"));
//       await driver.scroll(detailedOrderScroll , 0, -500, Duration(milliseconds: 300));
//       await driver.tap(trackingBtn);
//       await driver.waitFor(find.text("Order Placed"));
//
//       await driver.tap(closeTracking);
//       await driver.scroll(detailedOrderScroll , 0,500, Duration(milliseconds: 300));
//
//       await driver.tap(closeDetailedOrder);
//       await driver.waitFor(find.text("My Shipments"));
//     },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//
//     test('change profile', () async {
//       await driver.clearTimeline();
//       await driver.tap(menuButton);
//       await driver.tap(profile);
//       await driver.tap(profileName);
//       await driver.enterText(faker.person.name());
//       await driver.tap(profileMail);
//       await driver.enterText(faker.internet.email());
//       await driver.tap(editPrfBtn);
//
//       await driver.waitFor(find.text("Quick access"));
//
//
//     },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//     test('my payment', () async {
//       await driver.clearTimeline();
//       await driver.tap(menuButton);
//       await driver.tap(payments);
//
//
//       await driver.waitFor(find.text("fee"));
//       await driver.tap(menuButton);
//       await driver.tap(home);
//
//       await driver.waitFor(find.text("Quick access"));
//       },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//
//     test('my addresses', () async {
//       await driver.clearTimeline();
//       await driver.tap(menuButton);
//       await driver.tap(myAddress);
//
//
//       await driver.waitFor(find.text("My addresses"));
//       await driver.tap(menuButton);
//       await driver.tap(home);
//
//       await driver.waitFor(find.text("Quick access"));
//     },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//
//     test('change bank data', () async {
//       await driver.clearTimeline();
//       await driver.tap(menuButton);
//       await driver.tap(myBank);
//
//
//       await driver.waitFor(find.text("My Bank Account"));
//       await driver.tap(bankOwner);
//       await driver.enterText(faker.person.name());
//       await driver.tap(changeBankBtn);
//       await driver.tap(okBank);
//
//
//       await driver.waitFor(find.text("Quick access"));
//     },
//         timeout: Timeout(
//           Duration(seconds: 30),
//         )
//     );
//
//     tearDownAll(() async {
//       if (driver != null) {
//         driver.close();
//         await workaround.tearDown();
//       }
//     });
//
//   });
// }