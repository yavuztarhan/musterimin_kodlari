import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/models/conversations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class SohbetDetay extends StatefulWidget {
  final String userId;
  final String conersationId;
  final Conversations sohbet;

  const SohbetDetay({Key key, this.userId, this.conersationId, this.sohbet})
      : super(key: key);

  @override
  _SohbetDetayState createState() => _SohbetDetayState();
}

class _SohbetDetayState extends State<SohbetDetay> with ChangeNotifier {
  CollectionReference _ref;
  FocusNode _focusNode;
  ScrollController _scrollController;
  final TextEditingController _editingController = TextEditingController();
  int _keyboardVisibilitySubscriberId;
  String _url = "";
  KeyboardVisibilityNotification _keyboardVisibility =
      new KeyboardVisibilityNotification();

  Future moveScrollPosition({num duration = 500}) async {
    print("Çalıştı");

    if (_scrollController.hasClients) {
      print("girdi");
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        print("Future çalıştı" + "-----------------------------------");
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(microseconds: 500), curve: Curves.easeIn);
      });
    }
  }

  @override
  void initState() {
    _ref = FirebaseFirestore.instance
        .collection("conversations/${widget.conersationId}/messages");
    _scrollController = ScrollController();
    _focusNode = FocusNode();

    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        moveScrollPosition();
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _editingController.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_sharp)),
        titleSpacing: -5,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.sohbet.profileImage),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(widget.sohbet.name,
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                icon: Icon(Icons.error_outline_rounded, size: 35),
                onPressed: () {}),
          ) //Kullanıcı Bildirme Yeri
        ],
      ),
      body: showMessage(context),
    );
  }

  Container showMessage(BuildContext context) {
    return Container(
      color: Colors.black,
      // decoration: BoxDecoration(
      //     image: DecorationImage(
      //         fit: BoxFit.cover,
      //         image: NetworkImage(
      //             "https://cdn.pixabay.com/photo/2020/12/09/04/01/iceland-5816353_960_720.jpg"))),
      child: Column(children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () => _focusNode.unfocus(),
            child: StreamBuilder(
                stream:
                    _ref.orderBy("timeStamp", descending: false).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  return !snapshot.hasData
                      ? CircularProgressIndicator()
                      : ListView(
                          controller: _scrollController,
                          children: snapshot.data.docs
                              .map((document) => ListTile(
                                
                                  title: Align(
                                      alignment:
                                          widget.userId != document["senderId"]
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                      child: Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                              color: widget.userId !=
                                                      document["senderId"]
                                                  ? Color(0xff212E36)
                                                  : Color(0xff126161),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(
                                            document["message"],
                                            style:
                                                TextStyle(color: Colors.white),
                                          )))))
                              .toList(),
                        );
                }),
          ),
        ),
        _url.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 200,
                    child: Image.network(_url),
                  ),
                ),
              )
            : SizedBox.shrink(),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {},
                        child: Icon(Icons.tag_faces, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        focusNode: _focusNode,
                        controller: _editingController,
                        decoration: InputDecoration(
                            hintText: "Mesajınızı Yazınız...",
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(
                      0xff126161), //Basıldığında renk değiştirsin kullanıcı ses kaydettiğini anlasın
                ),
                child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (_editingController.text.split("").length != 0) {
                        await _ref.add({
                          "senderId": widget.userId,
                          "message": _editingController.text,
                          "timeStamp": DateTime.now(),
                        });

                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        );
                        setState(() {
                          _url = "";
                        });
                        _editingController.text = "";
                      }
                    }))
          ],
        )
      ]),
    );
  }
}
