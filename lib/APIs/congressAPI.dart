import 'dart:convert';
import 'package:http/http.dart' as http;


//---- FOR RESULTS OF https://api.congress.gov/#/bill/bill_list_all ----

// Model classes
class CongressApiService {
  final String apiKey = "UEhogD6IZQBLsUcJynMpOiZ5cPsvLwvwsAuXlRDe";
  final String baseUrl = 'https://api.congress.gov/v3';
  
  CongressApiService();

  // Fetch a bill with its specific details
  Future<Bill> getBill(int congress, String billType, String billNumber) async {
    final url = '$baseUrl/bill/$congress/$billType/$billNumber?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final bill = Bill.fromJson(data['bill']);
      return bill;
    } else {
      throw Exception('Failed to load bill: ${response.statusCode}');
    }
  }
  
  Future<List<BillActions>> getBillActions(int congress, String billType, String billNumber) async{
    print("In getBillActions");
    billType = billType.toLowerCase(); //billType must be lowercase
    final url = '$baseUrl/bill/$congress/$billType/$billNumber/actions?api_key=$apiKey&format=json';
    print("getBillActions URL: $url");
     final response = await http.get(Uri.parse(url));
    //else if code == 404, put summary as null/default values
    if (response.statusCode == 200) {
      print("========= status code == 200");
      final data = json.decode(response.body);
      
      // Check if summaries exist
      if (data['actions'] == null) {
        print("getBillActions empty for billNumber $billNumber");
        return [];
      }
      
      if (data['actions'] is List) {
      final actionsData = data['actions'] as List;
      return actionsData.map((actions) => BillActions.fromJson(actions)).toList();
      } else {
        throw Exception("Unexpected format: 'actions' is not a list.");
      }
    }else {
      print('Bill $billNumber has no actions: ${response.statusCode}');
      Future<List<BillActions>> emptyList = Future.value(<BillActions>[]);
      return emptyList;
    }
  }

  // Fetch summaries for a specific bill
  Future<List<BillSummary>> getBillSummaries(int congress, String billType, String billNumber) async {
    billType = billType.toLowerCase(); //billType must be lowercase
    print("In getBillSummaries: congress: $congress, type: $billType, bill number: $billNumber");
    final url = '$baseUrl/bill/$congress/$billType/$billNumber/summaries?api_key=$apiKey&format=json';
   // final url = "https://api.congress.gov/v3/bill/117/s/3115/summaries?api_key=UEhogD6IZQBLsUcJynMpOiZ5cPsvLwvwsAuXlRDe&format=json";

    print("==== URL: $url");
    final response = await http.get(Uri.parse(url));
    //else if code == 404, put summary as null/default values
    if (response.statusCode == 200) {
      print("========= status code == 200");
      final data = json.decode(response.body);
      
      // Check if summaries exist
      if (data['summaries'] == null) {
        print("getBillSummaries empty for billNumber $billNumber");
        return [];
      }
      
      if (data['summaries'] is List) {
      final summariesData = data['summaries'] as List;
      return summariesData.map((summary) => BillSummary.fromJson(summary)).toList();
      } else {
        throw Exception("Unexpected format: 'summaries' is not a list.");
      }
    }else {
      print('Bill $billNumber has no summaries: ${response.statusCode}');
      Future<List<BillSummary>> emptyList = Future.value(<BillSummary>[]);
      return emptyList;
    }
  }

  // Search bills to find bills of interest
  //originall of 
  Future<List<Bill>> searchBills({
    int? congress,
    String? billType,
    int offset = 0,
    int limit = 1,
  }) async {
    String url = '$baseUrl/bill?api_key=$apiKey&offset=$offset&limit=$limit&format=json&fromDateTime=2024-01-01T12:30:30Z&toDateTime=2025-03-01T12:30:30Z';
    //&fromDateTime=2022-01-01T12:30:30Z&toDateTime=2024-01-01T12:30:30Z
    print("searchBills URL: $url");
    if (congress != null) url += '&congress=$congress';
    if (billType != null) url += '&billType=$billType';
    print("==== awaiting searchBills.response ====");
    final response = await http.get(Uri.parse(url));
    print("==== Gotten response =====");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final bills = data['bills'] as List;
      return bills.map((bill) => Bill.fromJson(bill)).toList();
    } else {
      throw Exception('Failed to search bills: ${response.statusCode}');
    }
  }
}
// Detailed bill model
class Bill {
  final int? congress;
  final LatestAction? latestAction;
  final String? billNumber;
  final String? originChamber;
  final String? chamberCode;
  final String? title;
  final String? billType;
  final String? introducedDate;
  final String? urlForMore;
  final String? updateDate;
  
