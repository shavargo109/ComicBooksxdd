import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../helpers/webscrap.dart';

// for reading mode
// get the episodelist to display and choose which episode to read
class Episodelist extends StatefulWidget {
  final int colorCode;
  final String episode;
  final String link;
  final String em;

  const Episodelist({
    super.key,
    required this.colorCode,
    required this.episode,
    required this.link,
    required this.em,
  });

  @override
  State<Episodelist> createState() => _EpisodelistState();
}

class _EpisodelistState extends State<Episodelist> with WidgetsBindingObserver {
  final List<Uint8List> _imageData = [];
  Stream<Uint8List>? _imageStream;
  bool _isStreamPaused = false;
  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App is in background, pause the stream
      _isStreamPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      // App is active, resume the stream
      _isStreamPaused = false;
      setState(() {}); // Trigger rebuild to restart the stream
    }
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        //   ..translate(-position.dx * 2, -position.dy * 2)
        //   ..scale(3.0);
        // Fox a 2x zoom
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color? bgColor = isDarkTheme
        ? Colors.blueGrey[widget.colorCode + 800]
        : Colors.amber[widget.colorCode];
    var text =
        widget.em == "new" ? "${widget.episode} ${widget.em}" : widget.episode;

    return SizedBox(
      height: 50,
      child: Material(
        color: bgColor,
        child: InkWell(
          child: Center(
            child: Text(text),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FutureBuilder<Map<String, dynamic>>(
                  future: getEpsiodeImage(widget.link),
                  builder: (context, episodeSnapshot) {
                    if (episodeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (episodeSnapshot.hasError) {
                      return Center(
                          child: Text("Error: ${episodeSnapshot.error}"));
                    } else if (!episodeSnapshot.hasData ||
                        episodeSnapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No episode data found."));
                    } else {
                      final episodeData = episodeSnapshot.data!;
                      _imageStream = getImagedataStream(episodeData);
                      return StreamBuilder<Uint8List>(
                        stream: _isStreamPaused ? null : _imageStream,
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              _imageData.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (imageSnapshot.hasError) {
                            return Center(
                                child: Text("Error: ${imageSnapshot.error}"));
                          } else if (imageSnapshot.hasData) {
                            _imageData
                                .add(imageSnapshot.data!); // Add new image
                          }
                          return GestureDetector(
                            onDoubleTapDown: (d) => _doubleTapDetails = d,
                            onDoubleTap: _handleDoubleTap,
                            child: Center(
                              child: InteractiveViewer(
                                  transformationController:
                                      _transformationController,
                                  child: ListView.builder(
                                      itemCount: _imageData.length,
                                      itemBuilder: (context, index) {
                                        return Center(
                                            child: Image.memory(
                                                _imageData[index]));
                                      })),
                            ),
                          );

                          // return InteractiveViewer(
                          //     minScale: 0.5,
                          //     maxScale: 2.0,
                          //     child: ListView.builder(
                          //         itemCount: _imageData.length,
                          //         itemBuilder: (context, index) {
                          //           return Center(
                          //               child: Image.memory(_imageData[index]));
                          //         }));

                          // return ListView.builder(
                          //   itemCount: _imageData.length,
                          //   itemBuilder: (context, index) {
                          //     return Center(
                          //         child: Image.memory(_imageData[index]));
                          //   },
                          // );
                        },
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
