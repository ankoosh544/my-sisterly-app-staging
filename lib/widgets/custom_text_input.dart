import 'package:flutter/material.dart';

class CustomTextInput extends StatefulWidget {

  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hintColor;
  final double borderWidth;
  final String? hintText;
  final TextEditingController? controller;
  final bool? obscureText;
  final bool? readOnly;
  final GestureTapCallback onTap;
  final double height;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final double? borderRadius;
  final Widget? icon;
  final Color? iconColor;
  final double iconMarginLeft;
  final IconButton? suffixIcon;
  final int? maxLength;
  final int maxLines;
  final bool showHidePassword;

  const CustomTextInput({Key? key,
    this.textColor,
    this.backgroundColor,
    this.hintText,
    this.controller,
    this.obscureText: false,
    this.borderColor,
    required this.onTap,
    this.readOnly = false,
    this.height = 57,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.borderRadius = 15,
    this.hintColor,
    this.icon,
    this.borderWidth = 1,
    this.iconMarginLeft = 0,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.showHidePassword = false,
    this.iconColor = Colors.black
  }) : super(key: key);

  @override
  _CustomTextInputState createState() => _CustomTextInputState();
}

class _CustomTextInputState extends State<CustomTextInput> {

  bool hidePassword = true;

  getSuffixIcon() {
    if(widget.showHidePassword) {
      return IconButton(
        icon: Icon(
          Icons.remove_red_eye,
          color: widget.iconColor,
        ),
        color: hidePassword ? Theme.of(context).selectedRowColor : Theme.of(context).unselectedWidgetColor,
        onPressed: () {
          debugPrint("on hidePassword");
          setState(() {
            hidePassword = !hidePassword;
          });
        },
      );
    } else {
      return widget.suffixIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        border: widget.borderWidth > 0 ? Border.all(
            width: widget.borderWidth,
            color: widget.borderColor!
        ) : null,
      ),
      padding: EdgeInsets.only(left: widget.iconMarginLeft),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        obscureText: widget.obscureText! && hidePassword,
        controller: widget.controller,
        onTap: widget.onTap,
        readOnly: widget.readOnly!,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.textInputType,
        textInputAction: widget.textInputAction,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
          color: widget.textColor,
        ),
        decoration: InputDecoration(
            suffixIcon: getSuffixIcon(),
            labelText: widget.hintText,
            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(
                color: widget.hintColor ?? Theme.of(context).inputDecorationTheme.hintStyle!.color
            ),
            icon: widget.icon,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              color: widget.hintColor ?? Theme.of(context).inputDecorationTheme.hintStyle!.color
            )
        ),
        cursorColor: Theme.of(context).inputDecorationTheme.labelStyle!.color,
        focusNode: widget.focusNode,
      ),
    );
  }

}