import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webrtc_test/utils/user.utils.dart';

String MEETING_API_URl = 'http://192.168.1.5:4000/api/meeting';
var client = http.Client();

Future<http.Response?> startMeeting() async {
  Map<String, String> reqHeaders = { 'Content-Type': 'application/json' };
  var userId = await loadUserId();

  var response = await client.post(
    Uri.parse('$MEETING_API_URl/start'),
    headers: reqHeaders,
    body: jsonEncode({
      'hostId': userId,
      'hostName': ''
    })
  );
  print('-------------------------');
  print(response.body);
  if(response.statusCode == 200) {
    return response;
  } else {
    return null;
  }
}


Future<http.Response> joinMeeting(String meetingId) async {
  var response = await http.get(Uri.parse('$MEETING_API_URl/join?meetingId=$meetingId'));

  print('-------------------------');
  print(response.body);
  print('$MEETING_API_URl/join?meetingId=$meetingId');
  if(response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }

  throw UnsupportedError('Not a valid meeting!');
}
