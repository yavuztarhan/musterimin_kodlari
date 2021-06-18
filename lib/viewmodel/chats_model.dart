import 'package:flutter/material.dart';
import 'package:flutterfirebase/models/conversations.dart';
import 'package:flutterfirebase/services/firestore_servisleri.dart';

class ChatsModel with ChangeNotifier  {
  final FirestoreServisleri _db = FirestoreServisleri();
  Stream<List<Conversations>> conversations(String userId){
    return _db.getConversations(userId);
  }
}