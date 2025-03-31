import 'package:flutter/material.dart';
import 'landingPage/Button.dart';
import 'landingPage/Squaremaker.dart';
import 'package:tracklaw/registerPage/RegisterNewAccount.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ignore: unused_field
  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0; // Fully visible
      });
    });
  } // Start fully transparent

  //sign the user in
  void signUserIn() {}
  void register() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: Duration(seconds: 1),
                    child: Column(children: [
                      SizedBox(height: 70),
                      Padding(
                        padding: const EdgeInsets.only(right: 1),
                        child: Text('TrackLaw',
                            style: TextStyle(
                              fontSize: 50,
                            )),
                      ),
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
                      SizedBox(height: 50),
                      Padding(
                          padding: const EdgeInsets.only(left: 20, right: 100),
                          child: Text(
                              'Prompt view not donewwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww',
                              style: TextStyle(fontSize: 30))),
                      SizedBox(height: 40),
                      MyButton(onTap: signUserIn),
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
                      Text(
                        ' Or you can sign in with ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      Padding(
                          padding: const EdgeInsets.only(
                            right: 1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Squaretile(
                                  imagePath: 'lib/images/Instagram_icon.jpg'),
                              SizedBox(width: 60),
                              Squaretile(imagePath: 'lib/images/X_logo.png'),
                              SizedBox(width: 60),
                              Squaretile(
                                  imagePath: 'lib/images/GoogleImage.png')
                            ],
                          )),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: InkWell(
                          child: Text('You can also register here',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.blueAccent)),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterNewAccount()));
                          },
                        ),
                      )
                    ])))));
  }
}
