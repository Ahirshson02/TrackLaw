import 'package:flutter/material.dart';
import 'package:tracklaw/src/homescreen.dart';
import 'package:tracklaw/models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  //make first API call here? to save time on homescreen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  CongressApiService api = CongressApiService();
  print("calling searchBills in main.dart");
  List<Bill> bills = await api.searchBills(); //gets initial homescreen results
  Map<String, List<BillSummary>> billNumberToSummary = {};
  for (Bill b in bills) {
    //null checks
  if (b.congress != null && b.billType != null && b.billNumber != null) {
    List<BillSummary> summaries = await api.getBillSummaries(
        b.congress!, b.billType!, b.billNumber!);
    // Add or update the map entry based on billId
    billNumberToSummary[b.billId] = summaries;
  }
}
  print("bills populated, calling homescreen");
  runApp(Homescreen(bills: bills, summaries: billNumberToSummary));
}
