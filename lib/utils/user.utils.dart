import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

Future<String> loadUserId() async {
  SharedPreferences _pref = await SharedPreferences.getInstance();
  var userId;

  if(_pref.containsKey('userId')) {
    userId = _pref.getString('userId');
  } else {
    userId = uuid.v4();
    _pref.setString('userId', userId);
  }

  return userId;
}