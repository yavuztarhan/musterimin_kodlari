import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/pages/ilan_arama_sayfasi.dart';
import 'package:flutterfirebase/pages/ilan_filreleme_sayfasi.dart';
import 'package:flutterfirebase/profilPage.dart';
import 'package:flutterfirebase/services/ilan_model.dart';
import 'package:flutterfirebase/services/sehir_ve_ilce.dart';

class TumYazilar extends StatefulWidget {
  @override
  _TumYazilarState createState() => _TumYazilarState();
}

class _TumYazilarState extends State<TumYazilar> {
  List<Ilan> _tumIlanlar = [];
  bool _yukleniyor = false;
  bool _hasMore = true;
  int _getirilecekIlanSayisi = 5;
  Ilan _enSonGetirilenIlan;
  ScrollController _scrollController = ScrollController();
  Sehir filtrelenecekSehir;
  Ilan enSonSehreGoreFiltrelenenIlan;
  TextEditingController _textEditingController;

  ilanlariGetir(Ilan enSonGetirilenIlan) async {
    if (!_hasMore) {
      return;
    }
    if (_yukleniyor) {
      return;
    }
    setState(() {
      _yukleniyor = true;
    });
    QuerySnapshot _querysnapshot;
    if (enSonGetirilenIlan == null) {
      _querysnapshot = await FirebaseFirestore.instance
          .collection("Yazilar")
          .orderBy("baslik")
          .limit(_getirilecekIlanSayisi)
          .get();
    } else {
      _querysnapshot = await FirebaseFirestore.instance
          .collection("Yazilar")
          .orderBy("baslik")
          .startAfter([enSonGetirilenIlan.baslik])
          .limit(_getirilecekIlanSayisi)
          .get();
    }
    if (_querysnapshot.docs.length < _getirilecekIlanSayisi) {
      _hasMore = false;
    }
    for (DocumentSnapshot snapshot in _querysnapshot.docs) {
      Ilan tekIlan = Ilan.fromJson(snapshot.data());
      _tumIlanlar.add(tekIlan);

      print(tekIlan.baslik);
    }
    _enSonGetirilenIlan = _tumIlanlar.last;
    print("en sonki ılan :${_tumIlanlar.last.baslik}");
    setState(() {
      _yukleniyor = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController = TextEditingController();
    ilanlariGetir(_enSonGetirilenIlan);
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        ilanlariGetir(_enSonGetirilenIlan);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  color: Colors.red,
                  onPressed: () {
                    if (_textEditingController.text != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => IlanAramaSayfasi(
                                    filtrelenecekBaslik:
                                        _textEditingController.text,
                                  )));
                    }
                  },
                  icon: Icon(Icons.arrow_forward_ios)),
            )
          ],
          toolbarHeight: 90,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _textEditingController,
              onFieldSubmitted: (yazilanBaslik) {
                if (_textEditingController.text != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => IlanAramaSayfasi(
                                filtrelenecekBaslik: yazilanBaslik,
                              )));
                }
              },
              decoration: InputDecoration(
                  icon: Icon(Icons.search), hintText: "İlanlarda arayın"),
            ),
          ),
        ),
        body: Column(
          children: [
            InkWell(
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        title: Text(
                          "Şehirlere göre filtrele",
                          textAlign: TextAlign.center,
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "İlanlarını görüntülemek istediğiniz şehri seçin:",
                              ),
                              Center(
                                child: DropdownButton<Sehir>(
                                  underline: Container(
                                    height: 0,
                                  ),
                                  iconSize: 30,
                                  items: SehirveIlce()
                                      .plakaliSehirListesi
                                      .map((oankiSehir) {
                                    return DropdownMenuItem<Sehir>(
                                      child: Text(oankiSehir.sehirAdi),
                                      value: oankiSehir,
                                    );
                                  }).toList(),
                                  hint: filtrelenecekSehir == null
                                      ? Text("Şehir seçiniz")
                                      : Text(
                                          filtrelenecekSehir.sehirAdi,
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                  onChanged: (gelenSehir) {
                                    setState(() {
                                      filtrelenecekSehir = gelenSehir;
                                    });
                                  },
                                ),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    if (filtrelenecekSehir != null) {
                                      return Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  IlanFiltrelemeSayfasi(
                                                    filtrelenecekSehir:
                                                        filtrelenecekSehir,
                                                  )));
                                    } else
                                      return null;
                                  },
                                  child: Text("Filtrele"))
                            ],
                          ),
                        ),
                      );
                    });
                  }),
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5)),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.filter_alt),
                    Text(
                      "İlanları filtreleyin",
                      style: TextStyle(fontSize: 17),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: _tumIlanlar.length == 0
                  ? Text("Henüz bir ilan yok")
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _tumIlanlar.length,
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
                                                              _tumIlanlar[index]
                                                                  .kullaniciId,
                                                        )));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              _tumIlanlar[index].kullaniciAdi,
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          )),
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
                                                "${_tumIlanlar[index].tarih} \n${_tumIlanlar[index].saat}")
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
                                                " ${_tumIlanlar[index].baslik}"),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                "${_tumIlanlar[index].ilanTipi}"),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                "${_tumIlanlar[index].icerik}"),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(Icons.location_on),
                                          Text(
                                              "${_tumIlanlar[index].sehir}\n${_tumIlanlar[index].ilce}")
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
            ),
            _yukleniyor
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(),
          ],
        ));
  }
}
