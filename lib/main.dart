import 'package:flutter/material.dart';
import 'utils/text_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: ChatBubble(
              text:
                  'Lorem ipsum dolor sit amet, id ignota omnium vel. Ne has idque movet, exhgcffxgfx aasd',
              bubbleFontSize: 13,
              font: '')),
    );
  }
}

/// [ChatBubble] : Create a chat bubble based on text, fontSize and font
class ChatBubble extends StatelessWidget {
  final String text;
  final double bubbleFontSize;
  final String font;

  const ChatBubble(
      {Key? key,
      required this.text,
      required this.bubbleFontSize,
      required this.font})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleSize = _calculateBubbleSize(context);
    return Container(
      height: bubbleSize['height'],
      constraints: BoxConstraints(maxWidth: bubbleSize['width'] + 2),
      child: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints size) {
          // Create utils and handle font size
          final utils = TextUtils(
            fontFamily: font,
            bubbleFontSize: bubbleFontSize,
            maxLines: 3,
            bubbleText: text,
            context: context,
            boxConstraintsSize: size,
          );
          const maxLines = 3;
          final result = utils.calculateFontSize();
          final fontSize = result[0] as double;

          return Container(
              margin: const EdgeInsets.only(
                top: 0,
                left: 4.0,
              ),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(
                            child: Text(
                              "AUTHOR",
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              style:
                                  TextStyle(fontSize: 9, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      text,
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1,
                      maxLines: maxLines,
                    )
                  ]));
        },
      ),
    );
  }

  /// Function [_calculateBubbleSize]
  ///
  /// Handles dynamic height and width calculation of the chat bubble
  /// Returns map with height and width
  Map<String, dynamic> _calculateBubbleSize(BuildContext context) {
    // Use TextPainter to create a paint that will know
    // the size height and width of the text that will be added
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: bubbleFontSize, fontFamily: font),
      ),
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );

    // Set the layout with max width as infinite and min as 0
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );

    // Initialize base height and width as per the given diagram values
    double width = 72;
    double height = 72;

    // Find the lines consumed by the text within a base height
    final countLines = (textPainter.size.width / width).ceil();

    // The height given by the painter will only count the text height
    // and not the actual height consumed within a given/varying width
    final actualHeight = countLines * textPainter.size.height;

    // With the given constraints of 72x72, 90x90 and 90x198
    // Handle by checking width got from painter

    // First Stage
    if (textPainter.size.width < TextUtils.maxLineWidthSmall) {
      height = 72;
      width = 72;
    }
    // Handle Intermediate State 1
    else if (textPainter.size.width < TextUtils.maxLineWidthMedium) {
      height = 72;
      width = actualHeight * (textPainter.width / actualHeight);
    }
    // Handle Last Stage
    else if (textPainter.size.width < TextUtils.maxLineWidthLarge) {
      height = 90;
      width = 90;
    }
    // Handle Intermedia State 2
    else if (textPainter.size.width > TextUtils.maxLineWidthLarge &&
        textPainter.size.width < TextUtils.maxLineWidthMax) {
      height = 90;
      width = actualHeight * 2;
    }
    // Final Base Value
    else {
      height = 90;
      width = 198;
    }

    return {'height': height, 'width': width};
  }
}
