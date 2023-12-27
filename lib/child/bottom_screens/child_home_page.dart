import 'dart:math';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_services.dart';
import 'package:flutter_application_1/model/contactsm.dart';
import 'package:flutter_application_1/widgets/home_widget/SafeHome/SafeHome.dart';
import 'package:flutter_application_1/widgets/home_widget/customCarouel.dart';
import 'package:flutter_application_1/widgets/home_widget/custom_appBar.dart';
import 'package:flutter_application_1/widgets/home_widget/emergency.dart';
import 'package:flutter_application_1/widgets/live_safe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';               
//import 'package:shake/shake.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();  
}

class _HomeScreenState extends State<HomeScreen> {
  //const HomeScreen({super.key});

  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;
  _getPermissions() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;
  _sendSms(String phoneNumber, String message, {int? simslot}) async {
    await BackgroundSms.sendMessage(
            phoneNumber: phoneNumber, message: message, simSlot: simslot)
        .then((SmsStatus status) {
      if (status == "sent") {
        Fluttertoast.showToast(msg: "sent");
      } else {
        Fluttertoast.showToast(msg: "failed");
      }
    });
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition!.latitude);
        _getAddressFromLatLon();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.locality},${place.postalCode},${place.street},";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true)
        .then((Position position) => setState(() {
              _currentPosition = position;
              print(_currentPosition!.latitude);
              _getAddressFromLatLon();
            }))
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

 

  int qIndex = 0;

  getRandomQuota() {
    Random random = Random();

    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  getAndSendSms() async {
    List<TContact> contactList = await DatabaseHelper().getContactList();

    String messageBody =
        "https://maps.google.com/?daddr=${_currentPosition!.latitude},${_currentPosition!.longitude}";
    if (await _isPermissionGranted()) {
      contactList.forEach((element) {
        _sendSms(
          "${element.number}",
          "I am in trouple please reach me out at $messageBody",
        );
      });
    } else {
      Fluttertoast.showToast(msg: "something went wrong");
    }
    ;
  }

  @override
  void initState() {
    getRandomQuota();
    super.initState();
    _getPermissions();
    _getCurrentLocation();
    //////Shake feature/////
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomAppBar(
              quoteIndex: qIndex,
              onTap: getRandomQuota(),
            ),
            CustomCarouel(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Emergency",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Emergency(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Explore Livesafe",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            LiveSafe(),
            SafeHome(),
          ],
        ),
      )),
    );
  }
}
