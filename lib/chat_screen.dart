import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:caht_app/app_color.dart';
import 'package:caht_app/bloc/app_bloc.dart';
import 'package:caht_app/bloc/bloc_provider.dart';
import 'package:caht_app/bloc/chat_bloc.dart';
import 'package:caht_app/model/chat_model.dart';
import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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

  User me;
  bool uploadingImage = false;
  double progress = 0;

  File imageFile;
  StorageUploadTask task;

  @override
  void initState() {
    _chatBloc = new ChatBloc(
      sender: BlocProvider.of<AppBloc>(context).user,
      receiver: widget.user,
    );
    me = BlocProvider.of<AppBloc>(context).user;
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
                buildChatList(),
                buildInputSection()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _chatBloc.replyFor == null ? SizedBox() : buildReplyOfMessage(),
          uploadingImage ? _imageUploadView() : SizedBox(),
          Row(
            children: <Widget>[
              buildImageInputSection(),
              buildHorizontalSeparator4(),
              buildTextMessageInputSection(),
              buildHorizontalSeparator4(),
              _hasMessage ? buildSendButton() : SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox buildHorizontalSeparator4() {
    return SizedBox(
      width: 4.0,
    );
  }

  Widget buildImageInputSection() {
    return Container(
      height: 40.0,
      width: 40.0,
      decoration: BoxDecoration(
        color: AppColor.deepBlack,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: RawMaterialButton(
        onPressed: () async {
          imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

          _uploadImage(imageFile);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Expanded buildTextMessageInputSection() {
    return Expanded(
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
    );
  }

  Container buildSendButton() {
    return Container(
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
          FocusScope.of(context).requestFocus(FocusNode());
          _chatBloc.sendMessage(messageText: _message).then((s) {
            if (_chatBloc.replyFor != null)
              setState(() {
                _chatBloc.replyFor = null;
              });
          });
        },
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Center(
          child: Icon(
            Icons.send,
            size: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Container buildReplyOfMessage() {
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      padding: EdgeInsets.all(12.0),
      color: AppColor.deepBlack,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: "Reply of ",
                    style: TextStyle(fontSize: 12.0),
                    children: [
                      TextSpan(
                        text: _chatBloc.replyFor.sender.name,
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
    );
  }

  Expanded buildChatList() {
    return Expanded(
      child: StreamBuilder(
          stream: Firestore.instance
              .collection("chat")
              .where("message_id", isEqualTo: _chatBloc.messageId)
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.data == null)
              return Center(
                child: CircularProgressIndicator(),
              );
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              reverse: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                ChatModel message =
                    ChatModel.fromData(data: snapshot.data.documents[index]);
                /*if (message.media != null) {
                            //return Container(height: 120.0,width: 120.000,);
                            return Text(message.mediaType);
                          }*/
                return ChatBubble(
                  message: message,
                  fromMe: me.uid == message.sender.uid,
                  replyThis: () {
                    message.replyOf = null;
                    setState(() {
                      BlocProvider.of<ChatBloc>(context).replyFor = message;
                    });
                  },
                );
              },
            );
          }),
    );
  }

  void _uploadImage(File imageFile) async {
    String fileName =
        "${DateTime.now().millisecondsSinceEpoch.toString()}_${me.uid}";

    if (imageFile.lengthSync() < 300 * 1025) {
      task = FirebaseStorage.instance
          .ref()
          .child("$fileName${path.extension(imageFile.path)}")
          .putData(imageFile.readAsBytesSync());
    } else {
      Uint8List list = Uint8List.fromList(
          await FlutterImageCompress.compressWithFile(imageFile.absolute.path,
              minWidth: 300, quality: 60));

      task = FirebaseStorage.instance
          .ref()
          .child("$fileName${path.extension(imageFile.path)}")
          .putData(list);
    }

    final StreamSubscription<StorageTaskEvent> streamSubscription =
        task.events.listen((event) {
      setState(() {
        uploadingImage = true;
        progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });

    await task.onComplete.then((task) {
      task.ref.getDownloadURL().then((data) async {
        await _chatBloc.sendMessage(
          media: data,
          mediaType: "image",
        );

        setState(() {
          uploadingImage = false;
        });
      });
    });
    task = null;
    imageFile=null;
    streamSubscription.cancel();
  }

  _imageUploadView() {
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      padding: EdgeInsets.all(4.0),
      color: AppColor.deepBlack,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.file(
                  imageFile,
                  height: 36.0,
                  width: 36.0,
                ),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  "Uploading image",
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
                    uploadingImage = false;
                  });
                }),
          ),
        ],
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
    return message.media == null
        ? Dismissible(
            direction: fromMe
                ? DismissDirection.endToStart
                : DismissDirection.startToEnd,
            key: GlobalKey(),
            confirmDismiss: (direction) async {
              replyThis();
              return false;
            },
            background: shareIconOnSwipe(),
            child: chatMessageView(),
          )
        : chatMessageView();
  }

  Padding chatMessageView() {
    return Padding(
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
          message.media == null
              ? message.replyOf == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: bubbleWithNoReply(),
                    )
                  : buildBubbleForReply()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 300.0,
                      maxHeight: 340.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: message.media,
                      ),
                    ),
                  ),
                ),
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
    );
  }

  Container shareIconOnSwipe() {
    return Container(
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
