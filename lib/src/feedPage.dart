import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:tracklaw/landingPage/openingPage.dart';
import 'package:tracklaw/billPage/legistlationPage.dart';
import 'package:tracklaw/models/congress.dart';
import '../apis/firebaseAPI.dart';

class FeedPage extends StatefulWidget{
  final List<Bill> bills;
  final Map<String, List<BillActions>> actions;
  final firestoreDb = FirebaseFirestore.instance;
  final FirestoreService f = FirestoreService();
  static String id = 'feed';
  
  FeedPage({Key? key, required this.bills, required this.actions}) : super(key: key);
  @override
  State<FeedPage> createState() => _FeedPageState();
  
}

class _FeedPageState extends State<FeedPage>{
  TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var summariesSize = 0;
  void initState() {
    super.initState();
    summariesSize = widget.actions.length; // Initialize it here
  }

  void logout() async{
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, WelcomePage.id);
  }

  
  @override
  Widget build(BuildContext context){
    print("In feed widget");
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
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
                  logout();
                }),
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
              child: FeedScroll(bills: widget.bills, actions: widget.actions),
            ),
          ]
        ),
      ),
    );
  }
}

class FeedScroll extends StatelessWidget {
  const FeedScroll({
    super.key,
    required this.bills,
    required this.actions
  });

  final List<Bill> bills;
  final Map<String, List<BillActions>> actions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        final action = actions[bill.billId] ?? []; // Default to empty list if null
        // print("bills length is ${widget.bills.length}");
        // print("bill ID: ${bill.billId}");
        // print("actions for this bill: ${actions.last.type}");
        // print("actions is empty? ${actions.isEmpty}");
        // print("length = ${actions.length}");
        action.first.printBillAction();
        print("--------------------------------");
      // print("last action: actions size: ${actions.length}");
        action.last.printBillAction();
        var mostRecentAction = (actions.isNotEmpty && actions.length > 0) 
            ? action.first // Or some other safe access
            : null;
  
        mostRecentAction?.committees = action.first.committees ?? [];
              
        return Consumer<UserNotifier>(
          builder: (context, user, child){
            return BillCard(
              bill: bill,
              action: mostRecentAction ?? BillActions(actionDate: "a", text: "a", type: "a", committees: [], actionCode: "a"), // Pass null if no summaries exist
              isPinned: user.user!.likes.contains(bills[index].billId)
            );
          },
        );
      },
      separatorBuilder: (context, index){
        return SizedBox(height: 8.0);
      }
    );
  }
}
class BillCard extends StatefulWidget {
  final Bill bill;
  final BillActions action;
  final bool isPinned;

  const BillCard({
    super.key,
    required this.bill,
    required this.action,
    required this.isPinned,
  });

  @override
  State<BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  FirestoreService fs = FirestoreService();
  String? actionStatus;
  String? committee;
  String? date;
  @override
  void initState() {
    super.initState();
    print("in billcardstate init");
    actionStatus = widget.action.type ?? "Progress Not Yet Set";
    actionStatus = splitCamelCase(actionStatus!); // Returns "Intro Referral"
    if(widget.action.committees!.isEmpty){
      committee = "No committee listed";
    }
    else{
      committee = widget.action.committees?.first.name ?? "No committee";
    }
    date = widget.action.actionDate ?? "d";
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
          minimumSize: Size(150,40),         // Set specific width and height
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
            //TODO: Condition icon and function based on if its in likes already. isLiked = user.user.likes.contains(billid)?
            Consumer<UserNotifier>(
              builder: (context, user, child){
                //add/remove like based on if its in user likes already
              return IconButton(
                onPressed: () async{ user.user!.likes.contains(widget.bill.billId) ? 
                ( user.removeLike(widget.bill.billId)) : (user.addLike(widget.bill.billId));
                print("state's likes after pressing: ${user.user!.likes}");}, 

                icon: user.user!.likes.contains(widget.bill.billId) ? 
                Icon(Icons.push_pin) :
                Icon(Icons.push_pin_outlined)
                ); 
              }
            )

            //const SizedBox(height: 16),
          ],
        ),
      ),
      onPressed: () async{
        Navigator.push(context, MaterialPageRoute(builder: (context) => LegistlationPage(bill: widget.bill, action: widget.action)),);
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