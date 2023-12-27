//import 'dart:html';

//import 'dart:ffi';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_services.dart';
import 'package:flutter_application_1/model/contactsm.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFilter = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  TextEditingController searchController = TextEditingController();
  void initState() {
    super.initState();
    askPermission();
  }

  String flatterPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filterContact() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlattren = flatterPhoneNumber(searchTerm);
        String contactName = element.displayName!.toLowerCase();
        bool nameMatch = contactName.contains(searchTerm);
        if (nameMatch == true) {
          setState(() {
            contactsFilter = _contacts;
          });
          //return true;
        }
        if (searchTermFlattren.isEmpty) {
          return false;
        }
        var phone = element.phones!.firstWhere((p) {
          String phnFlattered = flatterPhoneNumber(p.value!);
          return phnFlattered.contains(searchTermFlattren);
        });
        return phone.value != null;
      });
    }
    setState(() {
      contactsFilter = _contacts;
    });
  }

  Future<void> askPermission() async {
    PermissionStatus permissionStatus = await getContactsPermissionn();
    if (permissionStatus == PermissionStatus.granted) {
      getAllContacts();
      searchController.addListener(() {
        filterContact();
      });
    } else {
      handInvalidPermission(permissionStatus);
    }
  }

  handInvalidPermission(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      dialogueBox(context, "Access to the contacts denied by the user");
    } else {
      dialogueBox(context, "May contacts does exist in this device");
    }
  }

  Future<PermissionStatus> getContactsPermissionn() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted ||
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  getAllContacts() async {
    List<Contact> _contacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listItemExit = (contactsFilter.length > 0 || contacts.length > 0);
    return Scaffold(
        body: contacts.length == 0
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "search contact",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    listItemExit == true
                        ? Expanded(
                            child: ListView.builder(
                                itemCount: isSearching == true
                                    ? contactsFilter.length
                                    : contacts.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Contact contact = isSearching == true
                                    ? contactsFilter[index]
                                    : contacts[index];
                                  return ListTile(
                                    title: Text(contact.displayName!),
                                    subtitle: Text(
                                        contact.phones!.elementAt(0).value!),
                                    leading: contact.avatar != null &&
                                            contact.avatar!.length > 0
                                        ? CircleAvatar(
                                            backgroundColor: primaryColor,
                                            backgroundImage:
                                                MemoryImage(contact.avatar!),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: primaryColor,
                                            child: Text(contact.initials()),
                                          ),
                                    onTap: () {
                                      if (contact.phones!.length > 0) {
                                        final String phoneNum =
                                            contact.phones!.elementAt(0).value!;
                                        final String name =
                                            contact.displayName!;
                                        _addContact(TContact(phoneNum, name));
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Oops! phone number Doesn't exits");
                                      }
                                    },
                                  );
                                }),
                          )
                        : Container(
                            child: Text("searching"),
                          ),
                  ],
                ),
              ));
  }

  void _addContact(TContact newContact) async {
    int result = await _databaseHelper.insertContact(newContact);
    if (result != 0) {
      Fluttertoast.showToast(msg: "contact added successfully");
    } else {
      Fluttertoast.showToast(msg: "failed to add contact");
    }
    Navigator.of(context).pop(true);
  }
}
