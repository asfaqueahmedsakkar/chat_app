import 'package:caht_app/bloc/base_bloc.dart';
import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatListBloc extends BaseBloc {
  Stream<QuerySnapshot> stream;

  createStream(User user) {
    stream = Firestore.instance
        .collection("messages")
        .where("contributors", arrayContains: user.uid).orderBy("time")
        .snapshots();
  }

  @override
  dispose() {}
}
