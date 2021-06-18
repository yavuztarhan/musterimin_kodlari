import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/profilPage.dart';
import 'package:flutterfirebase/services/ilan_model.dart';
import 'package:flutterfirebase/services/sehir_ve_ilce.dart';

class IlanFiltrelemeSayfasi extends StatefulWidget {
  Sehir filtrelenecekSehir;
  IlanFiltrelemeSayfasi({this.filtrelenecekSehir});

  @override
  _IlanFiltrelemeSayfasiState createState() => _IlanFiltrelemeSayfasiState();
}

class _IlanFiltrelemeSayfasiState extends State<IlanFiltrelemeSayfasi> {
  List<Ilan> filtrelenenTumIlanlarListesi = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("İlan Filtrele"),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (filtrelenenTumIlanlarListesi.length == 0) {
                return Center(
                  child: Text("Bu şehirle ilgili bir ilan yok"),
                );
              } else
                return ListView.builder(
                    itemCount: filtrelenenTumIlanlarListesi.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Card(
                          elevation: 15,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilPage(
                                                        profilGosterilecekId:
                                                            filtrelenenTumIlanlarListesi[
                                                                    index]
                                                                .kullaniciId,
                                                      )));
                                        },
                                        child: Text(
                                          filtrelenenTumIlanlarListesi[index]
                                              .kullaniciAdi,
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            size: 32,
                                          ),
                                          Text(
                                              "${filtrelenenTumIlanlarListesi[index].tarih} \n${filtrelenenTumIlanlarListesi[index].saat}")
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 200,
                                      child: Column(
                                        children: [
                                          Text(
                                              " ${filtrelenenTumIlanlarListesi[index].baslik}"),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                              "${filtrelenenTumIlanlarListesi[index].ilanTipi}"),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                              "${filtrelenenTumIlanlarListesi[index].icerik}"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.location_on),
                                        Text(
                                            "${filtrelenenTumIlanlarListesi[index].sehir}\n${filtrelenenTumIlanlarListesi[index].ilce}")
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    });
            } else
              return Center(child: CircularProgressIndicator());
          },
          future: sehreGoreFiltrele(widget.filtrelenecekSehir.sehirAdi),
        ));
  }

  Future<List<Ilan>> sehreGoreFiltrele(String sehirAdi) async {
    QuerySnapshot _snapshot = await FirebaseFirestore.instance
        .collection("Yazilar")
        .where("sehir", isEqualTo: sehirAdi)
        .get();
    for (QueryDocumentSnapshot snap in _snapshot.docs) {
      Ilan tekIlan = Ilan.fromJson(snap.data());
      filtrelenenTumIlanlarListesi.add(tekIlan);
    }
    return filtrelenenTumIlanlarListesi;
  }
}
