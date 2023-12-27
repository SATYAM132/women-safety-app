import 'package:flutter/material.dart';
import 'package:flutter_application_1/child/bottom_screens/contacts_page.dart';
import 'package:flutter_application_1/components/primaryButton.dart';
import 'package:flutter_application_1/db/db_services.dart';
import 'package:flutter_application_1/model/contactsm.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<TContact>? contactList;
  int count = 0;

  void showList() {
    Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((Database) {
      Future<List<TContact>> contactListFuture =
          databaseHelper.getContactList();
      contactListFuture.then((value) {
        setState(() {
          this.contactList = value;
          this.count = value.length;
        });
      });
    });
  }

  void deleteContact(TContact contact) async {
    int result = await databaseHelper.deleteContact(contact.id);
    if (result != 0) {
      Fluttertoast.showToast(msg: "contact removed successfully ");
      showList();
    }
  }

  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showList();
    });
    showList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (contactList == null) {
      contactList = [];
    }
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(children: [
        PrimaryButton(
            title: "Add Trasted Conntacts",
            onPressed: () async {
              bool result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ContactsPage()));
              if (result == true) {
                showList();
              }
            }),
        Expanded(
          child: ListView.builder(
              //shrinkWrap: true,
              itemCount: count,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(contactList![index].name),
                      trailing: Container(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                await FlutterPhoneDirectCaller.callNumber(
                                    contactList![index].number);
                              },
                              icon: Icon(
                                Icons.call,
                                color: Colors.red,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteContact(contactList![index]);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        )
      ]),
    );
  }
}
