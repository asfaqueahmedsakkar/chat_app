import 'package:caht_app/app_color.dart';
import 'package:caht_app/bloc/app_bloc.dart';
import 'package:caht_app/bloc/bloc_provider.dart';
import 'package:caht_app/bloc/chat_list_bloc.dart';
import 'package:caht_app/message_screen.dart';
import 'package:caht_app/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ChatListBloc chatBloc;
  AppBloc appBloc;

  @override
  void initState() {
    appBloc = new AppBloc();
    chatBloc = new ChatListBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: appBloc,
      child: BlocProvider(
        bloc: chatBloc,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: MaterialColor(0xff1a1a1a, {
              50: AppColor.lightBlack.withOpacity(0.1),
              100: AppColor.lightBlack.withOpacity(0.2),
              200: AppColor.lightBlack.withOpacity(0.3),
              300: AppColor.lightBlack.withOpacity(0.4),
              400: AppColor.lightBlack.withOpacity(.5),
              500: AppColor.lightBlack.withOpacity(.6),
              600: AppColor.lightBlack.withOpacity(.7),
              700: AppColor.lightBlack.withOpacity(.8),
              800: AppColor.lightBlack.withOpacity(.9),
              900: AppColor.lightBlack.withOpacity(1),
            }),
            accentColor: Colors.white,
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                ),
          ),
          home: SplashScreen(),
        ),
      ),
    );
  }
}
