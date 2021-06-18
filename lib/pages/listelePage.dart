import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Listele extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Listele> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference moviesRef = _firestore.collection('Yazilar');
    var babaRef = moviesRef.doc('baslik');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Firestore CRUD İşlemleri')),
      body: Center(
        child: Container(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                /// Neyi dinlediğimiz bilgisi, hangi streami
                stream: moviesRef.snapshots(),

                /// Streamden her yeni veri aktığında, aşağıdaki metodu çalıştır
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return AlertDialog(
                        title: Text('Bir Hata Oluştu, Tekrar Deneynizi'));
                  } else {
                    if (asyncSnapshot.hasData) {
                      List<DocumentSnapshot> listOfDocumentSnap =
                          asyncSnapshot.data.docs;
                      return Flexible(
                        child: ListView.builder(
                          padding: EdgeInsets.all(15),
                          itemCount: listOfDocumentSnap.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(
                                    '${listOfDocumentSnap[index].data()['baslik']}',
                                    style: TextStyle(fontSize: 24)),
                                subtitle: Text(
                                    '${listOfDocumentSnap[index].data()['icerik']}',
                                    style: TextStyle(fontSize: 16)),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await listOfDocumentSnap[index]
                                        .reference
                                        .delete();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
