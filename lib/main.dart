import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:toonfu/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:toonfu/types/provider/worker.dart';
import 'package:toonfu/isolates/lua.dart';

void main() {
  Isolate.spawn<void>(luaLoop, null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Worker()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