  Bill({
     this.congress,
     this.billType,
     this.billNumber,
     this.title,
     this.introducedDate,
     this.latestAction,
     this.updateDate,
     this.chamberCode,
     this.originChamber,
     this.urlForMore,
  });
  
  factory Bill.fromJson(Map<String, dynamic> json) {
    Bill? bill = null;
    try{
      bill = Bill(
      congress: json['congress'],
      originChamber: json['orginChamber'],
      chamberCode: json['originChamberCode'],
      billType: json['type'],
      billNumber: json['number'],
      title: json['title'],
      latestAction: LatestAction.fromJson(json['latestAction']),
      updateDate: json['updateDate'],
      urlForMore: json['url'],
    );
    }catch(e){
      print("exception when creaing Bill in fromJson");
      print(e.toString());
    }
    return bill!;
  }
  Map<String, dynamic> toJson() {
  return {
    'congress': congress,
    //'latestAction': latestAction, // Assuming LatestAction has a toJson method
    'billNumber': billNumber,
    'originChamber': originChamber,
    'chamberCode': chamberCode,
    'title': title,
    'billType': billType,
    'introducedDate': introducedDate,
    'urlForMore': urlForMore,
    'updateDate': updateDate,
  };
}
  
  // Helper method to get the unique identifier for this bill
  String get billId => '$congress-$billType-$billNumber';
}


class LatestAction {
  final String actionDate;
  final String text;
  
  LatestAction({
    required this.actionDate,
    required this.text,
  });
  
  factory LatestAction.fromJson(Map<String, dynamic> json) {
    LatestAction? latestAction = null;
    try{
      latestAction = LatestAction(
        actionDate: json['actionDate'],
        text: json['text'],
    );
    }catch(e){
      print("exception in LatestAction.fromJson");
      print("Exception message: $e");
    }
   return latestAction!; 
  }
}


class BillActions {
  final String? actionCode;
  final String actionDate;
  List<Committee>? committees; //not made final each bill's most recent action lacks a committee value. Last action's committee is set to the first's
  final String text;
  final String type;

  BillActions({
    this.actionCode,
    required this.actionDate,
    this.committees,
    required this.text,
    required this.type,
  });

  factory BillActions.fromJson(Map<String, dynamic> json) {
    return BillActions(
      actionCode: json['actionCode'],
      actionDate: json['actionDate'],
      committees: json['committees'] != null
          ? List<Committee>.from(
              json['committees'].map((x) => Committee.fromJson(x)))
          : [],
      text: json['text'],
      type: json['type'],
    );
  }
  printBillAction(){
    print("action code: ${actionCode ?? "No code"}, actionDate: $actionDate");
    if(committees != null){
      for(Committee c in committees!){
        c.printCommittee();
      }
    }
    print("text: $text, type: $type");
  }
}

class Committee {
  final String name;
  final String systemCode;
  final String url;

  Committee({
    required this.name,
    required this.systemCode,
    required this.url,
  });

  factory Committee.fromJson(Map<String, dynamic> json) {
    return Committee(
      name: json['name'],
      systemCode: json['systemCode'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'systemCode': systemCode,
      'url': url,
    };
  }
  printCommittee(){
    print("Committee: $name");
  }
}

// Bill Summary class
class BillSummary {
  //final String name;
  final String? updateDate;
  final String? actionDate;
  final String? actionDesc;
  final String? text;
  final String? versionCode;
  
  BillSummary({
    //required this.name,
     this.updateDate,
     this.actionDate,
     this.actionDesc,
     this.text,
     this.versionCode,
  });
  
  factory BillSummary.fromJson(Map<String, dynamic> json) {
    return BillSummary(
      //name: json['name'],
      updateDate: json['updateDate'],
      actionDate: json['actionDate'],
      actionDesc: json['actionDesc'],
      text: json['text'],
      versionCode: json['versionCode'],
    );
  }
}


//---- END RESULTS OF https://api.congress.gov/#/bill/bill_list_all

