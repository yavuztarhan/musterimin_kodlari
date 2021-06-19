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

  Future<Kullanici> kullaniciGetir(String kullaniciId) async {
    DocumentSnapshot _query = await FirebaseFirestore.instance
        .collection("Users")
        .doc(kullaniciId)
        .get();
    Kullanici kullanici = Kullanici.fromMap(_query.data());
    return kullanici;
  }

  Future<Kullanici> shobetKullaniciGetir(
      String kullaniciId, List<dynamic> members) async {
    String targetId;
    members.forEach((element) {
      if (kullaniciId != element) {
        print("element:" + element);
        targetId = element;
      }
    });
    print("Aktif ID: " + kullaniciId);
    print("TARGET ID: " + targetId);
    DocumentSnapshot _query = await FirebaseFirestore.instance
        .collection("Users")
        .doc(targetId)
        .get();
    Kullanici kullanici = Kullanici.fromMap(_query.data());
    return kullanici;
  }

  Future<Conversations> startConversation(
      String aktifKullaniciId, Kullanici profil) async {
    DocumentReference ref = await _firestore.collection("conversations").add({
      "displayMessage": "",
      "members": [aktifKullaniciId, profil.kullaniciId],
      "kullaniciAdi": profil.adSoyad,
      "profilFoto": profil.profilFotoUrl,
    });
    return Conversations(
        id: ref.id,
        displayMessage: "",
        name: profil.adSoyad,
        profileImage: profil.profilFotoUrl);
  }

  Future<bool> konusmaVarMi(String aktifKullaniciId, Kullanici profil) async {
    QuerySnapshot snapshot = await _firestore.collection("conversations").where(
        "members",
        isEqualTo: [aktifKullaniciId, profil.kullaniciId]).get();
    print(snapshot.docs);
    if (snapshot.docs.length == 0) {
      print("girdi");
      return false;
    }
    print("girmedi");
    return true;
  }

  Future<Conversations> konusmaVarMiGetir(
      String aktifKullaniciId, Kullanici profil) async {
    QuerySnapshot snapshot = await _firestore.collection("conversations").where(
        "members",
        isEqualTo: [aktifKullaniciId, profil.kullaniciId]).get();
    List<Conversations> aaa =
        snapshot.docs.map((doc) => Conversations.fromSnapshot(doc)).toList();
    return aaa[0];
  }
}
