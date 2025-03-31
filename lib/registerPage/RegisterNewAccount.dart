import 'package:flutter/material.dart';
import 'package:tracklaw/loginPage/loginPage.dart';
import 'package:tracklaw/registerPage/textField.dart';
import 'package:tracklaw/First_page/Squaremaker.dart';
import 'package:tracklaw/First_page/Button.dart';

class RegisterNewAccount extends StatefulWidget {
  const RegisterNewAccount({Key? key}) : super(key: key);

  @override
  State<RegisterNewAccount> createState() => _RegisterNewAccount();
}

class _RegisterNewAccount extends State<RegisterNewAccount> {
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final reTypePasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
            child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 100),
              child: Text('Please put your information down below',
                  style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 30),
            Mytext(
                controller: userNameController,
                hintText: 'Username',
                obscureText: false),
            //email
            SizedBox(height: 30),
            Mytext(
                controller: emailController,
                hintText: 'email',
                obscureText: false),
            //password
            SizedBox(height: 30),
            Mytext(
                controller: passwordController,
                hintText: 'password',
                obscureText: false),
            //retypePassword
            SizedBox(height: 30),
            Mytext(
                controller: reTypePasswordController,
                hintText: 'Retype your password',
                obscureText: false),
            SizedBox(height: 50),
            Text('You can also register with the following',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
            SizedBox(height: 10),
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
            SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.only(
                  right: 1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Squaretile(imagePath: 'lib/images/Instagram_icon.jpg'),
                    SizedBox(width: 60),
                    Squaretile(imagePath: 'lib/images/X_logo.png'),
                    SizedBox(width: 60),
                    Squaretile(imagePath: 'lib/images/GoogleImage.png')
                  ],
                )),
            SizedBox(height: 20),
            InkWell(
              child: Text('Already have an account? click here',
                  style: TextStyle(fontSize: 15, color: Colors.blue)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginAccount()));
              },
            )

            //MyButton(onTap: ,)
          ],
        )),
      ),
    );
  }
}
