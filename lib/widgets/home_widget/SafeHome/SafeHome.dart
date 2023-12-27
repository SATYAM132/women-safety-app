import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/primaryButton.dart';
import 'package:flutter_application_1/db/db_services.dart';
import 'package:flutter_application_1/model/contactsm.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeHome extends StatefulWidget {
  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
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
  }

  void initState() {
    super.initState();
    _getPermissions();
    _getCurrentLocation();
  }

  ShowModelSafeHome(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.4,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SEND YOUR CURRENT LOCATION IMMEDIATELY TO YOUR EMERGENCY CONTACT",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (_currentPosition != null) Text(_currentAddress!),
                  PrimaryButton(
                      title: "SEND LOCATION",
                      onPressed: () {
                        _getCurrentLocation();
                      }),
                  SizedBox(
                    height: 10,
                  ),
                  PrimaryButton(
                      title: "SEND ALERT",
                      onPressed: () async {
                        List<TContact> contactList =
                            await DatabaseHelper().getContactList();
                        print(contactList.length);
                        String recipients = "";

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
                      }),
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ShowModelSafeHome(context),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 90,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(),
          child: Row(children: [
            Expanded(
                child: Column(
              children: [
                ListTile(
                  title: Text("Send Location"),
                  subtitle: Text("Share Location"),
                )
              ],
            )),
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/travel.png')),
          ]),
        ),
      ),
    );
  }
}
