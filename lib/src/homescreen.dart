import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracklaw/main.dart';
import 'package:tracklaw/APIs/congressAPI.dart';
import 'package:tracklaw/src/legistlationPage.dart';
import '/APIs/firebaseAPI.dart';

class Homescreen extends StatefulWidget{
  final List<Bill> bills;
  final Map<String, List<BillActions>> actions;
  final firestoreDb = FirebaseFirestore.instance;
  final FirestoreService f = FirestoreService();

  
  Homescreen({Key? key, required this.bills, required this.actions}) : super(key: key);
  @override
  State<Homescreen> createState() => _HomescreenState();
  
}

class _HomescreenState extends State<Homescreen>{
  TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var summariesSize = 0;
  void initState() {
    super.initState();
    summariesSize = widget.actions.length; // Initialize it here
  }

  
  @override
  Widget build(BuildContext context){
    print("In homescreen widget");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.grey, // This affects the default focus color
          colorScheme: ColorScheme.light(
            primary: Colors.black, // This will affect focus colors
          ),
        ),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 212, 163, 115),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.person, size: 30.0),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          
           title: Center(
              child: SizedBox(
                width: 250, // Adjust width as needed
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                      
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                    labelText: 'Search bills',
                    fillColor: Colors.white,
                    filled: true,
                    focusColor: Colors.black,
                  ),
                ),
              ),
            ),
          actions: <Widget> [],//fill more later?
        ),
        drawer: Drawer(
          width: 200,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 212, 163, 115),
                ),
                child: Text(
                  'Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton.icon(
                icon: Icon(Icons.feed_sharp, size: 40.0),
                label: Text('Tracked Laws'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  // Close the drawer first
                  Navigator.pop(context);
                  // TODO: Replace with your navigation
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton.icon(
                icon: Icon(Icons.logout, size: 40.0),
                label: Text('Sign out'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  // Close the drawer first
                  Navigator.pop(context);
                  // TODO: Replace with your navigation
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SavedLawsPage()));
                },
              ),
            ),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.sort)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.filter)),
                ],
              ),
            ),
            // Bills list - using Expanded is crucial here
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.0),
                itemCount: widget.bills.length,
                itemBuilder: (context, index) {
                  final bill = widget.bills[index];
                  final actions = widget.actions[bill.billId] ?? []; // Default to empty list if null
                        // print("bills length is ${widget.bills.length}");
                        // print("bill ID: ${bill.billId}");
                        // print("actions for this bill: ${actions.last.type}");
                        // print("actions is empty? ${actions.isEmpty}");
                        // print("length = ${actions.length}");
                        actions.first.printBillAction();
                        print("--------------------------------");
                        print("last action: actions size: ${actions.length}");
                        actions.last.printBillAction();
                        var mostRecentAction = (actions.isNotEmpty && actions.length > 0) 
                            ? actions.first // Or some other safe access
                            : null;
                        mostRecentAction?.committees = actions.first.committees;

                  return BillCard(
                    bill: bill,
                    action: mostRecentAction!, // Pass null if no summaries exist
                  );
                },
                separatorBuilder: (context, index){
                  return SizedBox(height: 8.0);
                }
              ),
            ),
          ]
        ),
      ),
    );
  }
}
class BillCard extends StatefulWidget {
  final Bill bill;
  final BillActions action;
  // final String title;
  // final String status;
  // final String sponsor;
  // final String introduceDate;
  //final Function(String) onContentChanged;

  const BillCard({
    Key? key,
    required this.bill,
    required this.action,
    // required this.title,
    // required this.status,
    // required this.sponsor,
    // required this.introduceDate,
  }) : super(key: key);

  @override
  State<BillCard> createState() => _BillCardState();

}

class _BillCardState extends State<BillCard> {
  String? actionStatus;
  String? committee;
  String? date;
  @override
  void initState() {
    super.initState();
    print("in billcardstate init");
    if(widget?.action == null){
      print("action is null");
      return;
    }
    actionStatus = widget.action?.type ?? "Progress Not Yet Set";
    actionStatus = splitCamelCase(actionStatus!); // Returns "Intro Referral"
    committee = widget.action?.committees?[0].name ?? "No committee";
    date = widget.action?.actionDate;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 236, 189, 142),       // Button background color
          //foregroundColor: Colors.white,      // Text/icon color
          minimumSize: Size(150, 40),         // Set specific width and height
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black, width: 2),
          ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bill.title ?? "No title",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
               maxLines: 3,
               overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              child: Row(
                children: [
                  Text("Status: ${actionStatus ?? "Unknown"}"),
                  Text(" | ", style: TextStyle(fontSize: 20)),
                  Text(date ?? "Date Missing"),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Committee: ${committee ?? "Unknown"}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      onPressed: () async{
          final FirestoreService f = FirestoreService();
          f.saveBill(widget.bill);
        //Navigator.push(context, MaterialPageRoute(builder: (context) => LegistlationPage(bill: widget.bill, action: widget.action)),);
      },
    );
  }
  
  String splitCamelCase(String input) {
  // Add a space before each capital letter that isn't at the start of the string
  return input.replaceAllMapped(
    RegExp(r'(?<=[a-z])(?=[A-Z])'),
    (match) => ' '
  );
}
}