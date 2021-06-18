import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/pages/loginUser.dart';
import 'package:flutterfirebase/services/ilan_model.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String title = "Anasayfa";
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Anasayfa"),
            actions: <Widget>[
              RaisedButton.icon(
                label: Text(
                  "Çıkış Yap",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
                icon: Icon(
                  Icons.exit_to_app,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: _userCikis,
              )
            ],
          ),
          body: Container(child: Text("Deneme"))),
    );
  }

  void _currentUser() {
    final user = _auth.currentUser;

    /// final User user = _auth.currentUser; null safety olmadan
    setState(() {
      _email = user.email;
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _userCikis() async {
    await _auth
        .signOut()
        .then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginUser(title)),
            (Route<dynamic> route) => false))
        .catchError((onError) {
      Alert(
          type: AlertType.warning,
          context: context,
          title: "ÇIKIŞ YAPILAMADI!",
          buttons: [
            DialogButton(
              child: Text(
                "KAPAT",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ]).show();
    });
  }
}
