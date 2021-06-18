import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterfirebase/pages/kendiVerilerim.dart';

class ProfilTasarimi extends StatefulWidget {
  @override
  _ProfilTasarimiState createState() => _ProfilTasarimiState();
}

class _ProfilTasarimiState extends State<ProfilTasarimi> {
  File yuklenecekDosya;
  FirebaseAuth auth = FirebaseAuth.instance;
  String indirmeBaglantisi;

  kameradanYukle() async {
    var alinanDosya = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      yuklenecekDosya = File(alinanDosya.path);
    });

    Reference referansYol = FirebaseStorage.instance
        .ref()
        .child("image1")
        .child(auth.currentUser.uid)
        .child("profilResmi.png");
    UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
    String url = await (await yuklemeGorevi).ref.getDownloadURL();
    setState(() {
      indirmeBaglantisi = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          RaisedButton(
            child: Text("Resim Yükle"),
            onPressed: kameradanYukle(),
          )
        ],
      ),
    );
  }
}
