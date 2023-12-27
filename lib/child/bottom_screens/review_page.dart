//import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_1/components/SecondaryButton.dart';
import 'package:flutter_application_1/components/custom_textfield.dart';
import 'package:flutter_application_1/components/primaryButton.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:geocoding/geocoding.dart';

class ReviewPage extends StatefulWidget {
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController locationC = TextEditingController();
  TextEditingController viewsC = TextEditingController();
  bool isSaving = false;
  showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return  AlertDialog(
                  title: Text("Review your place"),
                  content: Form(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextField(
                          hintText: 'enter location',
                          controller: locationC,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomTextField(
                          hintText: 'enter location',
                          controller: viewsC,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  )),
                  actions: [
                    PrimaryButton(
                        title: "save",
                        onPressed: () {
                          saveReview();
                           Navigator.pop(context);
                        }),
                    TextButton(
                        child: Text("cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                );
        });
  }

  saveReview() async {
    setState(() {
      isSaving = true;
    });
    await FirebaseFirestore.instance
        .collection('reviews')
        .add({'location': locationC.text, 'views': viewsC.text}).then((value) {
      setState(() {
        isSaving = false;
        Fluttertoast.showToast(msg: 'review uploade successfully');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving == true
              ? Center(child: CircularProgressIndicator())
              :
      SafeArea(
        child: Column(
          children: [
            Text(
              
                     "Recent Review by other ",
                     style: TextStyle(fontSize: 30, color: Colors.black),
                                
            ),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final data = snapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              elevation: 10,
                              //color: Colors.primaries[Random().nextInt(17)],
                              child: ListTile(
                                title: Text(
                                  data['location'],
                                  style: TextStyle(fontSize: 20, color: Colors.black),
                                ),
                                subtitle: Text(data['views']),
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          showAlert(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
