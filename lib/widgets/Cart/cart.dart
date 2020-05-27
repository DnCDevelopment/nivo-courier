import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:nivocourier/models/auth.dart';

class Cart extends StatefulWidget {
  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> {
  final Map<String, Marker> _markers = {};
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final _db = Firestore.instance;
  final BaseAuth _auth = Auth();

  Timer _timer;
  String _uid;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => _getCurrentLocation());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getUser();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getUser() async {
    FirebaseUser user = await _auth.getCurrentUser();
    setState(() {
      _uid = user.uid;
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      _db.collection('couriers').document(_uid).updateData(
          {"position": GeoPoint(position.latitude, position.longitude)});
      GoogleMapController controller = await _controller.future;
      try {
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
      } catch (err) {
        print(err);
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('couriers').document(_uid).snapshots(),
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
