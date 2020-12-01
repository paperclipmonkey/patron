import 'dart:convert';

import 'package:drinksmaker/customIcons.dart';
import 'package:drinksmaker/recipe.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Wrap a Recipe in an order request
class OrderRequest {
  final Recipe recipe;

  OrderRequest(this.recipe);

  Map<String, dynamic> toJson() => {
        'type': 'make',
        'recipe': recipe,
      };
}

class RecipePage extends StatelessWidget {
  final Recipe recipe;
  final WebSocketChannel channel;

  RecipePage({Key key, this.recipe, this.channel}) : super(key: key);

  orderDrink() {
    channel.sink.add(json.encode(OrderRequest(recipe)));
  }

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(Ingredient ingredient) => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          title: Text(
            ingredient.name,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Padding(
                    padding: EdgeInsets.only(left: 0.0),
                    child: Text(ingredient.amount.toString(),
                        style: TextStyle(color: Colors.white))),
              )
            ],
          ),
        );

    Card makeCard(Ingredient ingredient) => Card(
          elevation: 0.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: makeListTile(ingredient),
          ),
        );

    final levelIndicator = Container(
      child: Container(
        child: LinearProgressIndicator(
            backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
            value: recipe.units / 10, // 1 - 10 = 0.1 - 1
            valueColor: AlwaysStoppedAnimation(Colors.green)),
      ),
    );

    final coursePrice = Container(
      padding: const EdgeInsets.all(7.0),
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5.0)),
      child: new Text(
        recipe.volume().toString() + " ml",
        style: TextStyle(color: Colors.white),
      ),
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 120.0),
        Icon(
          CustomIcons.getIcon(recipe.glass),
          color: Colors.white,
          size: 40.0,
        ),
        Container(
          width: 90.0,
          child: new Divider(color: Colors.green),
        ),
        SizedBox(height: 10.0),
        Text(
          recipe.name,
          style: TextStyle(color: Colors.white, fontSize: 45.0),
        ),
        SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 1, child: levelIndicator),
            Expanded(
                flex: 6,
                child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      recipe.units.toString() + ' Units',
                      style: TextStyle(color: Colors.white),
                    ))),
            Expanded(flex: 2, child: coursePrice)
          ],
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 10.0),
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/images/bar_bottles.jpg"),
                fit: BoxFit.cover,
              ),
            )),
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(30.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, .8)),
          child: Center(
            child: topContentText,
          ),
        ),
        Positioned(
          left: 8.0,
          top: 60.0,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
        )
      ],
    );

    final bottomContentText = Text(
      recipe.description,
      style: TextStyle(fontSize: 18.0),
    );

    final mixButton = Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: RaisedButton(
          onPressed: orderDrink,
          color: Color.fromRGBO(58, 66, 86, 1.0),
          child: Text("MIX THIS DRINK", style: TextStyle(color: Colors.white)),
        ));

    final ingredientsList = Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: recipe
            .ingredients()
            .length,
        itemBuilder: (BuildContext context, int index) {
          return makeCard(recipe.ingredients()[index]);
        },
      ),
    );

    final bottomContent = Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[bottomContentText, ingredientsList, mixButton],
        ),
      ),
    );

    return Scaffold(
      body: ListView(
        children: <Widget>[topContent, bottomContent],
      ),
    );
  }
}
