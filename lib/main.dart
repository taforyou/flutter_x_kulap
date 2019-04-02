import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stellar/stellar.dart';

Future<Post> fetchPost() async {
  final response = await http.get(
      'https://horizon-testnet.stellar.org/accounts/GDJH3EQLDSLQRJQKLCMTMCNEPEU6EGZ5YIQGOQWUAMJ6RRBZ3CLKTLNY');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final balances;

  Post({this.balances});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      balances: json['balances'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: MyTempPage(
            title: 'Stellar Demo Wallet',
            post: fetchPost()), // ให้รัน Fetch command ตรงนี้ !!!
      ),
    );
  }
}

class MyTempPage extends StatefulWidget {
  MyTempPage({Key key, this.title, this.post});
  // ได้เหมือนกันซึ่งก็ติดไว้ก่อนล่ะกัน ไม่รู้ใช้ตอนไหน ไม่ใช้ตอนไหน !!!
  // MyTempPage({Key key, this.title, this.post}) : super(key: key);
  final String title;
  final Future<Post> post;

  @override
  _MyTempPageState createState() => _MyTempPageState(post: this.post);
}

class _MyTempPageState extends State<MyTempPage> {
  _MyTempPageState({Key key, this.post});
  final Future<Post> post;
  int _counter = 0;
  bool _isLoading = false;

  // Methode นี้ไม่ต้องเป็น Async / Await แล้ว เพราะว่าตัว Lib มันทำให้แล้ว
  _sendPayment() {
    setState(() {
      _isLoading = true;
    });

    Network.useTestNetwork();
    Server server = new Server("https://horizon-testnet.stellar.org");

    KeyPair source = KeyPair.fromSecretSeed(
        "SDFPPL6DA4K3YZXX3MTPE6WIGSIXOFXSLKZQ5URHDONPISEX7O6RKEVW");
    KeyPair destination = KeyPair.fromAccountId(
        "GB74XD276N2MCJOAKGNVJMQFVKAPCXM7R3V2HXX2F27B4EKW7UP23UOP");

    server.accounts.account(source).then((sourceAccount) {
      Transaction transaction = new TransactionBuilder(sourceAccount)
          .addOperation(new PaymentOperationBuilder(
                  destination, new AssetTypeNative(), "200")
              .build())
          .addMemo(Memo.text("Test Transaction"))
          .build();
      transaction.sign(source);

      server.submitTransaction(transaction).then((response) {
        print("Success!");
        setState(() {
          _isLoading = false;
        });
        print(response);
      }).catchError((error) {
        print("Something went wrong!");
      });
    });
  }

  // void sendPayment() {
  //   Network.useTestNetwork();
  //   Server server = new Server("https://horizon-testnet.stellar.org");

  //   KeyPair source = KeyPair.fromSecretSeed(
  //       "SDFPPL6DA4K3YZXX3MTPE6WIGSIXOFXSLKZQ5URHDONPISEX7O6RKEVW");
  //   KeyPair destination = KeyPair.fromAccountId(
  //       "GB74XD276N2MCJOAKGNVJMQFVKAPCXM7R3V2HXX2F27B4EKW7UP23UOP");

  //   server.accounts.account(source).then((sourceAccount) {
  //     Transaction transaction = new TransactionBuilder(sourceAccount)
  //         .addOperation(new PaymentOperationBuilder(
  //                 destination, new AssetTypeNative(), "200")
  //             .build())
  //         .addMemo(Memo.text("Test Transaction"))
  //         .build();
  //     transaction.sign(source);

  //     server.submitTransaction(transaction).then((response) {
  //       print("Success!");
  //       print(response);
  //     }).catchError((error) {
  //       print("Something went wrong!");
  //     });
  //   });
  // }

  // void _incrementCounter() {
  //   print("Hey Dude !!!");
  //   sendPayment();
  //   setState(() {
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FutureBuilder<Post>(
                    future: post,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<String> listArray = [];
                        for (var book in snapshot.data.balances[0].keys) {
                          listArray.add(snapshot.data.balances[0][book]);
                        }
                        return Text(listArray[0]);
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner
                      return CircularProgressIndicator();
                    },
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.display1,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendPayment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
