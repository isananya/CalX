// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:calx/pages/basic.dart';
import 'package:calx/pages/whiteboard.dart';
import 'package:flutter/material.dart';
import 'dart:ui';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( "CalX"),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 206, 201, 201),
        child: Column(
          children: [
            DrawerHeader(child: Icon(
              Icons.calculate,
              size: 48,
            )),
            
            ListTile(
              leading: Icon(Icons.calculate_sharp),
              title: Text("B a s i c"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Calculator()),
                );
              },

            ),

            ListTile(
              leading: Icon(Icons.integration_instructions),
              title: Text("I n t e g r a t i o n"),
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text("S e t t i n g s"),
            ),
          ],
        ),
      ),
      body: new CalculatorWhiteboard(),
    );
  }
}

