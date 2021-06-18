import 'package:flutter/material.dart';

class Kullanici {
  Kullanici({
    @required this.adSoyad,
    @required this.kullaniciId,
    @required this.profilFotoUrl,
  });

  String adSoyad;
  String kullaniciId;
  String profilFotoUrl;

  factory Kullanici.fromMap(Map<String, dynamic> json) => Kullanici(
        adSoyad: json["adSoyad"],
        kullaniciId: json["kullaniciId"],
        profilFotoUrl: json["profilFotoUrl"],
      );

  Map<String, dynamic> toMap() => {
        "adSoyad": adSoyad,
        "kullaniciId": kullaniciId,
        "profilFotoUrl": profilFotoUrl,
      };
}
