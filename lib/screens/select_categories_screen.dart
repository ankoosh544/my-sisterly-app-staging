import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sisterly/models/category.dart';
import 'package:sisterly/widgets/select_category_cell.dart';
import '../utils/api_manager.dart';
import '../utils/constants.dart' as constants;
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/progress_indicator.dart';

class SelectCategoriesScreen extends StatefulWidget {

  final bool multiple;
  final List<Category> selectedCategory;

  const SelectCategoriesScreen({Key? key, this.multiple: false, required this.selectedCategory}) : super(key: key);

  @override
  _SelectCategoriesScreenState createState() => _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {

  List<Category> categories = <Category>[];
  List<Category> selectedList = <Category>[];
  List<Category> savedSelectedList = <Category>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    debugPrint("initState");

    Timer.run(() {
      loadCategories();
    });
  }

  loadCategories() {
    setState(() {
      isLoading = true;
    });

    ApiManager(context).makeGetRequest('/client/categories', {}, (res) {
      var data = res["data"];

      categories.clear();

      if (data != null) {
        for (var b in data) {
          Category category = Category.fromJson(b);
          categories.add(category);

          if(widget.selectedCategory != null) {
            for (var selected in widget.selectedCategory) {
              if (selected.id == category.id) {
                selectedList.add(category);
                savedSelectedList.add(category);
              }
            }
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    }, (res) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(savedSelectedList);
        return new Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Seleziona categorie"),
          backgroundColor: Constants.PRIMARY_COLOR,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: isLoading ? CustomProgressIndicator() : Container(
                margin: EdgeInsets.only(top: 15),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      debugPrint("itemBuilder "+index.toString()+" SelectCategoriesCell");
                      return SelectCategoryCell(
                        category: categories[index],
                        isSelected: selectedList.contains(categories[index]),
                        onSelected: () {
                          if(widget.multiple) {
                            if (selectedList.contains(categories[index])) {
                              selectedList.remove(categories[index]);
                            } else {
                              selectedList.add(categories[index]);
                            }
                          } else {
                            selectedList.clear();
                            selectedList.add(categories[index]);
                          }

                          setState(() {

                          });
                        },
                      );
                    }
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Constants.SECONDARY_COLOR,
                      textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: Text('Conferma'),
                  onPressed: () {
                    savedSelectedList.clear();
                    savedSelectedList.addAll(selectedList);
                    Navigator.of(context).pop(savedSelectedList);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
