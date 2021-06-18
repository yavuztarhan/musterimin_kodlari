import 'dart:convert';

Ilan IlanFromJson(String str) => Ilan.fromJson(json.decode(str));

String IlanToJson(Ilan data) => json.encode(data.toJson());

class Ilan {
  Ilan(
      {this.kullaniciId,
      this.sehir,
      this.baslik,
      this.icerik,
      this.ilce,
      this.tarih,
      this.saat,
      this.ilanTipi,
      this.kullaniciAdi});

  final String kullaniciId;
  String sehir;
  String baslik;
  String icerik;
  String ilce;
  String tarih;
  String saat;
  String ilanTipi;
  String kullaniciAdi;

  factory Ilan.fromJson(Map<String, dynamic> json) => Ilan(
        kullaniciId: json["kullaniciId"],
        sehir: json["sehir"],
        baslik: json["baslik"],
        icerik: json["icerik"],
        ilce: json["ilce"],
        tarih: json["tarih"],
        saat: json["saat"],
        ilanTipi: json["ilanTipi"],
        kullaniciAdi: json["kullaniciAdi"],
      );

  Map<String, dynamic> toJson() => {
        "kullaniciId": kullaniciId,
        "sehir": sehir,
        "baslik": baslik,
        "icerik": icerik,
        "ilce": ilce,
        "tarih": tarih,
        "saat": saat,
        "ilanTipi": ilanTipi,
        "kullaniciAdi": kullaniciAdi,
      };
}
