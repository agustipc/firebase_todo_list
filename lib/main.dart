import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prova Firestore'
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: Firestore.instance.collection('proves').document('test1').get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator());
          }
          final DocumentSnapshot doc = snapshot.data;
          Map<String, dynamic> fields = doc.data;
          return Center(
            child: Text(
              fields['text']
            ),
          );
        },
      )
    );
  }
}