class Ingredient {
  final String name;
  final int amount;

  Ingredient(this.name, this.amount);

  factory Ingredient.fromJson(dynamic json) {
    return Ingredient(json['name'] as String, json['amount'] as int);
  }

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'amount': this.amount,
      };
}

class Step {
  final List<Ingredient> ingredients;

  Step(this.ingredients);

  factory Step.fromJson(dynamic json) {
    var jsonIngredients = json['ingredients'] as List;
    List<Ingredient> ingredients = [];
    jsonIngredients.forEach((element) {
      ingredients.add(Ingredient.fromJson(element));
    });
    return Step(ingredients);
  }

  Map<String, dynamic> toJson() => {
        'ingredients': ingredients,
      };
}

class Recipe {
  final String name;
  final String intro;
  final String description;
  final String pre;
  final String post;
  final String glass;
  final List<Step> steps;

  Recipe(this.name, this.intro, this.description, this.pre, this.post,
      this.glass, this.steps);

  factory Recipe.fromJson(dynamic json) {
    var jsonSteps = json['steps'] as List;
    List<Step> steps = [];
    jsonSteps.forEach((element) {
      steps.add(Step.fromJson(element));
    });
    return Recipe(
        json['name'] as String,
        json['intro'] as String,
        json['description'] as String,
        json['pre'] as String,
        json['post'] as String,
        json['glass'] as String,
        steps);
  }

  // Sum up the volume of all ingredients
  ingredients() {
    return this.steps.fold(
        new List<Ingredient>(), (list, current) => list + current.ingredients);
  }

  // Sum up the volume of all ingredients
  volume() {
    return this.steps.fold(
        0,
        (previous, current) =>
            previous +
            current.ingredients
                .fold(0, (previous, current) => previous + current.amount));
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'steps': steps,
      };
}
