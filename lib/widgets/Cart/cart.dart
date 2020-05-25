import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cart extends StatefulWidget {
  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> {
  final Map<String, Marker> _markers = {};

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final _db = Firestore.instance;
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => _getCurrentLocation());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      _db
          .collection('couriers')
          .document('QiaUhKLiCDdLKdzzretQPbgVlmf1')
          .updateData(
              {"position": GeoPoint(position.latitude, position.longitude)});
      GoogleMapController controller = await _controller.future;
      final icon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(24, 24)), 'assets/marker.png');
      final Marker marker = Marker(
        markerId: MarkerId("courier"),
        icon: icon,
        position: LatLng(
          position.latitude,
          position.longitude,
        ),
        onTap: () {},
      );
      setState(() {
        _markers["courier"] = marker;
      });
      controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 18));
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
      stream: _db
          .collection('couriers')
          .document('2w12Es2ZUocZ7XOF0nzg')
          .snapshots(),
      builder: (context, snapshot) {
        return GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: MapType.terrain,
          markers: _markers.values.toSet(),
          initialCameraPosition: CameraPosition(
            target: LatLng(50.448619, 30.522760),
            zoom: 11.0,
          ),
        );
      },
    ));
  }
}
