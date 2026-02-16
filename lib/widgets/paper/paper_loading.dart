import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

/// Paper Loading Indicator (Full Screen Overlay)
///
/// Displays a centered circular loading indicator with optional message.
class PaperLoadingIndicator extends StatelessWidget {
  const PaperLoadingIndicator({
    super.key,
    this.barrierColor = Colors.white70,
    this.message,
    this.messagePadding,
  });

  final Color barrierColor;
  final String? message;
  final EdgeInsets? messagePadding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: barrierColor,
      child: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PaperCircularLoading(),
              if (message != null)
                Padding(
                  padding:
                      messagePadding ?? const EdgeInsets.fromLTRB(40, 28, 40, 0),
                  child: Text(
                    message!,
                    style: PaperText.bodyRegular.copyWith(
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show loading as a dialog
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white70,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PaperCircularLoading(),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      message,
                      style: PaperText.bodyRegular.primary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Paper Circular Loading Animation
///
/// Animated circular progress indicator with gradient sweep.
class PaperCircularLoading extends StatefulWidget {
  const PaperCircularLoading({
    super.key,
    this.size = 68,
    this.secondaryColor = Colors.white12,
    this.primaryColor = PaperColor.blue,
    this.lapDuration = 1000,
    this.strokeWidth = 12.0,
  });

  final double size;
  final Color secondaryColor;
  final Color primaryColor;
  final int lapDuration;
  final double strokeWidth;

  @override
  State<PaperCircularLoading> createState() => _PaperCircularLoadingState();
}

class _PaperCircularLoadingState extends State<PaperCircularLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.lapDuration),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(controller),
      child: CustomPaint(
        painter: _WhiteCirclePainter(strokeWidth: widget.strokeWidth),
        foregroundPainter: _CirclePainter(
          secondaryColor: widget.secondaryColor,
          primaryColor: widget.primaryColor,
          strokeWidth: widget.strokeWidth,
        ),
        size: Size(widget.size, widget.size),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter({
    this.secondaryColor = Colors.white24,
    this.primaryColor = Colors.blue,
    this.strokeWidth = 8,
  });

  final Color secondaryColor;
  final Color primaryColor;
  final double strokeWidth;

  double _degreeToRad(double degree) => degree * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerPoint = size.height / 2;

    final Paint paint = Paint()
      ..color = primaryColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          secondaryColor,
          primaryColor.withOpacity(.2),
          primaryColor.withOpacity(.4),
          primaryColor.withOpacity(.6),
          primaryColor.withOpacity(.8),
          primaryColor,
        ],
        tileMode: TileMode.repeated,
        startAngle: _degreeToRad(270),
        endAngle: _degreeToRad(270 + 360.0),
      ).createShader(
        Rect.fromCircle(center: Offset(centerPoint, centerPoint), radius: 0),
      );

    final scapSize = strokeWidth * 1;
    final double scapToDegree = scapSize / centerPoint;

    final double startAngle = _degreeToRad(270) + scapToDegree;
    final double sweepAngle = _degreeToRad(360) - (2 * scapToDegree);

    canvas.drawArc(
      Offset.zero & Size(size.width, size.width),
      startAngle,
      sweepAngle,
      false,
      paint..color = primaryColor,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => true;
}

class _WhiteCirclePainter extends CustomPainter {
  _WhiteCirclePainter({
    this.primaryColor = Colors.white24,
    this.strokeWidth = 15,
  });

  final Color primaryColor;
  final double strokeWidth;

  double _degreeToRad(double degree) => degree * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = primaryColor
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final double startAngle = _degreeToRad(0);
    final double sweepAngle = _degreeToRad(360);

    canvas.drawArc(
      Offset.zero & Size(size.width, size.width),
      startAngle,
      sweepAngle,
      false,
      paint..color = primaryColor,
    );
  }

  @override
  bool shouldRepaint(_WhiteCirclePainter oldDelegate) => true;
}

/// Simple inline loading indicator
class PaperLoadingSpinner extends StatelessWidget {
  const PaperLoadingSpinner({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 3,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? PaperColor.blue,
        ),
      ),
    );
  }
}
