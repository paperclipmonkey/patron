import 'dart:convert';

import 'package:drinksmaker/recipe.dart';
import 'package:drinksmaker/recipePage.dart';
import 'package:drinksmaker/settingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:preferences/preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'customIcons.dart';

WebSocketChannel channel;

void _tryConnect() {
  var connectionUrl = 'ws://' + PrefService.getString('server_ip');
  channel = IOWebSocketChannel.connect(connectionUrl);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefService.init(prefix: 'pref_');
  PrefService.setDefaultValues({'server_ip': '192.168.0.25:8080'});
  _tryConnect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  void goToRecipePage(Recipe recipe, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RecipePage(recipe: recipe, channel: channel)));
  }

  ListTile makeListTile(Recipe recipe) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: new BoxDecoration(
                border: new Border(
                    right: new BorderSide(width: 1.0, color: Colors.white24))),
            child: Icon(
              CustomIcons.getIcon(recipe.glass),
              size: 26.0,
            )),
        title: Text(
          recipe.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Text(
                      recipe.intro.isNotEmpty
                          ? recipe.intro
                          : recipe.description,
                      style: TextStyle(color: Colors.white))),
            )
          ],
        ),
        trailing:
            Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      RecipePage(recipe: recipe, channel: channel)));
        },
      );

  Card makeCard(Recipe recipe) => Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: makeListTile(recipe),
        ),
      );

  final List<Recipe> recipes = <Recipe>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        title: Text("Recipes"),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  _tryConnect();
                  registerHandler();
                  fetchRecipes();
                },
                child: Icon(
                  Icons.refresh,
                  size: 26.0,
                ),
              )),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SettingsPage(channel: channel)));
                },
                child: Icon(
                  IconData(0xe9c6, fontFamily: 'MaterialIcons'),
                  size: 26.0,
                ),
              )),
        ],
      ),

      body: Stack(children: <Widget>[
        // Image(
        //   image: AssetImage('assets/images/splash/background.jpg'),
        //   repeat: ImageRepeat.repeat,
        // ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: recipes.length,
            itemBuilder: (BuildContext context, int index) {
              return makeCard(recipes[index]);
            },
          ),
        )
      ]), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // Ask for recipes from the server
  fetchRecipes() async {
    setState(() {
      recipes.clear();
    });
    channel.sink.add("{\"type\":\"recipes\"}");
  }

  void registerHandler() {
    channel.stream.listen((receivedMessage) {
      var dataJson = json.decode(receivedMessage);

      if (dataJson['recipes'] != null) {
        // It's a recipe response
        var tagObjsJson = jsonDecode(receivedMessage)['recipes'] as List;

        setState(() {
          List<Recipe> tagObjs =
              tagObjsJson.map((tagJson) => Recipe.fromJson(tagJson)).toList();
          recipes.clear(); // New recipe list
          tagObjs.forEach((recipe) {
            recipes.insert(0, recipe);
          });
        });
      }
    });
  }

  @override
  void initState() {
    registerHandler();

    fetchRecipes();

    super.initState();
  }
}