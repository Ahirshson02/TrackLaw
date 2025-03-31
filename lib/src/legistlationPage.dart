import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tracklaw/APIs/congressAPI.dart';
import 'package:tracklaw/landingPage/loadingScreen.dart';
import 'package:tracklaw/src/chatInterface.dart';
import 'homescreen.dart';
import '/main.dart';
import '/APIs/firebaseAPI.dart';

class LegistlationPage extends StatefulWidget{

  final Bill bill;
  final BillActions action;

  LegistlationPage({Key? key, required this.bill, required this.action}) : super(key: key);
  @override
  State<LegistlationPage> createState() => _LegislationPageState();

}

class _LegislationPageState extends State<LegistlationPage>{
  CongressApiService congressAPI = CongressApiService();
  TextEditingController chatInput = TextEditingController();
  BillSummary? summary = BillSummary(); //create empty summary
  bool isLoading = true;

  final StreamController<ChatMessage> messageController = StreamController<ChatMessage>.broadcast();

  //ChatBox Data
    //Set up Firebase Cloud store API - select * from chathistory where userID = User.id AND billID = widget.bill.billID
    final List<ChatMessage> _messages = [
    ChatMessage(
      id: "1",
      userId: "1",
      billId: "1",
      text: "Hello! How can I help you today?",
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    )
  ];

  @override
  void initState(){
    super.initState();
    getSummary(widget.bill);
  }
  @override
  Widget build(BuildContext context){
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoading ? 
       Scaffold(
        appBar: AppBar(title: Text('Legislation Loading')),
        body: Center(child: CircularProgressIndicator()),
      ): Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 212, 163, 115),
          foregroundColor: Colors.white,
          //title: Text("Bill ${widget.bill.billNumber}"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.bill.title!,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary?.text ?? "not loaded",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                   ),
                ),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 236, 189, 142),
                            foregroundColor: Colors.black,
                            minimumSize: Size(15, 15),
                            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
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
                                "Read Bill",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingScreen()),);
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context); //download and save as a pdf
                          },
                         icon: Icon(Icons.file_download)
                      ),
                    ],
                   ),
                  const SizedBox(height: 8),
                  ChatContainer(messages: _messages, bill: widget.bill),
                  const SizedBox(height: 8),
                  ChatInput(bill: widget.bill)
              ],
            ),
          ),
        ), 
      )
    );
  }

  
  Future<void> getSummary(Bill bill) async{
    List<BillSummary> summaries = await congressAPI.getBillSummaries(bill.congress!,bill.billType!.toLowerCase(), bill.billNumber!);
    String errorMessage = "It looks like Congress has not yet created a summary for this bill. Check back later for updates";
        
    if(summaries.isNotEmpty && mounted){
      print("SUMMARIES IS NOT EMPTY. OR IS IT");
      setState(() {
        summary = summaries.last;
        isLoading = false;
      });
    }
    else{
      print("Bill ${bill.billId} has no summary");
      setState(() {
        this.summary = BillSummary(updateDate: "", actionDate: "", actionDesc: "", text: errorMessage, versionCode: "");
        isLoading = false;
      });
    }
  }
  Future<void> getFiles(Bill bill) async{
    BillData billData = await congressAPI.getBillFiles(bill.congress!, bill.billType!, bill.billNumber!);
    BillFormat? latestBill = billData.getLatestPdfFormat();
  }

  downLoadFile(File file){

  }


}