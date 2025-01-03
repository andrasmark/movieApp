import 'package:flutter/material.dart';
import 'package:movie_app/src/components/custom_welcome.dart';
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
    return CustomScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Text(
              "Welcome to \n Cinema Collection\n HUB!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            height: 80.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      Navigator.pushReplacementNamed(
                          context, RegistrationPage.id);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
