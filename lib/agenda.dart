import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

Future<List<Event>> fetchEvents(http.Client client) async {
  final response = await client
      .get('http://bdmoniak.fr/application/produits/lire_events.php');

  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseEvents, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Event> parseEvents(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Event>((json) => Event.fromJson(json)).toList();
}

class AgendaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Event>>(
        future: fetchEvents(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? calendrier(events: EventDataSource(snapshot.data)) /*getCalendarDataSource())*/
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
//Container(width: 0.0, height: 0.0)

class calendrier extends StatelessWidget {
  final EventDataSource events;
  calendrier({Key key, this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCalendar(
        view: CalendarView.week,
        backgroundColor: Color(0xFFD2DBE0),
        showNavigationArrow: true,
        firstDayOfWeek: 1,
        dataSource: events,
        headerStyle: CalendarHeaderStyle(
            textAlign: TextAlign.center,
            backgroundColor: Color(0xFF8CA2AE),
            textStyle: TextStyle(
                fontSize: 25,
                fontStyle: FontStyle.normal,
                letterSpacing: 5,
                color: Color(0xFFff5eaea),
                fontWeight: FontWeight.w500)),
        minDate: DateTime(2020, 12, 1, 10, 0, 0),
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 8,
          endHour: 24,
          minimumAppointmentDuration: Duration(minutes: 30),
          dateFormat: 'd',
          dayFormat: 'EEE',
        ),
        initialSelectedDate: DateTime.now(),
        selectionDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.pink[600], width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          shape: BoxShape.rectangle,
        ),
        todayHighlightColor: Colors.pink[600],
        onLongPress: (CalendarLongPressDetails details) {
          calendarTapped(details, context);
        },
      ),
    );
  }
}


SnackBar calendarTapped(
    CalendarLongPressDetails details, BuildContext context) {
  if (details.targetElement == CalendarElement.appointment) {
    final Event evenement = details.appointments[0];

    final snackBar = SnackBar(
      content: Column(children: <Widget>[
          Flexible(
            child: Text(
              evenement.eventName,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 22,
              ),
            ),
          ),
          Flexible(
            child: Text(
              (() {
                if (evenement.debut.day == evenement.fin.day){
                  return 'Le ${evenement.debut.day}/${evenement.debut.month}';
                }
                else {
                  return 'Du ${evenement.debut.day}/${evenement.debut.month} '
                      'au ${evenement.fin.day}/${evenement.fin.month}';
                }})(),

              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
          Text(''),
          Flexible(
            child: Text(
              (() {
                var debut = '';
                var fin = '';
                if (evenement.debut.minute == 0){
                  debut = 'De ${evenement.debut.hour}h';
                }
                else if (evenement.debut.minute < 10){
                  debut = 'De ${evenement.debut.hour}h0${evenement.debut.minute}';
                }
                else{
                  debut = 'De ${evenement.debut.hour}h${evenement.debut.minute}';
                }

                if (evenement.fin.minute == 0){
                  fin =  ' à ${evenement.fin.hour}h';
                }
                else if (evenement.fin.minute < 10) {
                  fin = ' à ${evenement.fin.hour}h0${evenement.fin.minute}';
                }
                else {
                  fin =  ' à ${evenement.fin.hour}h${evenement.fin.minute}';
                }
                return debut + fin;

              } ()),
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
          ),
          Flexible(
            child: Text(
                (() {
                  if (evenement.lieu == null){
                    return ' ';
                  }
                  else{
                    return 'Rendez vous ${evenement.lieu}!';
                  }

                }()),
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
          ),
          Flexible(
              child: Text(
                  '${(evenement.description == null ? 'Ca sera génial!' : evenement.description)}',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis)),
        ],
          mainAxisSize: MainAxisSize.min
      ),

      duration: const Duration(seconds: 30),
      padding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      behavior: SnackBarBehavior.floating,
    );
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

class Event {
  final String eventName;
  final DateTime debut;
  final DateTime fin;
  final String lieu;
  final String description;
  final String couleur;

  Event(
      {this.eventName,
      this.debut,
      this.fin,
      this.lieu,
      this.description,
      this.couleur});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventName: json['titre'] as String,
      debut: DateTime.parse(json['date']),
      fin: DateTime.parse(json['date_fin']),
      lieu: json['lieu'] as String,
      description: json['description'] as String,
      couleur: json['couleur'] as String,
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].debut;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].fin;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    switch (appointments[index].couleur) {
      case "rouge":
        return Colors.redAccent;
        break;

      case "orange":
        return Colors.orange;
        break;

      case "vert":
        return Colors.green;
        break;

      case "bleu":
        return Colors.blue;
        break;

      case "violet":
        return Colors.purple;
        break;

      default:
        return Colors.blue[200];
        break;
    }
  }
}
/*
EventDataSource getCalendarDataSource() {
  List<Event> appointments = <Event>[];
  appointments.add(Event(
    debut: DateTime(2021, 2, 23, 12, 0, 0),
    fin: DateTime(2021, 2, 23, 13, 0, 0),
    eventName: 'Meeting Meeting Meeting Meeting Meeting Meeting Meeting Meeting Meeting Meeting Meeting Meeting',
    couleur: "rouge",
    description: 'blablabla blablabla blablabla blablabla blablabla '
        'blablabla blablabla blablabla blablabla blablabla blablabla '
        'blablabla blablabla blablabla blablabla blablabla blablabla '
        'blablabla blablabla blablabla blablabla blablabla blablabla '
        'blablabla blablabla blablabla blablabla blablabla blablabla '
        'blablabla blablabla blablabla blablabla blablabla blablabla '
        'blablabla blablabla blablabla blablabla blablabla blablabla ',
    lieu: 'ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici ici '
  ));
  appointments.add(Event(
    debut: DateTime(2021, 2, 23, 14,15, 0),
    fin: DateTime(2021, 2, 23, 15, 8, 0),
    eventName: 'Release Meeting',
    couleur: "orange",
  ));
  appointments.add(Event(
    debut: DateTime(2021, 2, 23, 16, 10, 0),
    fin: DateTime(2021, 2, 23, 17, 5, 0),
    eventName: 'Performance check',
    couleur: "vert",
  ));
  appointments.add(Event(
    debut: DateTime(2021, 2, 24, 12, 5, 0),
    fin: DateTime(2021, 2, 24, 13, 0, 0),
    eventName: 'Support',
    couleur: "bleu",
  ));
  appointments.add(Event(
    debut: DateTime(2020, 12, 12, 16, 0, 0),
    fin: DateTime(2020, 12, 12, 22, 0, 0),
    eventName: 'Retrospective',
    couleur: "violet",
  ));

  return EventDataSource(appointments);
}
*/