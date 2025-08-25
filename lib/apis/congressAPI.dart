import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tracklaw/models/congress.dart';


//---- FOR RESULTS OF https://api.congress.gov/#/bill/bill_list_all ----


class CongressApiService {
  final String apiKey = dotenv.env['CONGRESS_API'] ?? "";
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

  Future<List<BillActions>> getBillActions(int congress, String billType, String billNumber) async {
    print("In getBillActions");
    billType = billType.toLowerCase(); //billType must be lowercase
    final url ='$baseUrl/bill/$congress/$billType/$billNumber/actions?api_key=$apiKey&format=json';
    print("getBillActions URL: $url");
    final response = await http.get(Uri.parse(url));
    //else if code == 404, put summary as null/default values
    if (response.statusCode == 200) {
      print("========= getbillACtions: status code == 200");
      final data = json.decode(response.body);

      // Check if summaries exist
      if (data['actions'] == null) {
        print("getBillActions empty for billNumber $billNumber");
        return [];
      }

      if (data['actions'] is List) {
        final actionsData = data['actions'] as List;
        return actionsData
            .map((actions) => BillActions.fromJson(actions))
            .toList();
      } else {
        throw Exception("Unexpected format: 'actions' is not a list.");
      }
    } else {
      print('Bill $billNumber has no actions: ${response.statusCode}');
      Future<List<BillActions>> emptyList = Future.value(<BillActions>[]);
      return emptyList;
    }
  }

  // Fetch summaries for a specific bill
  Future<List<BillSummary>> getBillSummaries(
      int congress, String billType, String billNumber) async {
    billType = billType.toLowerCase(); //billType must be lowercase
    print(
        "In getBillSummaries: congress: $congress, type: $billType, bill number: $billNumber");
    final url =
        '$baseUrl/bill/$congress/$billType/$billNumber/summaries?api_key=$apiKey&format=json';
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
        return summariesData
            .map((summary) => BillSummary.fromJson(summary))
            .toList();
      } else {
        throw Exception("Unexpected format: 'summaries' is not a list.");
      }
    } else {
      print('Bill $billNumber has no summaries: ${response.statusCode}');
      Future<List<BillSummary>> emptyList = Future.value(<BillSummary>[]);
      return emptyList;
    }
  }

  Future<BillData> getBillFiles(
    int congress,
    String billType,
    String billNumber,
    
  ) async{
    String url = '$baseUrl/bill/$congress/$billType/$billNumber/text?api_key=$apiKey&format=json';

    final response = await http.get(Uri.parse(url));
    //else if code == 404, put summary as null/default values
 
    if (response.statusCode == 200) {
      return BillData.fromJson(response.body);
    } else {
      throw BillData();
    }
  }
  // Search bills to find bills of interest
  //originall of
  Future<List<Bill>> searchBills({
    int? congress,
    String? billType,
    int offset = 0,
    int limit = 50,
  }) async {
    String url =
        '$baseUrl/bill?api_key=$apiKey&offset=$offset&limit=$limit&format=json';
    //&fromDateTime=2022-01-01T12:30:30Z&toDateTime=2024-01-01T12:30:30Z
    print("searchBills URL: $url");
    if (congress != null) url += '&congress=$congress';
    if (billType != null) url += '&billType=$billType';
    print("==== awaiting searchBills.response ====");
    try{
      final response = await http.get(Uri.parse(url));
      print("==== Gotten response =====");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bills = data['bills'] as List;
        return bills.map((bill) => Bill.fromJson(bill)).toList();
      } else {
        print("ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt");
        throw Exception('Failed to search bills: ${response.statusCode}');
      }
    }catch(e){
      print("searchBills catch:");
      return [];
    }

  }
}



//---- END RESULTS OF https://api.congress.gov/#/bill/bill_list_all

