import 'package:cached_network_image/cached_network_image.dart';
import 'package:caht_app/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightBlack,
      appBar: AppBar(
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Message",
              style: GoogleFonts.raleway(
                fontSize: 24.0,
              ),
            ),
          ),
          Container(
            color: AppColor.transparentWhite,
            child: Center(
              child: TextFormField(
                style: GoogleFonts.raleway(),
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top:14.0,bottom: 12.0,left: 12.0,right: 12.0),
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
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection("user")
                  .getDocuments()
                  .asStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapShot) {
                if (snapShot.hasError)
                  return Center(child: new Text('There is an error'));
                if (snapShot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                return ListView.separated(
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
                    return Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      child: Row(
                        children: <Widget>[
                          ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl: documentSnapshot.data["picture"],
                              height: 60.0,
                              width: 60.0,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
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
                                      child: Text(
                                        documentSnapshot.data["name"],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.raleway(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                     Text(
                                      "1 hr ago",
                                      style: GoogleFonts.raleway(
                                        fontWeight: FontWeight.w200,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "This is a test message from asfaque to test tha ability of the application",
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
                    );
                  },
                  itemCount: snapShot.data.documents.length,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
