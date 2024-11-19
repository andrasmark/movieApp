import 'package:flutter/material.dart';
import 'package:movie_app/src/pages/authentication/registration_page.dart';

import 'authentication/login_page.dart';

class WelcomePage extends StatefulWidget {
  static String id = 'welcome_page';

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
                colour: Colors.lightBlueAccent,
                title: 'Log in',
                onPress: () {
                  Navigator.pushReplacementNamed(context, LoginPage.id);
                }),
            RoundedButton(
                colour: Colors.blueAccent,
                title: 'Register',
                onPress: () {
                  Navigator.pushReplacementNamed(context, RegistrationPage.id);
                }),
          ],
        ),
      ),
    );
  }
}
