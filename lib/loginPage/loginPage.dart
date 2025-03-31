import 'package:flutter/material.dart';
import 'package:tracklaw/landingPage/Button.dart';
import 'package:tracklaw/registerPage/textField.dart';
import '/landingPage/loadingScreen.dart';

class LoginAccount extends StatefulWidget {
  const LoginAccount({Key? key}) : super(key: key);

  @override
  State<LoginAccount> createState() => _LoginAccount();
}

class _LoginAccount extends State<LoginAccount> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
             SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 100),
                child: Text(
                    'Welcome back to the fastest and easiest way to see whats going on.',
                    style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 30),
              Mytext(
                  controller: userNameController,
                  hintText: 'Username',
                  obscureText: false),
              //password
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Mytext(
                  controller: passwordController,
                  hintText: 'password',
                  obscureText: false),
          
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Text('You can also register with the following',
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 0.5,
                    color: Colors.grey,
                  ))
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              MyButton(onTap: MyButton.navigateTo(context, LoadingScreen()))
            ],
          )),
        ),
      ),
    );
  }
}
