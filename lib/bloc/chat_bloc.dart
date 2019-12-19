import 'package:caht_app/bloc/base_bloc.dart';
import 'package:caht_app/model/chat_model.dart';
import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatBloc extends BaseBloc {
  User _sender, _receiver;
  String messageId;

  ChatModel replyFor;

  ChatBloc({@required User sender, @required User receiver})
      : _sender = sender,
        _receiver = receiver {
    messageId = _sender.uid.compareTo(_receiver.uid) > 0
        ? "${_sender.uid}_${_receiver.uid}"
        : "${_receiver.uid}_${_sender.uid}";
  }

  Future sendMessage({@required String messageText}) async {
    ChatModel message = ChatModel.newMessage(
      sender: _sender,
      receiver: _receiver,
      message: messageText,
      messageId: messageId,
    );

    await Firestore.instance.collection("messages").document(messageId).setData(
          message.toJson()
            ..addAll({
              "contributors": [_sender.uid, _receiver.uid]
            }),
        );
    await Firestore.instance.collection("chat").add(
          message.toJson()..putIfAbsent("replyof", () => replyFor.toJson()),
        );
  }

  @override
  void dispose() {}
}
