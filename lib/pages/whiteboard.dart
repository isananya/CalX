import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:image_gallery_saver/image_gallery_saver.dart';

typedef OnRedoUndo = void Function(bool isUndoAvailable, bool isRedoAvailable);

class CalculatorWhiteboard extends StatefulWidget {
  @override
  _CalculatorWhiteboardState createState() => _CalculatorWhiteboardState();
}

class _CalculatorWhiteboardState extends State<CalculatorWhiteboard> {
  final WhiteBoardController _whiteBoardController = WhiteBoardController();
  final TextRecognizer _textRecognizer = TextRecognizer();
  String _result = '';
  bool _isErasing = false;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  // Future<void> _generateAnswer(Uint8List imageData) async {
  //   try {
  //     // Dynamically determine size based on actual whiteboard image
  //     final imageSize = Size(400, 400);  // Adjust this based on actual whiteboard size

  //     // Create InputImageMetadata
  //     final inputImage = InputImage.fromBytes(
  //       bytes: imageData,
  //       metadata: InputImageMetadata(
  //         size: imageSize, // Ensure this size matches the whiteboard's size
  //         rotation: InputImageRotation.rotation0deg, // Adjust rotation if necessary
  //         format: InputImageFormat.bgra8888, // Ensure correct format is used for image data
  //         bytesPerRow: imageSize.width.toInt() * 4, // Adjust bytesPerRow based on width
  //       ),
  //     );

  //     // Process the image and extract text using ML Kit TextRecognizer
  //     final recognizedText = await _textRecognizer.processImage(inputImage);
  //     String text = recognizedText.text;

  //     // Update the result with the recognized text
  //     setState(() {
  //       _result = text;
  //     });

  //     // Optionally, you can evaluate the text for expressions (e.g., mathematical calculations)
  //     _result = evalExpression(text).toString();  // Uncomment if you need this feature

  //   } catch (e) {
  //     setState(() {
  //       _result = 'Error: ${e.toString()}';
  //     });
  //   }
  // }



// Save the image to a temporary file and load it via a file path
Future<void> _generateAnswerFromFile(Uint8List imageData) async {
  try {
    // Save image to a temporary directory
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/temp_image.png'; 
    // final path = 'test.png';
    final file = File(path);
    await file.writeAsBytes(imageData);
    final pdirectory = Directory('/storage/emulated/0/Pictures/');
    final path2 = '${pdirectory.path}/temp_image.png'; 
    final file2 = File(path2);
    await file2.writeAsBytes(imageData);
    
    // Verify that the file was written correctly
    print('Saved image path: $path');
    print('Image data size: ${imageData.length}');
    
    // Create InputImage from the file path
    final inputImage = InputImage.fromFilePath(path);
    
    // Process the image and extract text using ML Kit TextRecognizer
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    // Debugging recognized text
    if (recognizedText.text.isEmpty) {
      print('No text was recognized from the image.');
    } else {
      print('Recognized text: ${recognizedText.text}');
    }
    
    // Update the result
    setState(() {
      _result = recognizedText.text.isNotEmpty ? evalExpression(recognizedText.text).toString() : 'No text recognized';
    });
  } catch (e) {
    setState(() {
      _result = 'Error: ${e.toString()}';
    });
    print("Image processing error: $e");
  }
}



  double evalExpression(String expression) {
    List<String> tokens =
        expression.replaceAll(' ', '').split(RegExp(r'(\+|\-|\*|\/)'));
    List<String> operators = expression
        .replaceAll(' ', '')
        .split(RegExp(r'[0-9]+'))
        .where((e) => e.isNotEmpty)
        .toList();

    double result = double.parse(tokens[0]);
    for (int i = 0; i < operators.length; i++) {
      double nextNum = double.parse(tokens[i + 1]);
      switch (operators[i]) {
        case '+':
          result += nextNum;
          break;
        case '-':
          result -= nextNum;
          break;
        case '*':
          result *= nextNum;
          break;
        case '/':
          result /= nextNum;
          break;
      }
    }
    return result;
  }

  // Future<void> _saveImage(Uint8List imageData) async {
  //   try {
  //     final result = await ImageGallerySaver.saveImage(
  //         imageData,
  //         quality: 100,
  //         name: "calculator_whiteboard_${DateTime.now().toIso8601String()}");

