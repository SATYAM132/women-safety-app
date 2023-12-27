import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_application_1/child/child_login_screen.dart';
import 'package:flutter_application_1/components/custom_textfield.dart';
import 'package:flutter_application_1/components/primaryButton.dart';
//import 'package:flutter_application_1/utils/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameC = TextEditingController();
  final key = GlobalKey<FormState>();
  String? id;
  String? profilePic;
  String? downloadUrl;
  bool isSaving = false;
  getData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        nameC.text = value.docs.first['name'];
        id = value.docs.first.id;
        profilePic = value.docs.first['profilePic'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isSaving == true
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.pink,
            ))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Form(
                      key: key,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "UPDATE YOUR PROFILE",
                            style: TextStyle(fontSize: 25),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final XFile? pickImage = await ImagePicker()
                                  .pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 50);
                              if (pickImage != null) {
                                setState(() {
                                  profilePic = pickImage.path;
                                });
                              }
                            },
                            child: Container(
                              child: profilePic == null
                                  ? CircleAvatar(
                                      radius: 80,
                                      child: Center(
                                          child: Image.asset(
                                        'assets/add_pic.png',
                                        height: 80,
                                        width: 80,
                                      )),
                                    )
                                  : profilePic!.contains('http')
                                      ? CircleAvatar(
                                          radius: 40,
                                          backgroundImage:
                                              NetworkImage(profilePic!),
                                        )
                                      : CircleAvatar(
                                          radius: 40,
                                          backgroundImage:
                                              FileImage(File(profilePic!)),
                                        ),
                            ),
                          ),
                          CustomTextField(
                            controller: nameC,
                            hintText: nameC.text,
                            validate: (v) {
                              if (v!.isEmpty) {
                                return 'please enter your updated name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          PrimaryButton(
                              title: "UPDATE",
                              onPressed: () async {
                                if (key.currentState!.validate()) {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  profilePic == null
                                      ? Fluttertoast.showToast(
                                          msg: 'please select profile picture')
                                      : update();
                                }
                              })
                        ],
                      )),
                ),
              ),
            ),
    );
  }

  // ignore: body_might_complete_normally_nullable
  Future<String?> uploadImage(String filePath) async {
    try {
      final fileName = Uuid().v4();
      final Reference fbStorage =
          FirebaseStorage.instance.ref('profile').child(fileName);
      final UploadTask uploadTask = fbStorage.putFile(File(filePath));
      await uploadTask.then((p0) async {
        downloadUrl = await fbStorage.getDownloadURL();
      });
      return downloadUrl;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  update() async {
    setState(() {
      isSaving = true;
    });
    uploadImage(profilePic!).then((value) {
      Map<String, dynamic> data = {
        'name': nameC.text,
        'profilepic': downloadUrl,
      };
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(data);
     setState(() {
      isSaving = false;
    });
    });
   
  }
}
