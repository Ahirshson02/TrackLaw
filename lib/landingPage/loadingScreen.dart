import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracklaw/apis/congressAPI.dart';
import 'package:tracklaw/models/congress.dart';
import 'package:tracklaw/src/feedPage.dart';


class LoadingScreen extends StatefulWidget {
  static String id = 'loading_screen';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  
  final user = FirebaseAuth.instance.currentUser!;
  Future<Map<String, dynamic>> fetchData() async {
    CongressApiService api = CongressApiService();
    print("calling searchBills in loading screen");

    List<Bill> bills = await api.searchBills();
    Map<String, List<BillActions>> billNumberToActions = {};
    if(bills.isEmpty){
      bills.add(Bill.fromJson({
      "congress": 118,
      "orginChamber": "House",
      "chamberCode": "H",
      "billType": "HR",
      "billNumber": "123",
      "title": "To improve healthcare access in rural communities and for other purposes.",
      "latestAction": {
        "actionDate": "2024-03-15",
        "text": "Referred to the Committee on Energy and Commerce."
      },
      "introducedDate": "2024-03-01T:10:30:00Z",
      "updateDate": "2024-03-15T10:30:00Z",
      "urlForMore": "https://www.congress.gov/bill/118th-congress/house-bill/1234"
      }));

      billNumberToActions[bills[0].billId] = [BillActions.fromJson(
        {
        "actionCode": "Intro-H",
        "actionDate": "2024-03-15",
        "committees": [
          {
            "name": "Committee on Energy and Commerce",
            "systemCode": "hsif00",
            "url": "https://www.congress.gov/committee/house-energy-and-commerce"
          }
        ],
        "text": "Introduced in House",
        "type": "IntroReferral"
      }
      )];
      return{
        "bills": bills,
        "actions": billNumberToActions,
      };
    } //end if bills.isEmpty
    await Future.wait(bills.map((b) async {
      if (b.congress != null && b.billType != null && b.billNumber != null) {
        
        List<BillActions> actions = await api.getBillActions(
          b.congress!,
          b.billType!,
          b.billNumber!,
        );
        billNumberToActions[b.billId] = actions;
  
       // print("billactions DONE");
      }
      
    }));

    print("bills populated, navigating to homescreen");

    return {
      "bills": bills,
      "actions": billNumberToActions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchData(), // Fetch data in background
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Show loader
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        // When data is ready, navigate to HomeScreen
        final data = snapshot.data!;
        return FeedPage(
          bills: data["bills"] as List<Bill>,
          actions: data["actions"] as Map<String, List<BillActions>>,
        );
      },
    );
  }
}
