import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:tracklaw/landingPage/openingPage.dart';
import 'package:tracklaw/billPage/legistlationPage.dart';
import 'package:tracklaw/models/congress.dart';
import '../apis/firebaseAPI.dart';
import 'feedPage.dart';

class LikesPage extends StatefulWidget{

  final int i;

  LikesPage({Key? key, required this.i}) : super(key: key);
  @override
  State<LikesPage> createState() => _LikesPageState();

}

class _LikesPageState extends State<LikesPage>{
  //get a bills and actions variable to use FeedScroll

  @override
  void initState(){
    super.initState();
  }
  
  @override
  void dispose(){
    super.dispose();
  }
  Future<List<Bill>> fetchLikedData() async{
    //construct bills cards from 
    return [];
  }
  @override
  Widget build(BuildContext context){
    final user = context.watch<UserNotifier>().user;
   
  }
}

