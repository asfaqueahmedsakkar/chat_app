import 'package:caht_app/bloc/base_bloc.dart';
import 'package:caht_app/model/message.dart';
import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatBloc extends BaseBloc {
  Stream<QuerySnapshot> stream;

  User _sender, _receiver;
  String _messageId;

  ChatBloc({@required User sender, @required User receiver})
      : _sender = sender,
        _receiver = receiver {
    _messageId = _sender.uid.compareTo(_receiver.uid) > 0
        ? "${_sender.uid}_${_receiver.uid}"
        : "${_receiver.uid}_${_sender.uid}";
    stream = Firestore.instance
        .collection("chat")
        .where("message_id", isEqualTo: _messageId)
        .snapshots();
  }

  void sendMessage({@required String messageText}) async {
    Message message = Message.newMessage(
      sender: _sender,
      receiver: _receiver,
      message: messageText,
      messageId: _messageId,
    );

    await Firestore.instance
        .collection("messages")
        .document(_messageId)
        .setData(
          message.toJson()
            ..addAll({
              "contributors": [_sender.uid, _receiver.uid]
            }),
        );
    await Firestore.instance.collection("chat").add(message.toJson());
  }

  @override
  void dispose() {}
}
