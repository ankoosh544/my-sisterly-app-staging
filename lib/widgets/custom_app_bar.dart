import 'package:flutter/material.dart';
import 'package:sisterly/utils/constants.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {

  final List<Widget>? actions;
  final Widget? leading;
  final bool forceUpperCase;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double textSize;
  final double elevation;
  final bool automaticallyImplyLeading;

  CustomAppBar({Key? key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.elevation = 2,
    this.iconColor,
    this.textColor,
    this.automaticallyImplyLeading = true,
    this.leading, this.centerTitle = true, this.forceUpperCase = true, this.textSize = 16}) : preferredSize = const Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize;

  final String? title;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>{

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: widget.centerTitle,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      elevation: widget.elevation,
      iconTheme: IconThemeData(
        color: widget.iconColor ?? Constants.TEXT_COLOR,
      ),
      title: Text(
       widget.forceUpperCase && widget.title != null ? widget.title!.toUpperCase() : widget.title!,
        style: Theme.of(context).appBarTheme.textTheme!.bodyText1!.copyWith(
          color: widget.textColor ?? Constants.TEXT_COLOR,
          fontSize: widget.textSize
        ),
      ),
      backgroundColor: widget.backgroundColor ?? Theme.of(context).appBarTheme.color,
      actions: widget.actions,
      leading: widget.leading,
    );
  }
}

