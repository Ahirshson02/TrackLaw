import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracklaw/api/congressAPI.dart';
import 'package:tracklaw/homescreen/homescreen.dart';

class LoadingScreen extends StatefulWidget {
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

    await Future.wait(bills.map((b) async {
      if (b.congress != null && b.billType != null && b.billNumber != null) {
        
        List<BillActions> actions = await api.getBillActions(
          b.congress!,
          b.billType!,
          b.billNumber!,
        );
        billNumberToActions[b.billId] = actions;
  
        print("billactions DONE");
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
        return Homescreen(
          bills: data["bills"] as List<Bill>,
          actions: data["actions"] as Map<String, List<BillActions>>,
        );
      },
    );
  }
}
