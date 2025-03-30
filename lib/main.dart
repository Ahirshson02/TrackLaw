import 'package:flutter/material.dart';
import 'package:tracklaw/src/homescreen.dart';
import 'package:tracklaw/models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //make first API call here? to save time on homescreen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
//   CongressApiService api = CongressApiService();
//   print("calling searchBills in main.dart");
//   List<Bill> bills = await api.searchBills(); //gets initial homescreen results
//   Map<String, List<BillSummary>> billNumberToSummary = {};
//   for (Bill b in bills) {
//     //null checks
//   if (b.congress != null && b.billType != null && b.billNumber != null) {
//     List<BillSummary> summaries = await api.getBillSummaries(
//         b.congress!, b.billType!, b.billNumber!);
//     // Add or update the map entry based on billId
//     billNumberToSummary[b.billId] = summaries;
//   }
// }
//   print("bills populated, calling homescreen");
  // runApp(Homescreen(bills: bills, summaries: billNumberToSummary));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingScreen(), // Show a loading screen first
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<Map<String, dynamic>> fetchData() async {
    CongressApiService api = CongressApiService();
    print("calling searchBills in loading screen");
    
    List<Bill> bills = await api.searchBills();
    Map<String, List<BillActions>> billNumberToActions = {};

    await Future.wait(bills.map((b) async {
      if (b.congress != null && b.billType != null && b.billNumber != null) {
        List<BillActions> actions = await api.getBillActions(
          b.congress!, b.billType!, b.billNumber!,
        );
        billNumberToActions[b.billId] = actions;
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
