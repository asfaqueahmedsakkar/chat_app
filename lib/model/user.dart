import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class User {
  String name, image, email, phone, uid;

  User.fromDocument({@required dynamic data}) {
    name = data["name"];
    image = data["picture"];
    email = data["email"];
    phone = data["number"];
    uid = data["uid"];
  }

  User.fromFirebaseUser({@required FirebaseUser user}) {
    uid = user.uid;
    email = user.email;
    image = user.photoUrl;
    name = user.displayName;
    phone = user.phoneNumber;
  }

  dynamic toJson() {
    return {
      "uid": uid,
      "email": email,
      "picture": image,
      "name": name,
      "number": phone,
    };
  }
}
