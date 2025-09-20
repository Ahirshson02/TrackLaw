import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tracklaw/models/congress.dart';
import '../apis/firebaseAPI.dart';
import 'feedPage.dart';

class LikesPage extends StatefulWidget{

  LikesPage({Key? key}) : super(key: key);
  @override
  State<LikesPage> createState() => _LikesPageState();

}

class _LikesPageState extends State<LikesPage>{
  //get a bills and actions variable to use FeedScroll
  //instance of FirestoreService, call getFollowedBills to retrieve List<Bill>
  final FirestoreService fs = FirestoreService();
  //List<Bill> bills = [];
  
  @override
  void initState() {
    super.initState();
    //fetchLikedData();
    // Map<String, dynamic> data = fetchLikedData();
    // bills = data["bills"];
    // actions = data["actions"];
  }
  
  @override
  void dispose(){
    super.dispose();
  }

  Future<void> fetchLikedData() async{
    //construct bills cards from 
    final user = context.watch<UserNotifier>().user;
    //bills = await fs.getFollowedBills(user!.id);
    //bills = user!.likes;
    //print("end LikesPage().fetchlikedData()");
  }
  
  @override
  Widget build(BuildContext context){
    final bills = context.watch<UserNotifier>().user?.likes ?? [];
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //     primarySwatch: Colors.grey, // This affects the default focus color
    //     colorScheme: ColorScheme.light(
    //       primary: Colors.black, // This will affect focus colors
    //     ),
    //   ),
    //   home: 
      return Scaffold(
         appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 212, 163, 115),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_outlined, size: 30.0),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
           title: Center(
              child: SizedBox(
                width: 250, // Adjust width as needed
                child: Row(
                  spacing: 20,
                  children: [
                    Icon(Icons.push_pin),
                    Text("Tracked Bills"),
                  ],
                )
              ),
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
              child: FeedScroll(bills: bills),
            ),
          ]
        ),
      );//,
 //   );
  }
}

//UNUSED - remove if screen stops flashing on feedpage when like/unliking
class LikesScroll extends StatelessWidget {
  const LikesScroll({
    super.key,
    required this.bills,
   // required this.actions
  });

  final List<Bill> bills;
  //final Map<String, List<BillActions>> actions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.0),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        final action = bill.latestAction;
              
        //return Consumer<UserNotifier>(
        //  builder: (context, user, child){
            return BillCard(
              bill: bill,
              action: action ?? BillActions(actionDate: "a", text: "a", type: "a", committees: [], actionCode: "a"), // Pass null if no summaries exist
              //isPinned: user.user!.likes.contains(bills[index])
            );
        //  },
       // );
      },
      separatorBuilder: (context, index){
        return SizedBox(height: 8.0);
      }
    );
  }
}

