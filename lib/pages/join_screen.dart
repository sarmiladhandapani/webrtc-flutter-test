import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../models/meeting_details.dart';

class JoinScreen extends StatefulWidget {
  final MeetingDetail? meetingDetail;
  const JoinScreen({Key? key, this.meetingDetail,}): super(key: key);
  @override
  State<JoinScreen> createState() => _JoinScreenState();
}
class _JoinScreenState extends State<JoinScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String userName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting App"),
        backgroundColor: Colors.redAccent,
      ), // AppBar
      body: Form(
        key: globalKey,
        child: formUI(),
      ), // Form
    ); // Scaffold
  }

  formUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
              context,
              "userId",
              "Enter your Name",
                  (val) {
                if (val.isEmpty) {
                  return "Name can`t be empty";
                }
                return null;
              },
                  (onSaved) {
                userName = onSaved;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: FormHelper.submitButton(
                    "Join",
                        () {
                      if (validateAndSave()) {
                      }
                    },
                  ),
                ), // Flexible
              ],
            ) // Row
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

}