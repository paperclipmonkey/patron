import 'dart:convert';

import 'package:drinksmaker/customIcons.dart';
import 'package:drinksmaker/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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

class MixButton extends StatelessWidget {
  final Recipe recipe;
  final WebSocketChannel channel;

  MixButton({Key key, this.recipe, this.channel}) : super(key: key);

  orderDrink() {
    channel.sink.add(json.encode(OrderRequest(recipe)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          onPressed: () {
            showBottomSheet(
                context: context,
                builder: (context) => Container(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      child: Card(
                          elevation: 10,
                          child: Column(children: [
                            LinearProgressIndicator(
                              value: 0.5,
                              minHeight: 6,
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 5.0),
                                child: MarkdownBody(
                                    data: recipe.pre.isNotEmpty
                                        ? recipe.pre
                                        : 'Place a glass in to the bartender')),
                            RaisedButton(
                              onPressed: orderDrink,
                              color: Color.fromRGBO(58, 66, 86, 1.0),
                              child: Text("MIX THIS DRINK",
                                  style: TextStyle(color: Colors.white)),
                            )
                          ])),
                    ));
          },
          color: Color.fromRGBO(58, 66, 86, 1.0),
          child: Text("MIX THIS DRINK", style: TextStyle(color: Colors.white)),
        ));
  }
}

class RecipePage extends StatelessWidget {
  final Recipe recipe;
  final WebSocketChannel channel;

  RecipePage({Key key, this.recipe, this.channel}) : super(key: key);

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
                    child: Text(ingredient.amount.toString() + ' ml',
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

    final unitsIndicator = Container(
      child: Container(
        child: LinearProgressIndicator(
            backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
            value: recipe.units / 10, // 1 - 10 = 0.1 - 1
            valueColor: AlwaysStoppedAnimation(Color.lerp(
                Colors.green[300], Colors.red[300], recipe.units / 10))),
      ),
    );

    final volumeLabel = Container(
      padding: const EdgeInsets.all(7.0),
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5.0)),
      child: new Text(
        recipe.volume().toString() + " ml",
        style: TextStyle(fontSize: 10, color: Colors.white),
      ),
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 130.0), // Height above
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Icon(
                CustomIcons.getIcon(recipe.glass),
                color: Colors.white,
                size: 40.0,
              ),
            ),
            Expanded(
                flex: 4,
                child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: unitsIndicator),
                            Expanded(
                                child: Text(
                                  recipe.units.toString() + ' Units',
                                  style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                                )),
                          ],
                        ),
                        volumeLabel
                      ],
                    ))),
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
          width: MediaQuery
              .of(context)
              .size
              .width,
          decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, .8)),
          child: Center(
            child: topContentText,
          ),
        ),
      ],
    );

    final bottomContentText = MarkdownBody(
      data: recipe.description,
    );


    final ingredientsList = ExpansionTile(
      title: Text('Ingredients'),
      children: <Widget>[
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: recipe
              .ingredients()
              .length,
          itemBuilder: (BuildContext context, int index) {
            return makeCard(recipe.ingredients()[index]);
          },
        )
      ],
    );

    final bottomContent = Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[
            bottomContentText,
            ingredientsList,
            MixButton(recipe: this.recipe, channel: this.channel)
          ],
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            // title: Text(recipe.name),
            expandedHeight: 250.0,
            pinned: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: Text(recipe.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    )),
                background: topContent),
          ),
          new SliverList(
              delegate:
              new SliverChildListDelegate([bottomContent])),
        ],
      ),
    );
  }
}
