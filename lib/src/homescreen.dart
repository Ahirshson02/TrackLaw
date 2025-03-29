import 'package:flutter/material.dart';
import 'package:tracklaw/models.dart';

class Homescreen extends StatefulWidget{
  final List<Bill> bills;
  final Map<String, List<BillSummary>> summaries;
  
  Homescreen({Key? key, required this.bills, required this.summaries}) : super(key: key);
  @override
  State<Homescreen> createState() => _HomescreenState();

  
}

class _HomescreenState extends State<Homescreen>{
  TextEditingController _searchController = TextEditingController();
  String title = "title";
  
  //Future<BillWithSummaries> billAndSummaries = await getBillWithSummaries();
  @override
  Widget build(BuildContext context){
    print("In homescreen widget");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.person),
            onPressed: () async { showDialog(
              context: context,
              builder: (BuildContext buildContext){
                return AlertDialog(
                  title: Text("Turn this into sidebar menu for sign out and saved laws view")
                  );
              }
              );
            }
          ),
          actions: <Widget> [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200, // Adjust width as needed
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      border: OutlineInputBorder(),
                      labelText: 'Search bills',
                  ),
                ),
              ),
            )
          ],
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
                  return BillCard(bill: widget.bills[index]);
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
  // final String title;
  // final String status;
  // final String sponsor;
  // final String introduceDate;
  //final Function(String) onContentChanged;

  const BillCard({
    Key? key,
    required this.bill,
    // required this.title,
    // required this.status,
    // required this.sponsor,
    // required this.introduceDate,
  }) : super(key: key);

  @override
  State<BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bill.title ?? "no title",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: latest action desc. from summary of bill",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}