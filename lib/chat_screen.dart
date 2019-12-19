import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:caht_app/app_color.dart';
import 'package:caht_app/bloc/app_bloc.dart';
import 'package:caht_app/bloc/bloc_provider.dart';
import 'package:caht_app/bloc/chat_bloc.dart';
import 'package:caht_app/model/chat_model.dart';
import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({Key key, this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FocusNode focusNode;
  TextEditingController _messageController;
  bool _hasMessage = false;
  ChatBloc _chatBloc;

  @override
  void initState() {
    _chatBloc = new ChatBloc(
      sender: BlocProvider.of<AppBloc>(context).user,
      receiver: widget.user,
    );
    focusNode = new FocusNode();
    _messageController = new TextEditingController();
    _messageController.addListener(() {
      if (_messageController.text != null) {
        if (_messageController.text.length == 1) {
          setState(() {
            _hasMessage = true;
          });
        } else if (_messageController.text.length == 0) {
          setState(() {
            _hasMessage = false;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _chatBloc,
      child: Scaffold(
        backgroundColor: AppColor.deepBlack,
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: AppColor.deepBlack,
          elevation: 0.0,
          title: Row(
            children: <Widget>[
              Hero(
                tag: widget.user.uid,
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    height: 36.0,
                    width: 36.0,
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              SizedBox(
                width: 8.0,
              ),
              Hero(
                tag: widget.user.email,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.user.name,
                    style: GoogleFonts.raleway(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30.0),
          ),
          child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 16.0),
            decoration: BoxDecoration(
              color: AppColor.lightBlack,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 8.0,
                ),
                Expanded(
                  child: StreamBuilder(
                      stream: Firestore.instance
                          .collection("chat")
                          .where("message_id", isEqualTo: _chatBloc.messageId)
                          .orderBy("time", descending: true)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.data == null)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        User me = BlocProvider.of<AppBloc>(context).user;
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          reverse: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            ChatModel message = ChatModel.fromData(
                                data: snapshot.data.documents[index]);
                            return ChatBubble(
                              message: message,
                              fromMe: me.uid == message.sender.uid,
                              replyThis: () {
                                message.replyOf = null;
                                setState(() {
                                  BlocProvider.of<ChatBloc>(context).replyFor =
                                      message;
                                });
                              },
                            );
                          },
                        );
                      }),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _chatBloc.replyFor == null
                          ? SizedBox()
                          : Container(
                              margin: EdgeInsets.only(bottom: 4.0),
                              padding: EdgeInsets.all(12.0),
                              color: AppColor.deepBlack,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                            text: "Reply of ",
                                            style: TextStyle(fontSize: 12.0),
                                            children: [
                                              TextSpan(
                                                text: _chatBloc
                                                    .replyFor.sender.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 4.0,
                                        ),
                                        Text(
                                          _chatBloc.replyFor.message,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w200,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 36.0,
                                    child: GestureDetector(
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _chatBloc.replyFor = null;
                                          });
                                        }),
                                  ),
                                ],
                              ),
                            ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                              color: AppColor.deepBlack,
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              constraints: BoxConstraints(
                                maxHeight: 100.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.deepBlack,
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              child: TextField(
                                controller: _messageController,
                                focusNode: focusNode,
                                maxLines: null,
                                style: GoogleFonts.actor(fontSize: 18),
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(4.0),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          _hasMessage
                              ? Container(
                                  height: 40.0,
                                  width: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: RawMaterialButton(
                                    onPressed: () {
                                      String _message = _messageController.text;
                                      _messageController.clear();
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      _chatBloc
                                          .sendMessage(messageText: _message)
                                          .then((s) {
                                        setState(() {
                                          _chatBloc.replyFor = null;
                                        });
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Center(
                                      child: Icon(
                                        Icons.send,
                                        size: 20.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatModel message;
  final bool fromMe;
  final Function replyThis;

  const ChatBubble({
    Key key,
    this.message,
    this.fromMe,
    this.replyThis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction:
          fromMe ? DismissDirection.endToStart : DismissDirection.startToEnd,
      key: GlobalKey(),
      confirmDismiss: (direction) async {
        replyThis();
        return false;
      },
      background: Container(
        alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            right: fromMe ? 16.0 : 0.0,
            left: fromMe ? 0.0 : 16.0,
          ),
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: AppColor.deepBlack,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.reply,
            color: Colors.white,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            fromMe
                ? SizedBox()
                : ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: message.sender.image,
                      height: 24.0,
                      width: 24.0,
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
            message.replyOf == null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: bubbleWithNoReply(),
                  )
                : buildBubbleForReply(),
            !fromMe
                ? SizedBox()
                : ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: message.sender.image,
                      height: 24.0,
                      width: 24.0,
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildBubbleForReply() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: !fromMe ? 16.0 : 0.0,
            ),
            Transform(
              transform: Matrix4.identity()..rotateY(pi),
              alignment: Alignment.center,
              child: Icon(
                Icons.reply,
                size: 16.0,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 4.0,
            ),
            Text(
              "${fromMe ? "You" : message.sender.name} replyed to ${(fromMe && message.replyOf.sender.uid == message.sender.uid) || (!fromMe && message.replyOf.sender.uid == message.receiver.uid) ? "You" : message.replyOf.sender.name}",
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(
              width: fromMe ? 16.0 : 0.0,
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: AppColor.deepBlack,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: fromMe ? Radius.circular(20) : Radius.circular(0.0),
              topRight: Radius.circular(20),
              bottomRight: fromMe ? Radius.circular(0.0) : Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, top: 4.0, bottom: 2.0),
                child: Text(
                  message.replyOf.message,
                  style: GoogleFonts.actor(fontSize: 16),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: fromMe ? 16 : 0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: fromMe ? AppColor.transparentWhite : Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft:
                            fromMe ? Radius.circular(20) : Radius.circular(0.0),
                        topRight: Radius.circular(20),
                        bottomRight:
                            fromMe ? Radius.circular(0.0) : Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      message.message,
                      style: GoogleFonts.actor(fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: !fromMe ? 16 : 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget bubbleWithNoReply() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: fromMe ? AppColor.transparentWhite : Colors.red,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: fromMe ? Radius.circular(20) : Radius.circular(0.0),
          topRight: Radius.circular(20),
          bottomRight: fromMe ? Radius.circular(0.0) : Radius.circular(20),
        ),
      ),
      child: Text(
        message.message,
        style: GoogleFonts.actor(fontSize: 18),
      ),
    );
  }
}
