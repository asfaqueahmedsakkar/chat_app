import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatModel {
  User sender, receiver;
  String message, messageId;
  Timestamp messageTime;
  ChatModel replyOf;

  ChatModel.fromData({@required data}) {
    receiver = User.fromDocument(data: data["receiver"]);
    sender = User.fromDocument(data: data["sender"]);
    message = data["message"];
    messageTime = data["time"];
    messageId = data["message_id"];
    replyOf = data["replyof"] != null
        ? ChatModel.fromData(data: data["replyof"])
        : null;
  }

  ChatModel.newMessage({
    @required this.sender,
    @required this.receiver,
    @required this.message,
    @required this.messageId,
  });

  Map<String, dynamic> toJson() {
    return {
      "receiver": receiver.toJson(),
      "sender": sender.toJson(),
      "message": message,
      "time": FieldValue.serverTimestamp(),
      "message_id": messageId,
    };
  }
}
