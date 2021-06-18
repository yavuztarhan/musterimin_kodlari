import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/profilPage.dart';
import 'package:flutterfirebase/services/ilan_model.dart';
import 'package:flutterfirebase/services/sehir_ve_ilce.dart';

class IlanAramaSayfasi extends StatefulWidget {
  String filtrelenecekBaslik;
  IlanAramaSayfasi({this.filtrelenecekBaslik});

  @override
  _IlanAramaSayfasiState createState() => _IlanAramaSayfasiState();
}

class _IlanAramaSayfasiState extends State<IlanAramaSayfasi> {
  List<Ilan> filtrelenenTumIlanlarListesi = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("İlan Ara"),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (filtrelenenTumIlanlarListesi.length == 0) {
                return Center(
                  child: Text("Bu kelimeyle ilgili bir ilan yok"),
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
                                    InkWell(
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
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
          future: kelimeyeGoreFiltrele(widget.filtrelenecekBaslik),
        ));
  }

  Future<List<Ilan>> kelimeyeGoreFiltrele(String filtrelenecekBaslik) async {
    QuerySnapshot _snapshot = await FirebaseFirestore.instance
        .collection("Yazilar")
        .where("baslik", isLessThanOrEqualTo: widget.filtrelenecekBaslik)
        .get();
    for (QueryDocumentSnapshot snap in _snapshot.docs) {
      Ilan tekIlan = Ilan.fromJson(snap.data());
      filtrelenenTumIlanlarListesi.add(tekIlan);
    }
    return filtrelenenTumIlanlarListesi;
  }
}
