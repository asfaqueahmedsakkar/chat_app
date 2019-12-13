import 'package:cached_network_image/cached_network_image.dart';
import 'package:caht_app/app_color.dart';
import 'package:caht_app/bloc/bloc_provider.dart';
import 'package:caht_app/bloc/chat_list_bloc.dart';
import 'package:caht_app/chat_screen.dart';
import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColor.deepBlack,
        elevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Contacts",
            style: GoogleFonts.raleway(
              fontSize: 24.0,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            color: AppColor.deepBlack,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: AppColor.lightBlack,
                        borderRadius: BorderRadius.circular(4.0)),
                    child: Center(
                      child: TextFormField(
                        style: GoogleFonts.raleway(),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                                top: 14.0,
                                bottom: 12.0,
                                left: 12.0,
                                right: 12.0),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 24.0,
                              color: AppColor.transparentWhite,
                            ),
                            hintText: "Search",
                            hintStyle: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                color: AppColor.transparentWhite,
                              ),
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                color: AppColor.lightBlack,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30.0),
                ),
              ),
              child: StreamBuilder(
                stream: Firestore.instance.collection("user").snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapShot) {
                  if (snapShot.hasError)
                    return Center(child: new Text('There is an error'));
                  if (snapShot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  return ListView.separated(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(0.0),
                    separatorBuilder: (context, index) => Row(
                      children: <Widget>[
                        SizedBox(
                          width: 60.0,
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColor.transparentWhite,
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                    itemBuilder: (context, index) {
                      DocumentSnapshot documentSnapshot =
                          snapShot.data.documents[index];
                      User user =
                          User.fromDocument(data: documentSnapshot.data);

                      return RawMaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                user: user,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          child: Row(
                            children: <Widget>[
                              Hero(
                                tag: user.uid,
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                    imageUrl: user.image,
                                    height: 60.0,
                                    width: 60.0,
                                  ),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Hero(
                                            tag: user.email,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Text(
                                                user.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.raleway(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      user.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: snapShot.data.documents.length,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
