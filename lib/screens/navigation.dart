import 'package:flutter/material.dart';
import './main_dialer.dart';
import 'settings.dart';
import 'call_note.dart';

void main() {
  runApp(AppBarPage());
}

class AppBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Bar Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MainDialer(),
    CallNotes(),
    SettingsWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromRGBO(210, 227, 191, 1),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dialpad),
              label: 'Dialpad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note),
              label: 'Call Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.queue_rounded),
              label: 'Queues',
            ),
          ],
        ),
      ),
    );
  }
}
