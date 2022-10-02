import 'package:flutter/material.dart';

enum CustomButtonType { defaultButton, continueButton, signIn }

enum CustomButtonStyle { black, whiteOutline, white }

class CustomAppleSignInButton extends StatefulWidget {

  final VoidCallback onPressed;
  final CustomButtonType type;
  final CustomButtonStyle style;
  final double cornerRadius;
  final bool onlyIcon;

  const CustomAppleSignInButton({
    required this.onPressed,
    this.type = CustomButtonType.defaultButton,
    this.style = CustomButtonStyle.white,
    this.cornerRadius = 6,
    this.onlyIcon: false,
  })  : assert(type != null),
        assert(style != null),
        assert(cornerRadius != null);

  @override
  State<StatefulWidget> createState() => _CustomAppleSignInButtonState();
}

class _CustomAppleSignInButtonState extends State<CustomAppleSignInButton> {
  bool _isTapDown = false;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.style == CustomButtonStyle.black ? Colors.black : Colors.white;
    final textColor =
        widget.style == CustomButtonStyle.black ? Colors.white : Colors.black;
    final borderColor =
        widget.style == CustomButtonStyle.white ? Colors.white : Colors.black;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapDown = true),
      onTapUp: (_) {
        setState(() => _isTapDown = false);
        widget?.onPressed();
      },
      onTapCancel: () => setState(() => _isTapDown = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        constraints: BoxConstraints(
          minHeight: 32,
          maxHeight: 64,
          minWidth: 200,
        ),
        height: 50,
        decoration: BoxDecoration(
          color: _isTapDown ? Colors.grey : bgColor,
          borderRadius: BorderRadius.all(
            Radius.circular(widget.cornerRadius),
          ),
          border: Border.all(width: .7, color: borderColor),
        ),
        child: Center(
            child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 1, left: 2, right: 10),
              child: SizedBox(
                height: 18,
                child: AspectRatio(
                  aspectRatio: 25 / 31,
                  child: CustomPaint(
                    painter: _AppleLogoPainter(color: textColor),
                  ),
                ),
              ),
            ),
            !widget.onlyIcon ? Text(
              "Continua con Apple",
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ) : SizedBox(),
          ],
        )),
      ),
    );
  }
}

class _AppleLogoPainter extends CustomPainter {
  final Color color;

  _AppleLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawPath(_getApplePath(size.width, size.height), paint);
  }

  static Path _getApplePath(double w, double h) {
    return Path()
      ..moveTo(w * .50779, h * .28732)
      ..cubicTo(
          w * .4593, h * .28732, w * .38424, h * .24241, w * .30519, h * .24404)
      ..cubicTo(
          w * .2009, h * .24512, w * .10525, h * .29328, w * .05145, h * .36957)
      ..cubicTo(w * -.05683, h * .5227, w * .02355, h * .74888, w * .12916,
          h * .87333)
      ..cubicTo(w * .18097, h * .93394, w * .24209, h * 1.00211, w * .32313,
          h * .99995)
      ..cubicTo(w * .40084, h * .99724, w * .43007, h * .95883, w * .52439,
          h * .95883)
      ..cubicTo(w * .61805, h * .95883, w * .64462, h * .99995, w * .72699,
          h * .99833)
      ..cubicTo(
          w * .81069, h * .99724, w * .86383, h * .93664, w * .91498, h * .8755)
      ..cubicTo(
          w * .97409, h * .80515, w * .99867, h * .73698, w * 1, h * .73319)
      ..cubicTo(w * .99801, h * .73265, w * .83726, h * .68233, w * .83526,
          h * .53082)
      ..cubicTo(
          w * .83394, h * .4042, w * .96214, h * .3436, w * .96812, h * .34089)
      ..cubicTo(
          w * .89505, h * .25378, w * .78279, h * .24404, w * .7436, h * .24187)
      ..cubicTo(
          w * .6413, h * .23538, w * .55561, h * .28732, w * .50779, h * .28732)
      ..close()
      ..moveTo(w * .68049, h * .15962)
      ..cubicTo(w * .72367, h * .11742, w * .75223, h * .05844, w * .74426, 0)
      ..cubicTo(w * .68249, h * .00216, w * .60809, h * .03355, w * .56359,
          h * .07575)
      ..cubicTo(w * .52373, h * .11309, w * .48919, h * .17315, w * .49849,
          h * .23051)
      ..cubicTo(w * .56691, h * .23484, w * .63732, h * .20183, w * .68049,
          h * .15962)
      ..close();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
