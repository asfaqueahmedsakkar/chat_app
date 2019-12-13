import 'package:cached_network_image/cached_network_image.dart';
import 'package:caht_app/app_color.dart';
import 'package:caht_app/bloc/app_bloc.dart';
import 'package:caht_app/bloc/bloc_provider.dart';
import 'package:caht_app/bloc/chat_bloc.dart';
import 'package:caht_app/model/user.dart';
import 'package:flutter/material.dart';
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
                Expanded(child: SizedBox()),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
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
                          child: TextFormField(
                            controller: _messageController,
                            focusNode: focusNode,
                            maxLines: null,
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
                                  _chatBloc.sendMessage(messageText: _message);
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
