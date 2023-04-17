import 'dart:collection';
import 'dart:convert';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(city ?? 'Waiting...'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _elements(),
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
      elements = [
        Text(
          'Current temperature: ${envData['data']['iaqi']['t']['v']}C',
        ),
        Text(
          'Current humidity: ${envData['data']['iaqi']['h']['v']}%',
        ),
        Text(
          'Current pressure: ${envData['data']['iaqi']['p']['v']} hPa',
        ),
      ];
    }
    return elements;
  }
}
