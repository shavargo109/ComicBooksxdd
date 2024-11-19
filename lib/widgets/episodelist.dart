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

class _EpisodelistState extends State<Episodelist> {
  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color? bgColor = isDarkTheme
        ? Colors.blueGrey[widget.colorCode + 800]
        : Colors.amber[widget.colorCode];
    var text =
        widget.em == "new" ? "${widget.episode} ${widget.em}" : widget.episode;
    var imageData = [];
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
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (episodeSnapshot.hasError) {
                            return Center(
                                child: Text("Error: ${episodeSnapshot.error}"));
                          } else if (!episodeSnapshot.hasData ||
                              episodeSnapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("No episode data found."));
                          } else {
                            final episodeData = episodeSnapshot.data!;
                            return StreamBuilder<Uint8List>(
                              stream: getImagedataStream(episodeData),
                              builder: (context, imageSnapshot) {
                                if (imageSnapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !imageSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (imageSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          "Error: ${imageSnapshot.error}"));
                                } else if (!imageSnapshot.hasData) {
                                  return const Center(
                                      child: Text("No images available"));
                                } else {
                                  imageData.add(
                                      imageSnapshot.data!); // Add new image
                                  return ListView.builder(
                                    itemCount: imageData.length,
                                    itemBuilder: (context, index) {
                                      return Center(
                                          child:
                                              Image.memory(imageData[index]));
                                    },
                                  );
                                }
                              },
                            );
                          }
                        },
                      )),
            );
          },
        ),
      ),
    );
  }
}
