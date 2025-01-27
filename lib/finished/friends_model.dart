import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'package:yo/finished/person.dart';
import 'package:yo/finished/session_model.dart';

class FriendsModel extends Model {
  /// Easy access to this model using [ScopedModel.of]
  static FriendsModel of(BuildContext context) =>
      ScopedModel.of<FriendsModel>(context);

  FriendsModel(this.userModel) {
    _loadFriends();
  }

  List<Person> get friends => _friends?.toList() ?? [];
  Iterable<Person> _friends;

  bool get isLoading => _friends == null;

  SessionModel userModel;

  DateTime _lastYoSent = DateTime(0);

  Future<void> sendYo(Person person) async {
    if (!userModel.isUserLoggedIn) {
      throw "not logged in ";
    }
    if (DateTime.now().difference(_lastYoSent).inSeconds < 5) {
      throw SpammyException();
    }
    _lastYoSent = DateTime.now();
    await http
        .get('https://us-central1-yo-flutter-80f0f.cloudfunctions.net/sendYo?'
            'fromUid=${userModel.uid}&toUid=${person.uid}');
  }

  Future<void> _loadFriends() async {
    final stream =
        Firestore.instance.collection(Person.REF).orderBy("name").snapshots();
    stream.listen((QuerySnapshot snapshot) {
      _friends = snapshot.documents.map((data) => Person.fromJson(data.data));
      notifyListeners();
    });
  }
}

class SpammyException implements Exception {}
