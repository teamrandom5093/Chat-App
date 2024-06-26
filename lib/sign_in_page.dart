import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  SignInPage({super.key, required this.title});
  String title;
  String fb = "facebook";
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 30),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              flex: 1,
              child: Text("data"),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    iconAlignment: IconAlignment.end,
                    label: Text("Sign In with "),
                    icon: Icon(Icons.facebook),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    iconAlignment: IconAlignment.end,
                    label: Text("Sign In with "),
                    icon: Icon(Icons.facebook),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    iconAlignment: IconAlignment.end,
                    label: Text("Sign In with "),
                    icon: Icon(Icons.facebook),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
