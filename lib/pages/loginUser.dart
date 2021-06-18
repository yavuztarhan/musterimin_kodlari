import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/main_screen.dart';
import 'package:flutterfirebase/pages/createUser.dart';
import 'package:flutterfirebase/pages/homePage.dart';
import 'package:flutterfirebase/services/firestore_servisleri.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:the_validator/the_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginUser extends StatefulWidget {
  final String title;
  LoginUser(this.title);

  @override
  _LoginUserState createState() => _LoginUserState();
}

final String title = "Bana Katıl";

class _LoginUserState extends State<LoginUser> {
  var formKeyHatirla = GlobalKey<FormState>();
  var formKey = GlobalKey<FormState>();
  var formKeyPhone = GlobalKey<FormState>();
  var formKeySmsCode = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  String _email;
  String _sifre;
  String _email2;
  String _hataMesaji;
  bool _isLoading = false;
  String _phone;
  String _smsCode;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text("Giriş | ${widget.title} ")),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        onSaved: (x) {
                          setState(() {
                            _email = x;
                          });
                        },
                        autofocus: true,
                        validator: (x) {
                          if (x.isEmpty) {
                            return "Doldurulması Zorunludur!";
                          } else {
                            if (EmailValidator.validate(x) != true) {
                              return "Geçerli Bir Email Adresi Giriniz!";
                            } else {
                              return null;
                            }
                          }
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            errorStyle: TextStyle(fontSize: 18),
                            labelText: "Email",
                            labelStyle: TextStyle(fontSize: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.purple))),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        onSaved: (x) {
                          setState(() {
                            _sifre = x;
                          });
                        },
                        obscureText: true,
                        validator: FieldValidator.password(
                            minLength: 8,
                            shouldContainNumber: true,
                            shouldContainCapitalLetter: true,
                            shouldContainSpecialChars: true,
                            errorMessage:
                                "Minimum 8 Karakter uzunluğunda Olmalıdır!",
                            onNumberNotPresent: () {
                              return "Rakam İçermelidir!";
                            },
                            onSpecialCharsNotPresent: () {
                              return "Özel Karakter İçermelidir!";
                            },
                            onCapitalLetterNotPresent: () {
                              return "Büyük Harf İçermelidir!";
                            }),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            errorStyle: TextStyle(fontSize: 18),
                            labelText: "Şifre",
                            labelStyle: TextStyle(fontSize: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.purple))),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FlatButton.icon(
                              onPressed: _sifreHatirlat,
                              icon: Icon(Icons.help_outline),
                              label: Text(
                                "Şifremi Unuttum",
                                style: TextStyle(fontSize: 16),
                              )),
                          RaisedButton.icon(
                            icon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            onPressed: _emailSifreGiris,
                            color: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            hoverColor: Colors.black,
                            label: Text(
                              " Giriş Yap",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  child: ListView(
                    children: <Widget>[
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.purple)),
                        child: ListTile(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateUser(title)));
                          },
                          leading: Icon(
                            Icons.email,
                            color: Colors.red,
                          ),
                          title: Text(
                            "Email İle Kayıt Ol",
                            style: TextStyle(fontSize: 20, color: Colors.red),
                          ),
                          trailing: Icon(Icons.arrow_right,
                              size: 32, color: Colors.red),
                        ),
                      ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.purple)),
                        child: ListTile(
                          onTap: _googleLogin,
                          leading: FaIcon(FontAwesomeIcons.google,
                              color: Colors.blue.shade800),
                          title: Text(
                            "Google İle Giriş Yap",
                            style: TextStyle(
                                fontSize: 20, color: Colors.blue.shade800),
                          ),
                          trailing: Icon(Icons.arrow_right,
                              size: 32, color: Colors.blue.shade800),
                        ),
                      ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.purple)),
                        child: ListTile(
                          onTap: _loginPhone,
                          leading: Icon(
                            Icons.phone_iphone,
                            color: Colors.blue.shade900,
                          ),
                          title: Text(
                            "Telefon İle Giriş Yap",
                            style: TextStyle(
                                fontSize: 20, color: Colors.blue.shade900),
                          ),
                          trailing: Icon(Icons.arrow_right,
                              size: 32, color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _emailSifreGiris() async {
    setState(() {
      _isLoading = true;
    });
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      await _auth
          .signInWithEmailAndPassword(email: _email, password: _sifre)
          .then((user) {
        if (user.user.emailVerified == false) {
          Alert(
              type: AlertType.warning,
              context: context,
              title: "HATA!",
              desc:
                  "Lütfen Email Adresinizi Emailinize Gelen Mesajla Onaylayın. \n Email Ulaşmadıysa Aşağıdaki Butonu Tıklayınız!",
              buttons: [
                DialogButton(
                    child: Text(
                      "AKTİVASYON MAİLİ GÖNDER",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      user.user.sendEmailVerification();
                      Navigator.pop(context);
                    }),
              ]).show();
          setState(() {
            _isLoading = false;
          });
        } else {
          //     Navigator.pushNamed(context, "/homePage");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
          formKey.currentState.reset();
        }
      }).catchError((onError) {
        Alert(
            type: AlertType.warning,
            context: context,
            title: "GİRİŞ YAPILAMADI!",
            desc: "Hatalı Email Adresi / Şifre",
            buttons: [
              DialogButton(
                child: Text(
                  "KAPAT",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ]).show();
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sifreHatirlat() {
    Alert(
        context: context,
        title: "ŞİFRE HATIRLATMA",
        desc: _hataMesaji,
        content: Form(
          key: formKeyHatirla,
          child: Column(
            children: <Widget>[
              TextFormField(
                onSaved: (x) {
                  setState(() {
                    _email2 = x;
                  });
                },
                autofocus: true,
                validator: (x) {
                  if (x.isEmpty) {
                    return "Doldurulması Zorunludur!";
                  } else {
                    if (EmailValidator.validate(x) != true) {
                      return "Geçerli Bir Email Adresi Giriniz!";
                    } else {
                      return null;
                    }
                  }
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    errorStyle: TextStyle(fontSize: 18),
                    labelText: "Email",
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(width: 1, color: Colors.purple))),
              ),
              SizedBox(height: 10),
              Text(_hataMesaji != null ? _hataMesaji.toString() : "",
                  style: TextStyle(color: Colors.red))
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: _sifreGonder,
            child: Text(
              "GÖNDER",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  _sifreGonder() async {
    setState(() {
      _isLoading = true;
    });
    if (formKeyHatirla.currentState.validate()) {
      formKeyHatirla.currentState.save();
    }
    await _auth.sendPasswordResetEmail(email: _email2).then((value) {
      Navigator.pop(context);
      Alert(
          type: AlertType.success,
          context: context,
          title: "ŞİFRE GÖNDERİLDİ!",
          desc: "Lütfen Email Adresinizi Kontrol Ediniz!!",
          buttons: [
            DialogButton(
              child: Text(
                "KAPAT",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ]).show();
      setState(() {
        _isLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        Navigator.pop(context);
        Alert(
            type: AlertType.warning,
            context: context,
            title: "HATA!",
            desc: "Lütfen Kayıtlı Bir Email Adresi Giriniz!",
            buttons: [
              DialogButton(
                child: Text(
                  "KAPAT",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ]).show();
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  void _googleLogin() {
    setState(() {
      _isLoading = true;
    });
    _googleSignIn.signIn().then((sonuc) {
      sonuc.authentication.then((googleKeys) {
        AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleKeys.idToken, accessToken: googleKeys.accessToken);
        _auth.signInWithCredential(credential).then((user) async {
          //  Navigator.pushNamed(context, "/homePage");
          String aktifKullaniciId = user.user.uid;
          var gelenUser = await _firestore
              .collection("Users")
              .where("kullaniciId", isEqualTo: aktifKullaniciId)
              .get();
          if (gelenUser.docs.length != 0) {
          } else
            await FirestoreServisleri().kullaniciVeritabaninaKaydet(
                "https://bilimgenc.tubitak.gov.tr/sites/default/files/styles/770px_node/public/insan_gozu_ile_fotograf_makinesini_karsilastiralim_9.jpg?itok=H1u_bPQL",
                user.user.uid,
                user.user.uid);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
        }).catchError((hata) {
          Alert(
              type: AlertType.success,
              context: context,
              title: "GİRİŞ YAPILAMADI!",
              desc: "Google Giriş Hatası! \n $hata",
              buttons: [
                DialogButton(
                  child: Text(
                    "KAPAT",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              ]).show();
          setState(() {
            _isLoading = false;
          });
        });
      }).catchError((hata) {
        Alert(
            type: AlertType.success,
            context: context,
            title: "GİRİŞ YAPILAMADI!",
            desc: "Google Authentication Hatası! \n $hata",
            buttons: [
              DialogButton(
                child: Text(
                  "KAPAT",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ]).show();
        setState(() {
          _isLoading = false;
        });
      });
    }).catchError((hata) {
      Alert(
          type: AlertType.success,
          context: context,
          title: "GİRİŞ YAPILAMADI!",
          desc: "Google SingIn Hatası! \n $hata",
          buttons: [
            DialogButton(
              child: Text(
                "KAPAT",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ]).show();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _loginPhone() {
    Alert(
        context: context,
        title: "TELEFONLA GİRİŞ",
        desc: _hataMesaji,
        content: Form(
          key: formKeyHatirla,
          child: Column(
            children: <Widget>[
              TextFormField(
                onSaved: (x) {
                  setState(() {
                    _phone = "+90$x";
                  });
                },
                autofocus: true,
                validator: FieldValidator.required(
                    message: "Doldurulması Zorunludur!"),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone_iphone),
                    prefixText: "+90",
                    errorStyle: TextStyle(fontSize: 18),
                    labelText: "Gsm No",
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(width: 1, color: Colors.purple))),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: _loginPhoneSubmit,
            child: Text(
              "GÖNDER",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  _loginPhoneSubmit() async {
    if (formKeyHatirla.currentState.validate()) {
      formKeyHatirla.currentState.save();
      await _auth.verifyPhoneNumber(
          phoneNumber: _phone,
          timeout: Duration(seconds: 30),
          verificationCompleted: (user) {
            debugPrint("yes");
          },
          verificationFailed: (expection) {
            debugPrint("no");
          },
          codeSent: (String verificationId, [int forceResendingToken]) {
            Navigator.pop(context);

            Alert(
                context: context,
                title: "SMS CODE",
                desc: _hataMesaji,
                content: Form(
                  key: formKeySmsCode,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        onSaved: (x) {
                          setState(() {
                            _smsCode = x;
                          });
                        },
                        autofocus: true,
                        validator: FieldValidator.required(
                            message: "Doldurulması Zorunludur!"),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.vpn_key),
                            errorStyle: TextStyle(fontSize: 18),
                            labelText: "Sms Code",
                            labelStyle: TextStyle(fontSize: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.purple))),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                buttons: [
                  DialogButton(
                    onPressed: () {
                      if (formKeySmsCode.currentState.validate()) {
                        formKeySmsCode.currentState.save();

                        AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: _smsCode);
                        _auth
                            .signInWithCredential(credential)
                            .then((user) async {
                          var gelenUser = await _firestore
                              .collection("Users")
                              .where("kullaniciId",
                                  isEqualTo: "${user.user.uid}")
                              .get();

                          if (gelenUser.docs.length != 0) {
                            print("buy kullanıcı daha önce giriş yapmıs");
                          } else
                            await FirestoreServisleri().kullaniciVeritabaninaKaydet(
                                "https://bilimgenc.tubitak.gov.tr/sites/default/files/styles/770px_node/public/insan_gozu_ile_fotograf_makinesini_karsilastiralim_9.jpg?itok=H1u_bPQL",
                                user.user.uid,
                                user.user.uid);
                          user.user.updateEmail("mekasular@hotmail.com");
                          user.user.updatePassword("123456A+");

                          //    Navigator.pushNamed(context, "/homePage");
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen()));
                        }).catchError((hata) {});
                      }
                    },
                    child: Text(
                      "GÖNDER",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ]).show();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            debugPrint("timeout verification Id: $verificationId");
          });
    }
  }
}
