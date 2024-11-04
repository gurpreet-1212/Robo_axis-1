import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'Screen/currentScreen.dart';
import 'Screen/voltageScreen.dart';
import 'login.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const CurrentScreen(),
    const VoltageScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    void _logout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage()),
      );
    }
    if (user != null) {
      // User is signed in. Navigate to the home screen.
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title:  Text("Roboaxis_Guard"),
          backgroundColor: Colors.grey[850],
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Se déconnecter',
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.topSlide,
                  title: 'Confirmer la déconnexion',
                  desc: 'Êtes-vous certain de vouloir vous déconnecter?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    _logout();
                  },
                ).show();
              },
            ),
          ],
        ),
        body: Center(
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blueAccent, // Set the color of the selected item
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.electric_bolt),
              label: 'Current',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.battery_charging_full),
              label: 'Voltage',
            ),
          ],
        ),
      );
    } else {
      // No user is signed in. Navigate to the login screen.
      return LoginScreen();
    }

  }
}