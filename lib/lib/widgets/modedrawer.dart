import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ledcontrol.dart';
import '../main.dart';
import '../helpers/webscrap.dart';
import '../helpers/loaddata.dart';

class ModeDrawer extends StatefulWidget {
  const ModeDrawer({super.key});

  @override
  State<ModeDrawer> createState() => _ModeDrawerState();
}

class _ModeDrawerState extends State<ModeDrawer> {
  Future<void> _759() async {
    final promotedImage = await WebScrap().search759();
    if (mounted) {
      Navigator.pop(context); // Close drawer after selection
      if (promotedImage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No new promotion')),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text(''),
                  backgroundColor: Colors.transparent,
                ),
                body: InteractiveViewer(
                    child: ListView.builder(
                        itemCount: promotedImage.length,
                        itemBuilder: (context, index) {
                          return Center(
                              child: Image.network(
                            promotedImage[index],
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ));
                        }))),
          ),
        );
      }
    }
  }

  Future<void> _exportList() async {
    final result = await LoadData().exportList();
    if (mounted) {
      Navigator.pop(context); // Close drawer after selection
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book list exported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot find download folder :DD:')),
        );
      }
    }
  }

  Future<void> _importList() async {
    final result = await LoadData().importList();
    if (mounted) {
      Navigator.pop(context); // Close drawer after selection
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book list uploaded successfully!')),
        );
      } else {
        showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text(
                'The uploaded file is in wrong format or cannot receive any file!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> test() async {
    if (!mounted) return;
    Navigator.pop(context); // Close drawer after selection
  }

  @override
  Widget build(BuildContext context) {
    GlobalNotifier modeNotifier = Provider.of<GlobalNotifier>(context);
    return SizedBox(
        width: 200,
        child: Drawer(
          child: Container(
            color: modeNotifier.isReadingMode ? Colors.green : Colors.blue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: const Center(
                      child: Text(
                    '759',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                  onTap: () {
                    _759();
                  },
                ),
                ListTile(
                  title: const Center(
                      child: Text(
                    'Export book list',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                  onTap: () {
                    _exportList();
                  },
                ),
                ListTile(
                  title: const Center(
                      child: Text(
                    'Upload book list',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                  onTap: () {
                    _importList();
                  },
                ),
                ListTile(
                  title: const Center(
                      child: Text(
                    'test',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                  onTap: () {
                    test();
                  },
                ),
                ListTile(
                  title: const Center(
                      child: Text(
                    'LED',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                  onTap: () {
                    if (!mounted) return;
                    Navigator.pop(context); // Close drawer after selection
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                            appBar: AppBar(
                                leading: IconButton(
                                    onPressed: () {
                                      const LedControl().superEscape();
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back,
                                    )),
                                title: const Text(''),
                                backgroundColor: Colors.transparent),
                            body: const LedControl()),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
