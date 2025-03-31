import 'package:flutter/material.dart';
import 'package:tracklaw/landingPage/Button.dart';
import 'package:tracklaw/landingPage/Squaremaker.dart';
import 'package:tracklaw/loginPage/loginPage.dart';
import 'package:tracklaw/registerPage/RegisterNewAccount.dart';

class openingPage extends StatefulWidget {
  const openingPage({super.key});

  @override
  State<openingPage> createState() => _openingPageState();
}

class _openingPageState extends State<openingPage> {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
              child: SingleChildScrollView(
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
                              padding:
                                  const EdgeInsets.only(left: 20, right: 100),
                              child: Text(
                                  'Putting the law in the eyes of the people',
                                  style: TextStyle(fontSize: 30))),
                          SizedBox(height: 40),
                          MyButton(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginAccount()));
                            },
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
                                      imagePath: '../images/Instagram_icon.jpg'),
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
                        ]))),
              ))),
    );
  }
}
