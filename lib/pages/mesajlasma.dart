import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/models/conversations.dart';
import 'package:flutterfirebase/pages/sohbetDetay.dart';
import 'package:flutterfirebase/services/firestore_servisleri.dart';
import 'package:flutterfirebase/services/kullanici_model.dart';
import 'package:flutterfirebase/viewmodel/chats_model.dart';
import 'package:provider/provider.dart';

class Mesajlasma extends StatefulWidget {
  @override
  _MesajlasmaState createState() => _MesajlasmaState();
}

class _MesajlasmaState extends State<Mesajlasma> {
  String aktifKullaniciId;
  final FirestoreServisleri fireStoreServisi = FirestoreServisleri();
  Kullanici kullanici;
  @override
  void initState() {
    super.initState();
    aktifKullaniciId = FirebaseAuth.instance.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    ChatsModel model = ChatsModel();
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        title: Text(
          "Mesajlar",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       showSearch(
          //           context: context,
          //           delegate: ContactSearchDelegate(aktifKullaniciId));
          //     },
          //     icon: Icon(Icons.search)),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: ChangeNotifierProvider(
          create: (BuildContext context) => model,
          child: StreamBuilder<List<Conversations>>(
            stream: model.conversations(aktifKullaniciId),
            builder: (BuildContext context,
                AsyncSnapshot<List<Conversations>> snapshot) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(height: 0);
              }

              return sohbetCard(snapshot);
            },
          ),
        ),
      ),
    );
  }

  sohbetCard(AsyncSnapshot<List<Conversations>> snapshot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            Conversations sohbet = snapshot.data[index];
            print(sohbet.name);
            print(sohbet.members);

            return FutureBuilder<Object>(
                future: FirestoreServisleri()
                    .shobetKullaniciGetir(aktifKullaniciId, sohbet.members),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  Kullanici kullanici = snapshot.data;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 27,
                          backgroundImage:
                              NetworkImage(kullanici.profilFotoUrl),
                        ),
                        title: Text(kullanici.adSoyad),
                        subtitle: Text(sohbet.displayMessage),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SohbetDetay(
                                      sohbet: sohbet,
                                      userId: aktifKullaniciId,
                                      conersationId: sohbet.id)));
                        },
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
