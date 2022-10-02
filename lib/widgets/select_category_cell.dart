import 'package:flutter/material.dart';
import 'package:sisterly/models/category.dart';

class SelectCategoryCell extends StatefulWidget {

  final Category category;
  final bool isSelected;
  final Function onSelected;

  const SelectCategoryCell({Key? key, required this.category, required this.isSelected, required this.onSelected}) : super(key: key);

  @override
  _SelectCategoryCellState createState() => _SelectCategoryCellState();
}

class _SelectCategoryCellState extends State<SelectCategoryCell> {

  bool isSelected = false;

  @override
  void initState() {
    super.initState();

    isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    isSelected = widget.isSelected;

    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });

        if(widget.onSelected != null) {
          widget.onSelected();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, bottom: 15, right: 20),
              child: Text(
                widget.category.category,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 20),
              child: Visibility(
                visible: isSelected,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
