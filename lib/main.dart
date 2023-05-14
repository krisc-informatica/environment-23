import 'dart:collection';
import 'dart:convert';

import 'package:environment/models/Environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EnvironmentApp());
}

class EnvironmentApp extends StatelessWidget {
  const EnvironmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Environment App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Home(city: 'Aachen'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.city});

  final String city;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  String? city;
  bool _loaded = false;
  late Map<String, dynamic> envData;

  @override
  void initState() {
    _loadEnvironmentData();
    super.initState();
  }

  Future<void> _loadEnvironmentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myCity = prefs.getString('city') ?? widget.city;
    prefs.setString('city', myCity);
    setState(() {
      city = myCity;
    });

    final response = await http.get(Uri.parse(
        'http://api.waqi.info/feed/$city/?token=1c9197115cd6b4b0a2f7fda5b8175312eb7d66e8'));
    debugPrint(response.body);
    final data = jsonDecode(response.body);

    setState(() {
      envData = data;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextField cityField = TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Search city',
      ),
      onChanged: (text) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('city', text);
        _loadEnvironmentData();
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(city ?? 'Waiting...'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              cityField,
              const Spacer(),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: _elements(),
                )),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('city', 'Düsseldorf');
          },
          child: const Icon(Icons.change_circle)),
    );
  }

  List<Widget> _elements() {
    List<Widget> elements;
    if (!_loaded) {
      elements = [const Text('No data available yet')];
    } else {
      if (envData['status'] != 'error') {
        Environment data = Environment.fromJson(envData);

        Image img;
        if (data.aqi < 51) {
          img = Image.asset('assets/images/aqi_0.png');
        } else if (data.aqi < 101) {
          img = Image.asset('assets/images/aqi_51.png');
        } else if (data.aqi < 151) {
          img = Image.asset('assets/images/aqi_101.png');
        } else if (data.aqi < 201) {
          img = Image.asset('assets/images/aqi_151.png');
        } else if (data.aqi < 301) {
          img = Image.asset('assets/images/aqi_201.png');
        } else {
          img = Image.asset('assets/images/aqi_301.png');
        }

        elements = [
          img,
          Text(
            'Current temperature: ${data.temperature}C',
          ),
          Text(
            'Current humidity: ${data.humidity}%',
          ),
          Text(
            'Current pressure: ${data.pressure} hPa',
          ),
        ];
      } else {
        elements = [const Text('Unknown city')];
      }
    }
    return elements;
  }
}
