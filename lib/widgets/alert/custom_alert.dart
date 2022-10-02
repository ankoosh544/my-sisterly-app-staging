import 'package:flutter/material.dart';
import 'package:sisterly/utils/constants.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';

import 'src/cancel.dart';
import 'src/confirm.dart';
import 'src/success.dart';

/// Return false to keey dialog showing
typedef bool CustomAlertOnPress(bool isConfirm);

enum CustomAlertStyle { success, error, confirm, loading }

class CustomAlertOptions {
  final String? title;
  final String? subtitle;

  final CustomAlertOnPress? onPress;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final bool showCancelButton;

  final CustomAlertStyle? style;

  CustomAlertOptions(
      {this.showCancelButton: false,
      this.title,
      this.subtitle,
      this.onPress,
      this.cancelButtonColor,
      this.cancelButtonText,
      this.confirmButtonColor,
      this.confirmButtonText,
      this.style});
}

class CustomAlertDialog extends StatefulWidget {

  final Curve curve;
  final CustomAlertOptions options;

  CustomAlertDialog({
    required this.options,
    required this.curve,
  }) : assert(options != null);

  @override
  State<StatefulWidget> createState() {
    return CustomAlertDialogState();
  }
}

class CustomAlertDialogState extends State<CustomAlertDialog> with SingleTickerProviderStateMixin, CustomAlert {

  late AnimationController controller;
  late Animation<double> tween;
  late CustomAlertOptions _options;

  @override
  void initState() {
    _options = widget.options;
    controller = AnimationController(vsync: this);
    tween = Tween(begin: 0.0, end: 1.0).animate(controller);
    controller.animateTo(1.0,
        duration: const Duration(milliseconds: 150),
        curve: widget.curve);

    CustomAlert._state = this;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    CustomAlert._state = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomAlertDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void confirm() {
    if (_options.onPress != null && _options.onPress!(true) == false) {
      return;
    }
    Navigator.pop(context);
  }



  void cancel() {
    if (_options.onPress != null && _options.onPress!(false) == false) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listOfChildren = [];

    switch (_options.style) {
      case CustomAlertStyle.success:
        listOfChildren.add(SizedBox(
          width: 64.0,
          height: 64.0,
          child: SuccessView(),
        ));
        break;
      case CustomAlertStyle.confirm:
        listOfChildren.add(SizedBox(
          width: 64.0,
          height: 64.0,
          child: ConfirmView(),
        ));
        break;
      case CustomAlertStyle.error:
        listOfChildren.add(SizedBox(
          width: 64.0,
          height: 64.0,
          child: CancelView(),
        ));
        break;
      case CustomAlertStyle.loading:
        listOfChildren.add(const SizedBox(
          width: 64.0,
          height: 64.0,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ));
        break;
    }

    listOfChildren.add(const SizedBox(height: 10,));

    if (_options.title != null) {
      listOfChildren.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _options.title!,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Color(0xff575757), fontFamily: Constants.FONT),
          textAlign: TextAlign.center,
        ),
      ));
    }

    if (_options.subtitle != null) {
      listOfChildren.add(Padding(
        padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        child: Text(
          _options.subtitle!,
          style: TextStyle(fontSize: 16.0, color: Color(0xff797979), fontFamily: Constants.FONT),
          textAlign: TextAlign.center,
        ),
      ));
    }

    //we do not render buttons when style=loading
    if (_options.style != CustomAlertStyle.loading) {
      if (_options.showCancelButton) {
        listOfChildren.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  onPressed: cancel,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                  color: _options.cancelButtonColor ?? CustomAlert.cancel,
                  child: Text(
                    _options.cancelButtonText ?? CustomAlert.cancelText,
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: RaisedButton(
                  padding: EdgeInsets.zero,
                  onPressed: confirm,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                  color: _options.confirmButtonColor ?? CustomAlert.danger,
                  child: Text(
                    _options.confirmButtonText ?? CustomAlert.confirmText,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ));
      } else {
        listOfChildren.add(Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: RaisedButton(
            onPressed: confirm,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60.0),
            ),
            color: _options.confirmButtonColor ?? CustomAlert.success,
            child: Text(
              _options.confirmButtonText ?? CustomAlert.successText,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
        ));
      }
    }

    return Center(
        child: AnimatedBuilder(
            animation: controller,
            builder: (c, w) {
              return ScaleTransition(
                scale: tween,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listOfChildren,
                        ),
                      )),
                ),
              );
            }));
  }

  void update(CustomAlertOptions options) {
    setState(() {
      _options = options;
    });
  }
}

abstract class CustomAlert {
  static Color success = Colors.green;
  static Color danger = Color(0xffDD6B55);
  static Color cancel = Color(0xffD0D0D0);

  static String successText = "OK";
  static String confirmText = "Conferma";
  static String cancelText = "Annulla";

  static Curve showCurve = Curves.easeIn;

  static CustomAlertDialogState? _state;

  static void show(BuildContext context,
      {Curve curve = Curves.easeIn,
      String? title,
      String? subtitle,
      bool showCancelButton = false,
        CustomAlertOnPress? onPress,
      Color? cancelButtonColor,
      Color? confirmButtonColor,
      String? cancelButtonText,
      String? confirmButtonText,
        CustomAlertStyle? style}) {
    confirmText = AppLocalizations.of(context).translate("generic_confirm");
    cancelText = AppLocalizations.of(context).translate("generic_cancel");

    CustomAlertOptions options =  CustomAlertOptions(
        showCancelButton: showCancelButton,
        title: title,
        subtitle: subtitle,
        style: style,
        onPress: onPress,
        confirmButtonColor: confirmButtonColor,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        cancelButtonColor: cancelButtonColor);
    if(_state!=null){
      _state!.update(options);
    }else{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Container(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: CustomAlertDialog(
                      curve: curve,
                      options:options
                  ),
                ),
              ),
            );
          });
    }

  }
}
