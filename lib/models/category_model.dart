import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(
      CategoryModel(
        name: 'Smartphone',
        iconPath: 'assets/icons/phone.svg',
        boxColor: Color(0xff92A3FD)
      )
    );

    categories.add(
      CategoryModel(
        name: 'Charger',
        iconPath: 'assets/icons/charger.svg',
        boxColor: Color(0xffC58BF2)
      )
    );
    categories.add(
      CategoryModel(
        name: 'Water Bottle',
        iconPath: 'assets/icons/water-bottle.svg',
        boxColor: Color(0xff92A3FD)
      )
    );
    categories.add(
      CategoryModel(
        name: 'Others',
        iconPath: 'assets/icons/dots.svg',
        boxColor: Color(0xffC58BF2)
      )
    );
    return categories;
  }
}