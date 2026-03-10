import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class LedControl extends StatefulWidget {
  const LedControl({super.key});

  @override
  State<LedControl> createState() => _LedControlState();
  Future<void> superEscape() async {
    print('called');
    final url = Uri.http('192.168.1.41:5000', '/ledcommand');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Function": 'off',
          "Color": 'BLACK',
          "Pattern": 'none',
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Server Result: ${data['output']}");
      }
    } catch (e) {
      print("Error calling command: $e");
    }
  }
}

class _LedControlState extends State<LedControl> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionTest(isInitial: true);
    });
  }

  String _selectedFunction = 'static';
  String _brightness = '';
  String? _coloritem;
  String? _patternitem;
  bool isBreathing = false;
  final List<String> _colorOption = [
    'RED',
    'PINK',
    'BLUE',
    'GREEN',
    'PURPLE',
    'YELLOW',
    'ORANGE',
    'BLACK',
    'WHITE',
    'RAINBOW',
  ];
  final List<String> _patternOption = [
    'heart',
    'test',
    'test12',
    'focus',
  ];

  Future<bool> _connectionTest({bool isInitial = false}) async {
    if (mounted) {
      _showLoadingPopup(context);
    }
    try {
      final response = await http.get(
        Uri.http('192.168.1.41:5000', '/initial'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Connection test: ${data['output']}");
        Navigator.of(context).pop();
        if (mounted && isInitial) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Online!',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.greenAccent,
            ),
          );
        }
      }
    } catch (e) {
      print("Error fetching initial data: $e");
      if (mounted) {
        Navigator.of(context).pop();
        showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text(
              'Please check the connection with the server',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
        return false;
      }
    }
    return true;
  }

  void _showLoadingPopup(BuildContext context) {
    showDialog(
      context: context,
      // barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text("Connecting to server..."),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLed() async {
    if (_coloritem == null ||
        _patternitem == null ||
        _brightness.isEmpty ||
        double.tryParse(_brightness) == null ||
        double.parse(_brightness) < 0.0 ||
        double.parse(_brightness) > 1.0) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content:
              const Text('Please fill in all the fields with valid values'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }
    bool isConnected = await _connectionTest();
    if (!isConnected) {
      return;
    }
    final url = Uri.http('192.168.1.41:5000', '/ledcommand');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Function": _selectedFunction,
          "Color": _coloritem,
          "Pattern": _patternitem,
          "Brightness": _brightness,
          "Breathing": isBreathing ? 'True' : 'False',
        }), // this is the data
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Server Result: ${data['output']}");
      }
    } catch (e) {
      print("Error calling command: $e");
    }
  }

  Future<void> _ledoff() async {
    bool isConnected = await _connectionTest();
    if (!isConnected) {
      return;
    }
    final url = Uri.http('192.168.1.41:5000', '/ledcommand');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Function": 'off',
          "Color": 'BLACK',
          "Pattern": 'none',
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Server Result: ${data['output']}");
      }
    } catch (e) {
      print("Error calling command: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return const Color.fromARGB(255, 219, 94, 241);
      }
      return Colors.deepPurple;
    }

    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
                value: 'static',
                label: Text('Static'),
                icon: Icon(Icons.image)),
            ButtonSegment(
                value: 'animate',
                label: Text('Animate'),
                icon: Icon(Icons.smart_display)),
          ],
          selected: {_selectedFunction},
          onSelectionChanged: (val) =>
              setState(() => _selectedFunction = val.first),
        ),
        const SizedBox(height: 24),
        DropdownMenu<String>(
          width: MediaQuery.of(context).size.width * 0.8,
          label: const Text('Color Options'),
          initialSelection: _coloritem,
          onSelected: (String? value) {
            setState(() => _coloritem = value);
          },
          dropdownMenuEntries: _colorOption.map((option) {
            return DropdownMenuEntry<String>(value: option, label: option);
          }).toList(),
        ),
        const SizedBox(height: 32),
        DropdownMenu<String>(
          width: MediaQuery.of(context).size.width * 0.8,
          label: const Text('Pattern Options'),
          initialSelection: _patternitem,
          onSelected: (String? value) {
            setState(() => _patternitem = value);
          },
          dropdownMenuEntries: _patternOption.map((option) {
            return DropdownMenuEntry<String>(value: option, label: option);
          }).toList(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Brightness (0.0-1.0)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]'))
            ],
            onChanged: (value) {
              setState(() {
                _brightness = value;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith(getColor),
              value: isBreathing,
              onChanged: (bool? value) {
                setState(() {
                  isBreathing = value!;
                });
              },
            ),
            const Text('Breathing Effect',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _toggleLed,
              icon: const Icon(Icons.send),
              label: const Text('Enter'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 50),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: _ledoff,
              icon: const Icon(Icons.flashlight_off),
              label: const Text('LED off'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 50),
              ),
            ),
          ],
        )
      ],
    ));
  }
}
