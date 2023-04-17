import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  bool _loaded = false;
  late Map<String, dynamic> envData;

  @override
  void initState() {
    _loadEnvironmentData();
    super.initState();
  }

  Future<void> _loadEnvironmentData() async {
    final response = await http.get(Uri.parse(
        'http://api.waqi.info/feed/aachen/?token=1c9197115cd6b4b0a2f7fda5b8175312eb7d66e8'));
    // debugPrint(response.body);
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
        title: Text(widget.city),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _loaded
                ? Text(
                    'Current temperature: ' +
                        envData['data']['iaqi']['t']['v'].toString(),
                  )
                : const Text('No data available yet'),
          ],
        ),
      ),
    );
  }
}