  //     if (result['isSuccess']) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Image saved to gallery')),
  //       );
  //     } else {
  //       throw Exception('Failed to save image');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator Whiteboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: WhiteBoard(
              controller: _whiteBoardController,
              backgroundColor: Colors.white,
              // backgroundColor: _isErasing ? Colors.white : Colors.black,
              strokeColor:Colors.black,
              strokeWidth: _isErasing ? 100 : 2,
              isErasing: _isErasing,
              onConvertImage: (imageData) {
                _generateAnswerFromFile(imageData);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Result: $_result', style: TextStyle(fontSize: 18)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isErasing = !_isErasing;
                    
                  });
                },

                child: Text(_isErasing ? 'Draw' : 'Erase'),
              ),
              ElevatedButton(
                onPressed: () => _whiteBoardController.undo(),
                child: Text('Undo'),
              ),
              ElevatedButton(
                onPressed: () => _whiteBoardController.redo(),
                child: Text('Redo'),
              ),
              ElevatedButton(
                onPressed: () => _whiteBoardController.clear(),
                child: Text('Clear'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _whiteBoardController.convertToImage(),
                child: Text('Generate Answer'),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     _whiteBoardController.convertToImage(
              //         format: ui.ImageByteFormat.png);
              //   },
              //   child: Text('Save Image'),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class WhiteBoard extends StatefulWidget {
  final WhiteBoardController? controller;
  final Color backgroundColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool isErasing;
  final ValueChanged<Uint8List>? onConvertImage;
  final OnRedoUndo? onRedoUndo;

  const WhiteBoard({
    Key? key,
    this.controller,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.blue,
    this.strokeWidth = 4,
    this.isErasing = false,
    this.onConvertImage,
    this.onRedoUndo,
  }) : super(key: key);

  @override
  _WhiteBoardState createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard> {
  final _undoHistory = <RedoUndoHistory>[];
  final _redoStack = <RedoUndoHistory>[];
  final _strokes = <_Stroke>[];
  late Size _canvasSize;

  // Future<void> _convertToImage() async {
  //   final recorder = ui.PictureRecorder();
  //   final canvas = Canvas(recorder);
  //   _FreehandPainter(_strokes, widget.backgroundColor)
  //       .paint(canvas, _canvasSize);

  //   final result = await recorder
  //       .endRecording()
  //       .toImage(_canvasSize.width.floor(), _canvasSize.height.floor());

  //   final byteData = await result.toByteData(format: ui.ImageByteFormat.png);
  //   final imageData = byteData!.buffer.asUint8List();

  //   widget.onConvertImage?.call(imageData);
  // }

  Future<void> _convertToImage() async {
    // Capture the size of the whiteboard (canvas)
    final size = _canvasSize; // Ensure this is set properly in your build method

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Paint the strokes onto the canvas
    _FreehandPainter(_strokes, widget.backgroundColor).paint(canvas, size);
    print("sizes:");
    print(size.width);
    print(size.height);
    print(size.width.floor());
    print(size.height.floor());

    // Create an image from the canvas
    final result = await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());

    final byteData = await result.toByteData(format: ui.ImageByteFormat.png);
    final imageData = byteData!.buffer.asUint8List();

    // Call the onConvertImage callback with the entire image
    widget.onConvertImage?.call(imageData);
  }

  @override
  void initState() {
    widget.controller?._delegate = _WhiteBoardControllerDelegate()
      ..saveAsImage = _convertToImage
      ..onUndo = () {
        if (_undoHistory.isEmpty) return false;
        _redoStack.add(_undoHistory.removeLast()..undo());
        widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
        return true;
      }
      ..onRedo = () {
        if (_redoStack.isEmpty) return false;
        _undoHistory.add(_redoStack.removeLast()..redo());
        widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
        return true;
      }
      ..onClear = () {
        if (_strokes.isEmpty) return;
        setState(() {
          final removedStrokes = <_Stroke>[]..addAll(_strokes);
          _undoHistory.add(
            RedoUndoHistory(
              undo: () {
                setState(() => _strokes.addAll(removedStrokes));
              },
              redo: () {
                setState(() => _strokes.clear());
              },
            ),
          );
          _strokes.clear();
          _redoStack.clear();
        });
        widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
      };
    super.initState();
  }

  void _start(double startX, double startY) {
    final newStroke = _Stroke(
      color: widget.strokeColor,
      width: widget.strokeWidth,
      erase: widget.isErasing,
    );
    newStroke.path.moveTo(startX, startY);
    _strokes.add(newStroke);
    _undoHistory.add(
      RedoUndoHistory(
        undo: () {
          setState(() => _strokes.remove(newStroke));
        },
        redo: () {
          setState(() => _strokes.add(newStroke));
        },
      ),
    );
    _redoStack.clear();
    widget.onRedoUndo?.call(_undoHistory.isNotEmpty, _redoStack.isNotEmpty);
  }

  void _add(double x, double y) {
    setState(() {
      _strokes.last.path.lineTo(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _start(details.localPosition.dx, details.localPosition.dy),
      onPanUpdate: (details) => _add(details.localPosition.dx, details.localPosition.dy),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _canvasSize = Size(constraints.maxWidth , constraints.maxHeight);
          // _canvasSize = Size(50, 50);
      
          return CustomPaint(
            painter: _FreehandPainter(_strokes, widget.backgroundColor),
            child: Container(),
          );
        },
      ),
    );
  }
}

class WhiteBoardController {
  late _WhiteBoardControllerDelegate _delegate;

  void convertToImage({ui.ImageByteFormat format = ui.ImageByteFormat.png}) =>
      _delegate.saveAsImage();

  bool undo() => _delegate.onUndo();

  bool redo() => _delegate.onRedo();

  void clear() => _delegate.onClear();
}

class _WhiteBoardControllerDelegate {
  late Future<void> Function() saveAsImage;
  late bool Function() onUndo;
  late bool Function() onRedo;
  late VoidCallback onClear;
}

class _Stroke {
  final path = Path();
  final Color color;
  final double width;
  final bool erase;

  _Stroke({
    // this.color = const ui.Color.fromARGB(255, 255, 255, 255),
    this.color = Colors.brown,
    this.width = 4,
    this.erase = false,
  });
}

class RedoUndoHistory {
  final VoidCallback undo;
  final VoidCallback redo;

  RedoUndoHistory({
    required this.undo,
    required this.redo,
  });
}

class _FreehandPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final Color backgroundColor;

  _FreehandPainter(this.strokes, this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.erase ? Colors.white : stroke.color
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..blendMode = stroke.erase ? BlendMode.srcOver : BlendMode.clear;

      canvas.drawPath(stroke.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
