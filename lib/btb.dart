import 'package:flutter/material.dart';
import 'dart:async';

// ignore: use_key_in_widget_constructors
class CallScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isCalling = false;
  Timer? _timer;
  double _buttonPosition = 0.0;
  final double _sliderWidth = 250.0;
  final double _buttonWidth = 60.0;
  late Animation<double> _returnAnimation;
  late AnimationController _returnController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);

    _returnController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _returnAnimation = Tween<double>(begin: _buttonPosition, end: 0.0)
        .animate(_returnController)
      ..addListener(() {
        setState(() {
          _buttonPosition = _returnAnimation.value;
        });
      });
  }

  void _startCall() {
    setState(() {
      _isCalling = true;
    });
    _timer = Timer(const Duration(seconds: 30), () {
      _stopCall();
    });
    _buttonPosition = 0.0;
    _moveButton();
  }

  void _moveButton() {
    if (!_isCalling) return;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isCalling) {
        timer.cancel();
        return;
      }

      setState(() {
        _buttonPosition += 2;
        if (_buttonPosition >= _sliderWidth - _buttonWidth) {
          _buttonPosition = 0;
        }
      });
    });
  }

  void _stopCall() {
    setState(() {
      _isCalling = false;
    });
    _timer?.cancel();
    _controller.stop();

    // Retourner le bouton à la position initiale...
    _returnController.forward(from: 0.0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCalling) {
      double newPosition = _buttonPosition + details.delta.dx;

      // Garde le bouton dans les limites du slider..
      if (newPosition < 0) {
        newPosition = 0;
      } else if (newPosition > _sliderWidth - _buttonWidth) {
        newPosition = _sliderWidth - _buttonWidth;
      }

      setState(() {
        _buttonPosition = newPosition;

        // Arrêter l'animation du bouton lorsqu'il glisse..
        if (details.delta.dx != 0) {
          _controller.stop();
        } else {
          _moveButton();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _returnController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(''),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sweet Mummy',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Appel entrant',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 50),
              Opacity(
                opacity: 0.4,
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 80),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: _sliderWidth,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onPanUpdate: _onPanUpdate,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 50),
                          transform:
                              Matrix4.translationValues(_buttonPosition, 0, 0),
                          child: Container(
                            width: _buttonWidth,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Icon(Icons.call,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 150,
            right: 20,
            child: ScaleTransition(
              scale: _controller.drive(Tween<double>(begin: 1, end: 1.1)),
              child: ElevatedButton(
                onPressed: _isCalling ? _stopCall : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child:
                    const Icon(Icons.call_end, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: ElevatedButton(
              onPressed: _startCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text('Démarrer l\'appel',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
