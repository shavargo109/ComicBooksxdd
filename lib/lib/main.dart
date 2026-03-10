import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'widgets/homepage.dart';
import 'widgets/modedrawer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GlobalNotifier(),
      child: const MyApp(),
    ),
  );
}

class GlobalNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isReadingMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isReadingMode => _isReadingMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleMode() {
    _isReadingMode ? _isReadingMode = false : _isReadingMode = true;
    notifyListeners();
  }

  void setReadingMode() {
    _isReadingMode = true;
    notifyListeners();
  }

  void setWebsiteMode() {
    _isReadingMode = false;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to both themeMode and isReadingMode to trigger a rebuild for both
    return Selector<GlobalNotifier, Tuple2<ThemeMode, bool>>(
      selector: (_, notifier) =>
          Tuple2(notifier.themeMode, notifier.isReadingMode),
      builder: (context, value, child) {
        final themeNotifier = context.read<GlobalNotifier>();
        return MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: value.item1, // Listen to themeMode directly
          home: Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    color: Colors.white,
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              backgroundColor: value.item2
                  ? Colors.green
                  : Colors.blue, // Updated based on isReadingMode
              actions: [
                IconButton(
                  icon: Icon(
                    value.item2 ? Icons.book : Icons.personal_video,
                    color: Colors.white,
                  ),
                  onPressed: () => themeNotifier.toggleMode(),
                ),
                IconButton(
                  icon: Icon(
                    value.item1 == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.white,
                  ),
                  onPressed: () => themeNotifier.toggleTheme(),
                ),
              ],
            ),
            drawer: const ModeDrawer(), // Custom drawer for mode toggle
            body: HomePage(isReadingMode: value.item2),
          ),
        );
      },
    );
  }
}


