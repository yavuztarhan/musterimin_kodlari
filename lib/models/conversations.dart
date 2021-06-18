import 'package:cloud_firestore/cloud_firestore.dart';

class Conversations{
  String id;
  String name;
  String profileImage;
  String displayMessage;

  Conversations({this.id, this.name, this.profileImage, this.displayMessage});

  factory Conversations.fromSnapshot(DocumentSnapshot doc){
    return Conversations(
      id: doc.id,
      name: doc["kullaniciAdi"],
      profileImage: doc["profilFoto"],
      displayMessage: doc.data()["displayMessage"]
    );
  }
}