import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/text_field_container.dart';
import 'package:flutterfirebase/pages/Login/login_screen.dart';
import 'package:flutterfirebase/pages/Signup/components/background.dart';
import 'package:flutterfirebase/pages/Signup/components/or_divider.dart';
import 'package:flutterfirebase/pages/Signup/components/social_icon.dart';
import 'package:flutterfirebase/components/already_have_an_account_acheck.dart';
import 'package:flutterfirebase/components/rounded_button.dart';
import 'package:flutterfirebase/components/rounded_input_field.dart';
import 'package:flutterfirebase/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterfirebase/services/firestore_servisleri.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:the_validator/the_validator.dart';

import '../../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  var formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _email;
  String _sifre;
  String adSoyad;
  String kullaniciAdi;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: formKey,
      child: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/signup.svg",
                height: size.height * 0.35,
              ),
              TextFieldContainer(
                child: TextFormField(
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
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.mail,
                      color: kPrimaryColor,
                    ),
                    hintText: "Email Adresinizi Giriniz ",
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextFieldContainer(
                child: TextFormField(
                  onSaved: (x) {
                    setState(() {
                      kullaniciAdi = x;
                    });
                  },
                  autofocus: false,
                  validator: (x) {
                    if (x.isEmpty) {
                      return "Doldurulması Zorunludur!";
                    } else {
                      return null;
                    }
                  },
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                    hintText: "Kullanıcı Adı Giriniz",
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextFieldContainer(
                child: TextFormField(
                  onSaved: (x) {
                    setState(() {
                      adSoyad = x;
                    });
                  },
                  autofocus: false,
                  validator: (x) {
                    if (x.isEmpty) {
                      return "Doldurulması Zorunludur!";
                    } else {
                      return null;
                    }
                  },
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                    hintText: "Ad Soyad Giriniz",
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextFieldContainer(
                child: TextFormField(
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
                      errorMessage: "Minimum 8 Karakter uzunluğunda Olmalıdır!",
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
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Şifre",
                    icon: Icon(
                      Icons.lock,
                      color: kPrimaryColor,
                    ),
                    suffixIcon: Icon(
                      Icons.visibility,
                      color: kPrimaryColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              RoundedButton(
                text: "Kayıt Ol",
                press: _emailSifreEkle,
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginScreen();
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  void _emailSifreEkle() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var _firebaseUser = await _auth
          .createUserWithEmailAndPassword(
            email: _email,
            password: _sifre,
          )
          .catchError((onError) => null);
      if (_firebaseUser != null) {
        _firebaseUser.user
            .updateProfile(displayName: kullaniciAdi)
            .catchError((onError) {
          print("Kullanıcı adı degistirme hatalı $onError");
        });
        await FirestoreServisleri().kullaniciVeritabaninaKaydet(
            "https://bilimgenc.tubitak.gov.tr/sites/default/files/styles/770px_node/public/insan_gozu_ile_fotograf_makinesini_karsilastiralim_9.jpg?itok=H1u_bPQL",
            _firebaseUser.user.uid,
            adSoyad);
        Alert(
            type: AlertType.success,
            context: context,
            title: "KAYIT EKLENDİ!",
            desc: "Lütfen Email Adresinize Gelen Mesajı Onaylıyınız!",
            buttons: [
              DialogButton(
                child: Text(
                  "KAPAT",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ]).show();
        formKey.currentState.reset();

        _firebaseUser.user
            .sendEmailVerification()
            .then((value) => null)
            .catchError((onError) => null);
      } else {
        Alert(
            type: AlertType.warning,
            context: context,
            title: "KAYIT EKLENEMEDİ!",
            desc:
                "Sisteme Kayıtlı Bir Email Adresi Girdiniz. \n Lütfen Farklı Bir Email Adresi Giriniz!",
            buttons: [
              DialogButton(
                child: Text(
                  "KAPAT",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ]).show();
      }
    }
  }
}
