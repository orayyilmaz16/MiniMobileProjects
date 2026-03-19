import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  double sliderValue = 1;
  late String time;

  @override
  void initState() {
    super.initState();
    time = _formatTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => time = _formatTime(DateTime.now()));
    });
  }

  String _formatTime(DateTime t) {
    final ist = t.toUtc().add(const Duration(hours: 3));
    return "${ist.hour.toString().padLeft(2, '0')}:"
        "${ist.minute.toString().padLeft(2, '0')}:"
        "${ist.second.toString().padLeft(2, '0')}";
  }

  void increase() => setState(() => counter += sliderValue.toInt());
  void decrease() => setState(
    () => counter = (counter - sliderValue.toInt()).clamp(0, 999999),
  );
  void reset() => setState(() => counter = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f4f8),
      appBar: AppBar(
        title: const Text(
          "Akıllı Sayaç",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade800,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade900],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("İstanbul Saati", style: TextStyle(color: Colors.white70)),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  "$counter",
                  key: ValueKey(counter),
                  style: const TextStyle(
                    fontSize: 56,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Artış Miktarı: ${sliderValue.toInt()}",
                style: const TextStyle(color: Colors.white70),
              ),

              Slider(
                value: sliderValue,
                min: 1,
                max: 50,
                divisions: 49,
                activeColor: Colors.amber,
                onChanged: (v) => setState(() => sliderValue = v),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "dec",
                    backgroundColor: Colors.redAccent,
                    onPressed: decrease,
                    child: const Icon(Icons.remove),
                  ),
                  FloatingActionButton(
                    heroTag: "inc",
                    backgroundColor: Colors.greenAccent,
                    onPressed: increase,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextButton.icon(
                onPressed: reset,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  "Sıfırla",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
