import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoriesLogo extends StatelessWidget {
  /// The width of the complete logo.
  final double width;

  /// Logo color.
  final Color color;

  const StoriesLogo({
    super.key,
    this.width = 350,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // ORIGINAL DESIGN SIZE
    //
    // Your original logo was designed around 350px width.
    // We use that as our reference size and scale everything
    // proportionally from it.
    // ---------------------------------------------------------

    const originalWidth = 350.0;

    final scale = width / originalWidth;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: 50 * scale,
            child: CustomPaint(
              painter: StoriesPainter(
                color: color,
                scale: scale,
              ),
            ),
          ),

          SizedBox(
            height: 2.8 * scale,
          ),

          Text(
            'BY PARIN',
            style: GoogleFonts.playfairDisplay(
              color: color,
              fontSize: 20 * scale,
              fontWeight: FontWeight.w400,
              letterSpacing: 20 * scale,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}


class StoriesPainter extends CustomPainter {
  final Color color;

  /// Scale applied to the original logo design.
  final double scale;

  StoriesPainter({
    required this.color,
    required this.scale,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    // ---------------------------------------------------------
    // STORIES TEXT
    //
    // Every value here comes from the original logo.
    // We multiply it by scale so the visual proportions
    // remain exactly the same at every size.
    // ---------------------------------------------------------

    final style = GoogleFonts.playfairDisplay(
      color: color,
      fontSize: 58 * scale,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5 * scale,
      height: 1,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: 'STORIES',
        style: style,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    painter.layout(
      maxWidth: size.width,
    );

    final x = (size.width - painter.width) / 2;

    // ---------------------------------------------------------
    // CUT POSITION
    // ---------------------------------------------------------

    final cutY = 51 * scale;

    // ---------------------------------------------------------
    // TEXT + REAL TRANSPARENT CUT
    // ---------------------------------------------------------

    canvas.saveLayer(
      Offset.zero & size,
      Paint(),
    );

    painter.paint(
      canvas,
      Offset(x, 0),
    );

    // This removes the pixels from the text.
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        cutY - (18 * scale),
        size.width,
        4 * scale,
      ),
      clearPaint,
    );

    canvas.restore();

    // ---------------------------------------------------------
    // THIN LINE
    // ---------------------------------------------------------

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 0.7 * scale;

    canvas.drawLine(
      Offset(
        size.width - (294 * scale),
        cutY,
      ),
      Offset(
        size.width - (58 * scale),
        cutY,
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant StoriesPainter oldDelegate,
      ) {
    return oldDelegate.color != color ||
        oldDelegate.scale != scale;
  }
}