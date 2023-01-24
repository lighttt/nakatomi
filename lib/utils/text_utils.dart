import 'package:flutter/material.dart';

/// [TextUtils]
///
/// Utils to determine if given text and font size fits, else reduces the font size
class TextUtils {
  final String bubbleText;
  final double bubbleFontSize;
  final String fontFamily;
  final int maxLines;
  final BuildContext context;
  final BoxConstraints boxConstraintsSize;

  TextUtils(
      {required this.bubbleText,
      required this.boxConstraintsSize,
      required this.bubbleFontSize,
      required this.fontFamily,
      required this.maxLines,
      required this.context});

  /// Each Line Width is based on multiple of default text scale factor and given diagram
  static const double maxLineWidthSmall = 96;
  static const double maxLineWidthMedium = 128;
  static const double maxLineWidthLarge = 192;
  static const double maxLineWidthMax = 256;

  /// Function [calculateFontSize]
  ///
  /// Checks and calculates font size
  ///
  /// If -> Text will be able to fit, return initial font size
  ///
  /// Else -> return new default scaled font size that fits
  List calculateFontSize() {
    // Initialize TextSpan and user scale
    final span = TextSpan(
      style: TextStyle(fontFamily: fontFamily, fontSize: bubbleFontSize),
      text: bubbleText,
    );
    final userScale = MediaQuery.textScaleFactorOf(context);

    // Set min and max fonts for the text
    double minFontSize = 9;
    double maxFontSize = double.infinity;

    // Set Default Scale factor and manage styling
    final defaultTextStyle = DefaultTextStyle.of(context);
    var style = TextStyle(
        fontSize: bubbleFontSize, fontFamily: fontFamily, color: Colors.white);
    if (style.inherit) {
      style = defaultTextStyle.style.merge(style);
    }

    final num defaultFontSize = style.fontSize!.clamp(minFontSize, maxFontSize);
    final defaultScale = defaultFontSize * userScale / style.fontSize!;

    // Check if text fits in the constraint with default scaling
    if (_checkTextFits(span, defaultScale, maxLines, boxConstraintsSize)) {
      return <Object>[defaultFontSize * userScale, true];
    }

    // Handle font size check by two values
    // Left for handling given font size
    // Right for checking default font size
    int left;
    int right;

    // Step size in which font size will be changed to adapt to constraint
    const stepFontSize = 1;
    left = (13 / stepFontSize)
        .floor(); // value set to 13 according to code can be changed to liking
    right = (defaultFontSize / stepFontSize).ceil();

    // Handle if font size is too big to fit into the given constraint
    var lastValueFits = false;
    while (left <= right) {
      final mid = (left + (right - left) / 2).floor();
      double scale;
      scale = mid * userScale * stepFontSize / style.fontSize!;

      if (_checkTextFits(span, scale, maxLines, boxConstraintsSize)) {
        left = mid + 1;
        lastValueFits = true;
      } else {
        right = mid - 1;
      }
    }

    if (!lastValueFits) {
      right += 1;
    }

    // Calculate the scaling and return the font size that will fit
    double fontSize = right * userScale * stepFontSize;

    return <Object>[fontSize, lastValueFits];
  }

  /// Function [_checkTextFits]
  ///
  /// Check if text fits inside the given constraint, returns true/false
  ///
  /// [text] : TextSpam to render
  /// [scale] : Text factor scale for the device
  /// [maxLines] : Get the max lines need to show i.e. 3
  /// [constraints] : Given max/min height or width
  bool _checkTextFits(
      TextSpan text, double scale, int? maxLines, BoxConstraints constraints) {
    final textPainter = TextPainter(
      text: text,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      textScaleFactor: scale,
      maxLines: maxLines,
    );

    textPainter.layout(maxWidth: constraints.maxWidth);

    return !(textPainter.didExceedMaxLines ||
        textPainter.height > constraints.maxHeight ||
        textPainter.width > constraints.maxHeight);
  }
}
