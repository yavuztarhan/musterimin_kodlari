import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/services/sehir_ve_ilce.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class YaziEkrani extends StatefulWidget {
  @override
  _YaziEkraniState createState() => _YaziEkraniState();
}

class _YaziEkraniState extends State<YaziEkrani> {
  // String secilenIlce = "Şehir Seçiniz";
  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Sehir secilenSehir;
  Ilce secilenIlce;
  var gelenYaziBasligi = "";
  var gelenYaziIcerigi = "";
  String secilenTarih;
  String secilenSaat;
  String secileIlanTipi;
  FirebaseAuth auth = FirebaseAuth.instance;

  yaziEkle() async {
    if (secilenIlce != null &&
        secileIlanTipi != null &&
        secilenTarih != null &&
        secilenSaat != null) {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        FirebaseFirestore.instance.collection("Yazilar").add({
          'kullaniciId': auth.currentUser.uid,
          "sehir": secilenSehir.sehirAdi,
          'baslik': t1.text,
          'icerik': t2.text,
          "ilce": secilenIlce.ilceAdi,
          "tarih": secilenTarih,
          "saat": secilenSaat,
          "ilanTipi": secileIlanTipi,
          "kullaniciAdi": auth.currentUser.displayName,
        }).whenComplete(() {
          SnackBar snackBar = SnackBar(
            backgroundColor: Colors.green,
            content: Text("İlan Başarıyla Eklendi."),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            t1.text = "";
            t2.text = "";
          });
        });
      }
    } else
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lütfen tüm alanları doldurunuz."),
        backgroundColor: Colors.red,
      ));
  }

  yaziGuncelle() {
    FirebaseFirestore.instance
        .collection("Yazilar")
        .doc(t1.text)
        .update({'baslik': t1.text, 'icerik': t2.text}).whenComplete(
            () => print("Yazı güncellendi"));
  }

  yaziSil() {
    FirebaseFirestore.instance.collection("Yazilar").doc(t1.text).delete();
  }

  yaziGetir() {
    FirebaseFirestore.instance
        .collection("Yazilar")
        .doc(t1.text)
        .get()
        .then((gelenVeri) {
      setState(() {
        gelenYaziBasligi = gelenVeri.data()['baslik'];
        gelenYaziIcerigi = gelenVeri.data()['icerik'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Veri Ekle")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (s) {
                        if (s.isEmpty) {
                          return "İlan başlığı boş bırakılamaz";
                        } else
                          return null;
                      },
                      onSaved: (s) {
                        gelenYaziBasligi = s;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.add_chart),
                        hintText: "İlan Başlığı",
                        labelText: "İlan Başlığı",
                        border: OutlineInputBorder(),
                      ),
                      controller: t1,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      validator: (s) {
                        if (s.isEmpty) {
                          return "İlan içeriği boş bırakılamaz";
                        } else
                          return null;
                      },
                      onSaved: (s) {
                        gelenYaziIcerigi = s;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.align_horizontal_left),
                        hintText: "İlan Detayları",
                        labelText: "İlan Detayları",
                        border: OutlineInputBorder(),
                      ),
                      controller: t2,
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black38)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: Icon(Icons.location_city),
                          ),
                          SizedBox(
                            width: 50,
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
                              hint: secilenSehir == null
                                  ? Text("Şehir seçiniz")
                                  : Text(
                                      secilenSehir.sehirAdi,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                              onChanged: (gelenSehir) {
                                setState(() {
                                  secilenSehir = gelenSehir;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    secilenSehir != null
                        ? Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.black38)),
                            child: Center(
                              child: DropdownButton<Ilce>(
                                  underline: Container(
                                    height: 0,
                                  ),
                                  onChanged: (gelenIlceSecimi) {
                                    setState(() {
                                      secilenIlce = gelenIlceSecimi;
                                    });
                                  },
                                  hint: secilenIlce == null
                                      ? Text("İlçe seçiniz")
                                      : Text(
                                          secilenIlce.ilceAdi,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                  items: SehirveIlce()
                                      .ilceListesiniOlustur(
                                          "${secilenSehir.sehirPlakaKodu}")
                                      .map(
                                    (oankiIlce) {
                                      return DropdownMenuItem<Ilce>(
                                        child: Text(oankiIlce.ilceAdi),
                                        value: oankiIlce,
                                      );
                                    },
                                  ).toList()),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        DatePicker.showDatePicker(context,
                            locale: LocaleType.tr, onConfirm: (gelenTarih) {
                          setState(() {
                            secilenTarih =
                                gelenTarih.toString().substring(0, 11);
                          });
                        });
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black38)),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(Icons.date_range),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4.7,
                            ),
                            Center(
                              child: secilenTarih != null
                                  ? Text(
                                      "Tarih : " + secilenTarih,
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Text(
                                      "Tarih seçiniz",
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        DatePicker.showTimePicker(context,
                            locale: LocaleType.tr,
                            showSecondsColumn: false, onConfirm: (gelenSaat) {
                          setState(() {
                            secilenSaat =
                                gelenSaat.toString().substring(11, 16);
                          });
                        });
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black38)),
                        child: Row(
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(Icons.lock_clock)),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4.7,
                            ),
                            Center(
                              child: secilenSaat != null
                                  ? Text(
                                      "Saat : $secilenSaat",
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Text(
                                      "Saat seçiniz",
                                      style: TextStyle(fontSize: 18),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black38)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(Icons.event),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          Center(
                            child: DropdownButton<String>(
                              underline: Container(
                                height: 0,
                              ),
                              iconSize: 30,
                              items: [
                                "Planım var, arkadaş arıyorum.",
                                "Planı olan birisini arıyorum"
                              ].map((oankiIlanTipi) {
                                return DropdownMenuItem<String>(
                                  child: Text(oankiIlanTipi),
                                  value: oankiIlanTipi,
                                );
                              }).toList(),
                              hint: secileIlanTipi == null
                                  ? Text("İlan tipini seçiniz")
                                  : Text(
                                      secileIlanTipi,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                              onChanged: (gelenIlanTipi) {
                                setState(() {
                                  secileIlanTipi = gelenIlanTipi;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () => yaziEkle(),
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black38)),
                        child: Center(
                            child: Text(
                          "İlan Oluştur",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
