import 'package:cloud_firestore/cloud_firestore.dart';

class Conversations{
  String id;
  String name;
  String profileImage;
  String displayMessage;
  List<dynamic> members;

  Conversations({this.id, this.name, this.profileImage, this.displayMessage,this.members});

  factory Conversations.fromSnapshot(DocumentSnapshot doc){
    return Conversations(
      id: doc.id,
      name: doc["kullaniciAdi"],
      profileImage: doc["profilFoto"],
      displayMessage: doc.data()["displayMessage"],
      members: doc["members"]
    );
  }
}