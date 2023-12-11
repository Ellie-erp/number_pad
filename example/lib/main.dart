import 'package:flutter/material.dart';
import 'package:number_pad/number_pad.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? _value;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              final result = await showStringNumberPad(context,
                  initialValue: _value, maxLength: 8);
              setState(() {
                _value = result;
              });
            },
            child: Text('$_value')),
      ),
    );
  }
}
