import 'package:flutter/material.dart';

import 'home.dart';
import 'photos.dart';
import 'agenda.dart';

void main() => runApp(MyApp());

/// main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'BdMoniak';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// Stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// Private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    AgendaPage(),
    PhotosPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BdMoniaK',
            style: TextStyle(
                fontSize: 27, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.pink[600],
        actions: [
          IconButton(
            icon: new Image.asset('assets/logo.png'),
          ),
          SizedBox(width: 10)
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on_rounded),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Photos',
          ),
        ],
        currentIndex: _selectedIndex,
        //selectedItemColor: Colors.amber[800],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.38),
        backgroundColor: Colors.pink[600],
        selectedFontSize: 15,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
      ),
    );
  }
}
