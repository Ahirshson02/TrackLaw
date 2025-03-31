import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracklaw/APIs/congressAPI.dart';
import 'package:tracklaw/landingPage/loadingScreen.dart';
import 'package:tracklaw/src/chatInterface.dart';
import 'package:tracklaw/src/pdfViewer.dart';
import 'homescreen.dart';
import '/main.dart';
import '/APIs/firebaseAPI.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser; // For simple parsing
import 'package:html_unescape/html_unescape.dart';


class LegistlationPage extends StatefulWidget{

  final Bill bill;
  final BillActions action;
  File? pdf;

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

  String? localPath;
  bool fileIsLoading = true;
  int totalPages = 0;
  int currentPage = 0;


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
    getFiles(widget.bill);
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
                          print("localpath on press: $localPath");
                          if (localPath == "NOPATH") {
                            // Show the alert dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Uh oh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 138, 74, 69),
                                    ),
                                  ),
                                  content: Text("It looks like Congress hasn't publized the contents of this bill just yet. Please check back later"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Navigate to PDF viewer
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => PDFViewerPage(filePath: localPath!),
                              ),
                            );
                          }
                        },
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     Navigator.pop(context); //download and save as a pdf
                      //     },
                      //    icon: Icon(Icons.file_download)
                      // ),
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
      setState(() {
        summary = summaries.last;
        if(summary!.text!.isNotEmpty){
          summary?.text = convertToPlainText(summary!.text!);
        }
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
   static String convertToPlainText(String htmlString) {
    if (htmlString == null || htmlString.isEmpty) {
      return '';
    }

    final unescape = HtmlUnescape();
    // Parse the HTML
    var document = htmlparser.parse(htmlString);
    // Get the text content
    String parsedText = document.body?.text ?? '';
    // Decode HTML entities like &nbsp;
    String decodedText = unescape.convert(parsedText);
    
    // Remove extra whitespace
    return decodedText.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> getFiles(Bill bill) async{
    print("bill in getFiles: congress ${bill.congress}, type: ${bill.billType}, number: ${bill.billNumber}");
    BillData billData = await congressAPI.getBillFiles(bill.congress!, bill.billType!.toLowerCase(), bill.billNumber!);
    BillFormat? latestBill = billData.getLatestPdfFormat();
    print("billpath: ${latestBill?.url}");
    await downloadAndSavePDF(latestBill?.url ?? "");
    //await downloadAndSavePDF("https://www.congress.gov/117/bills/hr3076/BILLS-117hr3076enr.pdf");
  }

Future<void> downloadAndSavePDF(String url) async {
    if(url == "" || url.isEmpty){
      setState(() {
        localPath = "NOPATH";
      });
      print("localpat = $localPath");
      return;
    }
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      // Create a unique filename based on URL
      final filename = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$filename';
      
      // Download the PDF from URL
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Save the PDF to the local path
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        setState(() {
          localPath = filePath;
          fileIsLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        fileIsLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }



}