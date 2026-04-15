import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/utilities/Constants.dart';

class MyMap extends StatefulWidget {
  // final OrdersDataModelMix ordersDataModelMix;
  MyMap({this.taker, this.shipmentId});
  String? taker;
  String? shipmentId;
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  PolylinePoints polylinePoints =
      PolylinePoints(apiKey: Constants.googleMabiApiKey);

  _getRoute() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
      origin: PointLatLng(21.5371171, 39.2022873),
      destination: PointLatLng(21.5842335, 39.2056292),
      mode: TravelMode.driving,
    ));

    print(result.status.toString() + " points status");
    print(result.points.length.toString() + " points number");
    print(result.errorMessage.toString() + " errorMessage number");
  }

  @override
  void initState() {
    _getRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.taker);
    print(widget.shipmentId);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.shipmentId ?? "",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Constants.blueColor,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('location')
              .where('courier', isEqualTo: widget.taker)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (_added) {
              mymap(snapshot);
            }
            if (snapshot.hasData) {
              print(snapshot.data?.docs.length);
              print(snapshot.data?.docs.first['latitude']);
              return GoogleMap(
                mapType: MapType.normal,
                markers: {
                  Marker(
                      position: LatLng(
                        snapshot.data?.docs.first['latitude'],
                        snapshot.data?.docs.first['longitude'],
                      ),
                      markerId: MarkerId('id'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure)),
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      snapshot.data?.docs.first['latitude'],
                      snapshot.data?.docs.first['longitude'],
                    ),
                    zoom: 14.47),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                    _added = true;
                  });
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data?.docs.first['latitude'],
              snapshot.data?.docs.first['longitude'],
            ),
            zoom: 14.47)));
  }
}
