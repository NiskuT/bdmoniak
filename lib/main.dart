import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:workmanager/workmanager.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'home.dart';
import 'photos.dart';
import 'agenda.dart';

var mesNews;

void main() {
  /*WidgetsFlutterBinding.ensureInitialized();
  Workmanager.cancelAll();
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(
      callbackDispatcher,
      // If enabled it will post a notification whenever
      // the task is running. Handy for debugging tasks
      isInDebugMode: false
  );
  // Periodic task registration
  Workmanager.registerPeriodicTask(
    "2",
    "PeriodicTask",
    constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false),
    initialDelay: Duration(minutes: 1),
    // Minimum frequency is 15 min.
    frequency: Duration(minutes: 20),
  );
*/
  runApp(MyApp());
}


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

/*
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {

    FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings = new InitializationSettings(android: android, iOS: iOS);
    flip.initialize(settings/*, onSelectNotification: onSelectNotification*/);

    _showNotification(flip);

    return Future.value(true);
  });
}


Future<int> _grepLastId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int id = (prefs.getInt('lastNewsId') ?? 0);
  return id;
}

Future<void> _grepLastNews() async {
  var client2 = new http.Client();
  debugPrint("là");
  var response = client2.get('http://bdmoniak.fr/application/produits/lireLastNews.php').timeout(Duration(seconds: 4));

  client2.close();
  mesNews = response;

  var body;

  if (response.statusCode == 200) {
     body = jsonDecode(response.body);
  } else {
    body =  ["0","0"];
  }
  debugPrint("ici");
  debugPrint(body.runtimeType.toString());
  mesNews = body;

}


_writeLastNews(int id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastNewsId', id);
}


Future _showNotification(flip) async {

    var id = await _grepLastId();
    Future.wait([_grepLastNews()]);
    var body;
    debugPrint("here 2");
    var response = await mesNews;
    if ( response.statusCode == 200) {
      body = jsonDecode(response.body);
    } else {
      body =  ["0","0"];
    }
    debugPrint("ici");
    debugPrint(body.runtimeType.toString());
    var lastNews = body;


    debugPrint("here 3");
    debugPrint("id : $id");
    debugPrint("lastNewsid : ${lastNews.runtimeType.toString()}");


    if (id < int.parse(lastNews[0])) {
      debugPrint("Y a une notif!");
      _writeLastNews(int.parse(lastNews[0]));

      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          '1',
          'BdMoniak',
          'News check',
          importance: Importance.max,
          priority: Priority.high
      );
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

      // initialise channel platform for both Android and iOS device.
      var platformChannelSpecifics = new NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics
      );
      await flip.show(0, 'BdMoniaK: Y a du nouveau!',
          lastNews[1],
          platformChannelSpecifics, payload: lastNews[1]
      );
    }
}
*/