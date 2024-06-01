import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/content/widget/home_page.dart';

class ConnectingPage extends StatefulWidget {
  const ConnectingPage({super.key});

  @override
  State<ConnectingPage> createState() => _ConnectingPageState();
}

class _ConnectingPageState extends State<ConnectingPage> {
  final databaseReference = FirebaseDatabase.instance.ref();
  bool isConnected = false;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  void _checkConnectionStatus() {
    databaseReference.child('connectionStatus').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final status = (event.snapshot.value as Map)['status'];
        setState(() {
          isConnected = status == 'connected';
        });
      }
    });
  }

  void _toggleConnection() {
    if (isConnected) {
      _disconnect();
    } else {
      _connect();
    }
  }

  void _connect() {
    setState(() {
      isConnecting = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isConnecting = false;
        isConnected = true;
      });

      databaseReference
          .child('connectionStatus')
          .set({'status': isConnected ? 'connected' : 'disconnected'});

      if (isConnected) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    });
  }

  void _disconnect() {
    setState(() {
      isConnecting = false;
      isConnected = false;
    });

    databaseReference.child('connectionStatus').set({'status': 'disconnected'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color.fromARGB(255, 17, 191, 229),
              height: 217,
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                'Smart Pet Feeder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 250),
            GestureDetector(
              onTap: _toggleConnection,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isConnected ? Colors.green : Colors.red,
                        width: 7,
                      ),
                    ),
                    child: Text(
                      isConnected ? 'Connected' : 'Connect',
                      style: TextStyle(
                        color: isConnected ? Colors.white : Colors.red,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isConnecting)
                    const SizedBox(
                      width: 170.0,
                      height: 170.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 7,
                        color: Color.fromARGB(255, 17, 191, 229),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
