
import 'dart:convert';

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
    try {
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
    } catch (e) {
      print("exception when creaing Bill in fromJson");
      print(e.toString());
    }
    return bill!;
  }
  Map<String, dynamic> toJson() {
  return {
    'congress': congress,
    'latestAction': latestAction, // Assuming LatestAction has a toJson method
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
    try {
      latestAction = LatestAction(
        actionDate: json['actionDate'],
        text: json['text'],
      );
    } catch (e) {
      print("exception in LatestAction.fromJson");
      print("Exception message: $e");
    }
   return latestAction!; 
  }
  Map<String, dynamic> toJson() {
  return {
    'actionDate': actionDate,
    'text': text,
  };
}
}

class BillActions {
  final String? actionCode;
  final String? actionDate;
  List<Committee>? committees; //not made final each bill's most recent action lacks a committee value. Last action's committee is set to the first's
  final String? text;
  final String? type;

  BillActions({
    this.actionCode,
    required this.actionDate,
    this.committees,
    required this.text,
    required this.type,
  });

  factory BillActions.fromJson(Map<String, dynamic> json) {
    try{
      // print("${json['actionCode'] ?? "a"}");
      // print("${json['actionDate'] ?? "b"}");
      // print("${json['committees'] ?? "c"}");
      // print("${json['text'] ?? "d"}");
      // print("${json['type'] ?? "e"}");
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
    
    }catch(e){
      print("ERROR IN FROMJSON: $e");
      // print("${json['actionCode'] ?? "a"}");
      // print("${json['actionDate'] ?? "b"}");
      // print("${json['committees'] ?? "c"}");
      // print("${json['text'] ?? "d"}");
      // print("${json['type'] ?? "e"}");
    }
    return BillActions(actionDate: "a", text: "a", type: "a", committees: [], actionCode: "a");
  }
  printBillAction() {
    print("action code: ${actionCode ?? "No code"}, actionDate: $actionDate");
    if (committees != null) {
      for (Committee c in committees!) {
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
  String? text;
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

class BillFormat {
  final String? type;
  final String? url;

  BillFormat({required this.type, required this.url});

  factory BillFormat.fromJson(Map<String, dynamic> json) {
    return BillFormat(
      type: json['type'] as String,
      url: json['url'] as String,
    );
  }

  @override
  String toString() => '$type: $url';
}

class BillVersion {
  final String? type;
  final DateTime? date;
  final List<BillFormat>? formats;

  BillVersion({required this.type, this.date, required this.formats});

  factory BillVersion.fromJson(Map<String, dynamic> json) {
    return BillVersion(
      type: json['type'] as String,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      formats: (json['formats'] as List<dynamic>)
          .map((format) => BillFormat.fromJson(format as Map<String, dynamic>))
          .toList(),
    );
  }

  BillFormat? getFormatByType(String formatType) {
    for (var format in formats!) {
      if (format.type == formatType) {
        return format;
      }
    }
    return null;
  }

  @override
  String toString() {
    String dateStr = date != null ? date!.toIso8601String() : 'No date';
    return '$type ($dateStr)';
  }
}
class BillData {
  final String? billNumber;
  final String? billType;
  final String? congress;
  final List<BillVersion>? textVersions;

  BillData({
     this.billNumber,
     this.billType,
     this.congress,
     this.textVersions,
  });

  factory BillData.fromJson(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final request = json['request'] as Map<String, dynamic>;
    
    return BillData(
      billNumber: request['billNumber'] as String,
      billType: request['billType'] as String,
      congress: request['congress'] as String,
      textVersions: (json['textVersions'] as List<dynamic>)
          .map((version) => BillVersion.fromJson(version as Map<String, dynamic>))
          .toList(),
    );
  }

  BillVersion? getLatestVersion() {
    // Filter versions with dates
    List<BillVersion>? datedVersions = [];
    try{
    datedVersions = textVersions!.where((version) => version.date != null).toList();
    if (datedVersions.isEmpty) {
      print("getlatestVersion: datedVersions is empty, returning type == empty");
      return BillVersion(type: "empty", formats: []);
    }
    datedVersions.sort((a, b) => b.date!.compareTo(a.date!)); 
    }catch(e){
      print("getlatestVersion threw exceptin: $e");
      return BillVersion(type: "empty", formats: []);
    }
    return datedVersions.first;
  }

  BillFormat? getLatestPdfFormat() {
    final BillVersion? latestVersion = getLatestVersion();
    if (latestVersion == null || latestVersion.type == "empty") {
      print("in getlatestPDFformat, is null or empty");
      return BillFormat(type: "empty", url: "");
    }
    
    return latestVersion.getFormatByType('PDF');
  }

  @override
  String toString() {
    return 'Bill $billNumber ($billType) from Congress $congress';
  }
}