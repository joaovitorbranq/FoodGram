import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodlab/model/food.dart';

class FoodNotifier with ChangeNotifier {
  List<Food> _foodList = [];
  List<int> nOfLikesList = [];
  List<bool> isLiked = [];
  List<Color> likeColor = [];
  List<String> likeRef = [];

  UnmodifiableListView<Food> get foodList {
    return UnmodifiableListView(_foodList);
  }

  set foodList(List<Food> foodList) {
    _foodList = foodList;
    notifyListeners();
  }

  void setFood(List<Food> foodList) {
    _foodList = foodList;
    notifyListeners();
  }
}
