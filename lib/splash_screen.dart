import 'package:caht_app/app_color.dart';
import 'package:caht_app/bloc/app_bloc.dart';
import 'package:caht_app/bloc/bloc_provider.dart';
import 'package:caht_app/bloc/chat_list_bloc.dart';
import 'package:caht_app/message_screen.dart';
import 'package:caht_app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      FirebaseAuth.instance.currentUser().then((fUser) {
        if (fUser != null) {
          User user = User.fromFirebaseUser(user: fUser);
          BlocProvider.of<AppBloc>(context).user = user;
          BlocProvider.of<ChatListBloc>(context).createStream(user);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MessageScreen()));
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constrains) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                size: Size(constrains.maxWidth, constrains.maxHeight),
                painter: SplashScreenPaint(),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: RawMaterialButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        _handleSignIn().then((user) async {
                          await Firestore.instance
                              .collection("user")
                              .document(user.uid)
                              .setData({
                            "uid": user.uid,
                            "email": user.email,
                            "picture": user.photoUrl,
                            "name": user.displayName,
                            "number": user.phoneNumber,
                          });
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MessageScreen()));
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              "images/g_icon.png",
                              width: 36.0,
                              height: 36.0,
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            Text(
                              "Sign in With Google",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                color: AppColor.lightBlack,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    "OURTIME",
                    style: TextStyle(
                      color: AppColor.transparentWhite,
                      fontSize: 120.0,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    return user;
  }
}

class SplashScreenPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0.0)
        ..lineTo(0.0, size.height * 0.8)
        ..lineTo(0.0, size.height)
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()..color = AppColor.lightBlack,
    );
    canvas.drawPath(
      Path()
        ..lineTo(size.width + 2, 0.0)
        ..lineTo(0.0, size.height * 0.8 + 2)
        ..close(),
      Paint()..color = AppColor.deepBlack,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
