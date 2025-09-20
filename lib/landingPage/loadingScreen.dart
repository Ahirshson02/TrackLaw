import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracklaw/apis/congressAPI.dart';
import 'package:tracklaw/apis/firebaseAPI.dart';
import 'package:tracklaw/models/congress.dart';
import 'package:tracklaw/src/feedPage.dart';


class LoadingScreen extends StatefulWidget {
  static String id = 'loading_screen';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
    // Future<List<Bill>> fetchData() async {
  //   CongressApiService api = CongressApiService();
  //   //print("calling searchBills in loading screen");

  //   //List<Bill> bills = await api.searchBills();
  //   List<Bill> bills = context.watch<UserNotifier>().currentBills;
  //   print("In loadingScreenState: ${bills.length}");
  //   return bills;
  //  }

  @override
  Widget build(BuildContext context) {
    // Get bills directly in build method
    final bills = context.watch<UserNotifier>().currentBills;
    
    // No need for FutureBuilder if bills are already available
    if (bills.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FeedPage(bills: bills);
  }
}