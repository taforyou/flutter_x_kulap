import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

Future<List<Article>> fetchPostNews() async {
  String link =
      "https://newsapi.org/v2/top-headlines?country=th&apiKey=a1cc62c2b46541ecb4726f3fefed8b2a";
  var response = await http
      .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
      print(response.body);

  if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var rest = data["articles"] as List;
      print(rest); 
      return rest.map<Article>((json) => Article.fromJson(json)).toList();
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Article {
  Source source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;

  Article(
      {this.source,
      this.author,
      this.title,
      this.description,
      this.url,
      this.urlToImage,
      this.publishedAt,
      this.content});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        source: Source.fromJson(json["source"]),
        author: json["author"],
        title: json["title"],
        description: json["description"],
        url: json["url"],
        urlToImage: json["urlToImage"],
        publishedAt: json["publishedAt"],
        content: json["content"]);
  }
}

class Source {
  String id;
  String name;

  Source({this.id, this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json["id"] as String,
      name: json["name"] as String,
    );
  }
}

class Post {
  final balances;
  //final int userId;
  //final int id;
  //final String title;
  //final String body;

  Post({this.balances});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      balances: json['balances'],
    );
  }
}

void main() => runApp(MyApp(post: fetchPost(),list: fetchPostNews()));

// คือถ้าเป็น Stateful จะได้จัดการ State ได้
class MyApp extends StatelessWidget {
  final Future<Post> post;
  final Future<List<Article>> list;

  MyApp({Key key, this.post, this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<Article>>(
            future: list,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data[0].source.name);
                  return Text("Hey");
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
