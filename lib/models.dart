import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';


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
    Future<Bill> getBills() async {
    final url = '$baseUrl/bill/?form=json&api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final bill = Bill.fromJson(data['bill']);
      return bill;
    } else {
      throw Exception('Failed to load bill: ${response.statusCode}');
    }
  }
  // Fetch summaries for a specific bill
  Future<List<BillSummary>> getBillSummaries(int congress, String billType, String billNumber) async {
    final url = '$baseUrl/bill/$congress/$billType/$billNumber/summaries?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Check if summaries exist
      if (data['summaries'] == null || data['summaries']['count'] == 0) {
        return [];
      }
      
      final summariesData = data['summaries']['billSummaries'] as List;
      return summariesData.map((summary) => BillSummary.fromJson(summary)).toList();
    } else {
      throw Exception('Failed to load bill summaries: ${response.statusCode}');
    }
  }
  
  // Convenience method to get a bill with its summaries
  Future<BillWithSummaries> getBillWithSummaries(int congress, String billType, String billNumber) async {
    final bill = await getBill(congress, billType, billNumber);
    final summaries = await getBillSummaries(congress, billType, billNumber);
    
    return BillWithSummaries(bill: bill, summaries: summaries);
  }
  
  // Search bills to find bills of interest
  //originall of 
  Future<List<Bill>> searchBills({

    int? congress,
    String? billType,
    int offset = 0,
    int limit = 20,
  }) async {
    String url = '$baseUrl/bill?api_key=$apiKey&offset=$offset&limit=$limit&format=json';
    
    //if (query != null) url += '&q=$query';
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

// Model class for bill search results (simplified)
class BillSearchResult {
  final int congress;
  final String billType;
  final String billNumber;
  final String title;
  final String updateDate;
  
  BillSearchResult({
    required this.congress,
    required this.billType,
    required this.billNumber,
    required this.title,
    required this.updateDate,
  });
  
  factory BillSearchResult.fromJson(Map<String, dynamic> json) {
    return BillSearchResult(
      congress: json['congress'],
      billType: json['type'],
      billNumber: json['number'],
      title: json['title'],
      updateDate: json['updateDate'],
    );
  }
  
  // Helper method to get the unique identifier for this bill
  String get billId => '$congress-$billType-$billNumber';
  
  @override
  String toString() {
    return '$billType $billNumber ($congress): $title';
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
  final List<Sponsor>? sponsors;
  final List<Cosponsors>? cosponsors;
  final List<PolicyArea>? policyAreas;
  final String? updateDate;
  
  Bill({
     this.congress,
     this.billType,
     this.billNumber,
     this.title,
     this.introducedDate,
     this.sponsors,
     this.cosponsors,
     this.latestAction,
     this.policyAreas,
     this.updateDate,
     this.chamberCode,
     this.originChamber,
     this.urlForMore,
  });
  
  factory Bill.fromJson(Map<String, dynamic> json) {
    // Extract sponsors
   // List<Sponsor> sponsors = [];
    // if (json['sponsors'] != null) {
    //   sponsors = (json['sponsors']['item'] as List)
    //       .map((sponsor) => Sponsor.fromJson(sponsor))
    //       .toList();
    // }
    
    // Extract cosponsors
    // List<Cosponsors> cosponsors = [];
    // if (json['cosponsors'] != null && json['cosponsors']['count'] > 0) {
    //   cosponsors = (json['cosponsors']['item'] as List)
    //       .map((cosponsor) => Cosponsors.fromJson(cosponsor))
    //       .toList();
    // }
    
    // Extract policy areas
    // List<PolicyArea> policyAreas = [];
    // if (json['policyArea'] != null) {
    //   if (json['policyArea'] is List) {
    //     policyAreas = (json['policyArea'] as List)
    //         .map((area) => PolicyArea.fromJson(area))
    //         .toList();
    //   } else {
    //     policyAreas = [PolicyArea.fromJson(json['policyArea'])];
    //   }
    // }
    Bill? bill = null;
    try{
      bill = Bill(
      congress: json['congress'],
      originChamber: json['orginChamber'],
      chamberCode: json['originChamberCode'],
      billType: json['type'],
      billNumber: json['number'],
      title: json['title'],
      //introducedDate: json['introducedDate'],
     // sponsors: sponsors,
      //cosponsors: cosponsors,
      latestAction: LatestAction.fromJson(json['latestAction']),
      //policyAreas: policyAreas,
      updateDate: json['updateDate'],
      urlForMore: json['url'],
    );
    }catch(e){
      print("exception when creaing Bill in fromJson");
      print(e.toString());
    }
    return bill!;
  }
  
  // Helper method to get the unique identifier for this bill
  String get billId => '$congress-$billType-$billNumber';
}

class Sponsor {
  final String name;
  final String bioguideId;
  final String state;
  final String party;
  
  Sponsor({
    required this.name,
    required this.bioguideId,
    required this.state,
    required this.party,
  });
  
  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      name: json['name'],
      bioguideId: json['bioguideId'],
      state: json['state'],
      party: json['party'],
    );
  }
}

class Cosponsors {
  final String name;
  final String bioguideId;
  final String state;
  final String party;
  final String sponsorshipDate;
  
  Cosponsors({
    required this.name,
    required this.bioguideId,
    required this.state,
    required this.party,
    required this.sponsorshipDate,
  });
  
  factory Cosponsors.fromJson(Map<String, dynamic> json) {
    return Cosponsors(
      name: json['name'],
      bioguideId: json['bioguideId'],
      state: json['state'],
      party: json['party'],
      sponsorshipDate: json['sponsorshipDate'],
    );
  }
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

class PolicyArea {
  final String name;
  
  PolicyArea({required this.name});
  
  factory PolicyArea.fromJson(Map<String, dynamic> json) {
    return PolicyArea(name: json['name']);
  }
}

// Bill Summary class
class BillSummary {
  final String name;
  final String updateDate;
  final String actionDate;
  final String actionDesc;
  final String text;
  final int versionCode;
  
  BillSummary({
    required this.name,
    required this.updateDate,
    required this.actionDate,
    required this.actionDesc,
    required this.text,
    required this.versionCode,
  });
  
  factory BillSummary.fromJson(Map<String, dynamic> json) {
    return BillSummary(
      name: json['name'],
      updateDate: json['updateDate'],
      actionDate: json['actionDate'],
      actionDesc: json['actionDesc'],
      text: json['text'],
      versionCode: json['versionCode'],
    );
  }
}

// Combined class for a bill with its summaries
class BillWithSummaries {
  final Bill bill;
  final List<BillSummary> summaries;
  
  BillWithSummaries({
    required this.bill,
    required this.summaries,
  });
  
  // Get the latest summary if available
  BillSummary? get latestSummary {
    if (summaries.isEmpty) return null;
    return summaries.reduce((a, b) => 
      a.versionCode > b.versionCode ? a : b);
  }
}
//---- END RESULTS OF https://api.congress.gov/#/bill/bill_list_all

