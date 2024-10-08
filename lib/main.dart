// ignore_for_file: unused_import

import 'package:calx/pages/home.dart';
import 'package:calx/pages/intro_slider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home:  WelcomeScreen(),
    );
  }
}