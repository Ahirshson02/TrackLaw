import "package:cloud_firestore/cloud_firestore.dart";
import "package:tracklaw/models/congress.dart";

 
class PagedBills {
  final List<Bill> bills;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  PagedBills(this.bills, this.lastDoc, this.hasMore);
}

Future<PagedBills> getBillsFB(String order, DocumentSnapshot? lastDoc) async {
  var query = FirebaseFirestore.instance
      .collection("bills")
      .orderBy(order, descending: true)
      .limit(20);

  if (lastDoc != null) {
    query = query.startAfterDocument(lastDoc);
  }

  final snapshot = await query.get();

  final bills = snapshot.docs
      .map((d) => Bill.fromJson(d.data()))
      .toList();

  final newLastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : lastDoc;
  if(newLastDoc == lastDoc){
    return PagedBills(bills, newLastDoc, false);
  }
  else {
    return PagedBills(bills, newLastDoc, true);
  }
}
