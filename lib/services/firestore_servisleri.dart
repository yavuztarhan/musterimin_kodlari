import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterfirebase/models/conversations.dart';
import 'package:flutterfirebase/services/kullanici_model.dart';

class FirestoreServisleri {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future kullaniciVeritabaninaKaydet(
      String profilFotoUrl, kullaniciId, adSoyad) async {
    try {
      await _firestore.collection("Users").doc(kullaniciId).set({
        "profilFotoUrl": profilFotoUrl,
        "kullaniciId": kullaniciId,
        "adSoyad": adSoyad,
      }).then((value) => print("Kullanıcı veritabanına basarıyla kaydedildi."));
    } catch (e) {
      print("Kullanıcı veritabanına eklenirken bir hata cıktı.Hata $e");
    }
  }

  Stream<List<Conversations>> getConversations(String userId) {
    var _ref = _firestore
        .collection("conversations")
        .where("members", arrayContains: userId);
    return _ref.snapshots().map((list) => list.docs
        .map((snapshot) => Conversations.fromSnapshot(snapshot))
        .toList());
  }

  Future<Conversations> startConversation(
      String aktifKullaniciId, Kullanici profil) async {
    DocumentReference ref = await _firestore.collection("conversations").add({
      "displayMessage": "",
      "members": [aktifKullaniciId, profil.kullaniciId],
      "kullaniciAdi": profil.adSoyad,
      "profilFoto": profil.profilFotoUrl,
    });
  }

  Future<bool> konusmaVarMi(String aktifKullaniciId, Kullanici profil) async {
    QuerySnapshot snapshot = await _firestore.collection("conversations").where("members",
        isEqualTo: [aktifKullaniciId, profil.kullaniciId]).get();
        print(snapshot.docs);
        if(snapshot.docs.length == 0){
          print("girdi");
  return false;
        }
        print("girmedi");
           return true;
        
  }
}
