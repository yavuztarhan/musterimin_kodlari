import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/pages/homePage.dart';
import 'package:flutterfirebase/pages/kendiVerilerim.dart';
import 'package:flutterfirebase/pages/listelePage.dart';
import 'package:flutterfirebase/pages/mesajlasma.dart';
import 'package:flutterfirebase/pages/vericek.dart';
import 'package:flutterfirebase/pages/veriekle.dart';
import 'package:flutterfirebase/profilPage.dart';
import 'package:flutterfirebase/profilTasarimi.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreen createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  int selectedIndex = 0;
  final screen = [
    TumYazilar(),
    YaziEkrani(),
    ProfilPage(
      profilGosterilecekId: FirebaseAuth.instance.currentUser.uid,
    ),
    Mesajlasma(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: selectedIndex,
        items: [
          Icon(
            Icons.home,
            size: 30,
          ),
          Icon(
            Icons.add,
            size: 30,
          ),
          Icon(
            Icons.person,
            size: 30,
          ),
          Icon(
            Icons.message,
            size: 30,
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        animationCurve: Curves.easeInBack,
        animationDuration: const Duration(milliseconds: 300),
      ),
      body: screen[selectedIndex],
    );
  }
}
