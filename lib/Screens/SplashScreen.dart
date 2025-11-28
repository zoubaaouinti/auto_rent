import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'LoginScreen.dart';


class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _glitchController;
  bool _showGlitch = false;
  late Timer _glitchTimer;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize video controller
    _videoController = VideoPlayerController.asset('assets/images/splash.mp4')
      ..setLooping(true) // Loop video
      ..setVolume(0.0) // Mute audio
      ..initialize().then((_) {
        setState(() {});
        _videoController.play(); // Start playing
      });

    // ✅ Initialize glitch animation
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startIntermittentGlitch();

    // ✅ Delay before navigating to next screen
    Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signup');
    });
  }


  void _startIntermittentGlitch() {
    _glitchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _showGlitch = true;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showGlitch = false;
            });
          }
        });

        _glitchController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _glitchTimer.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Play the MP4 version of the GIF
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? VideoPlayer(_videoController)
                : Container(color: Colors.black),
          ),

          // ✅ Background blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Container(
                color: Colors.black.withAlpha((0.2 * 255).toInt()),
              ),
            ),
          ),

          // ✅ Centered content (Logo + Glitch Effect)
          Center(
            child: Column(
              children: [
                const Spacer(),
                const SizedBox(height: 30),
                AnimatedBuilder(
                  animation: _glitchController,
                  builder: (context, child) {
                    final random = Random();
                    double dx =
                    _showGlitch ? random.nextDouble() * 0.5 - 0.25 : 0;
                    double dy =
                    _showGlitch ? random.nextDouble() * 0.5 - 0.25 : 0;

                    return Stack(
                      children: [
                        // Base logo
                        Image.asset(
                          'assets/images/logo.png',
                          width: 250,
                          height: 250,
                        ),

                        // Red glitch effect
                        if (_showGlitch)
                          Transform.translate(
                            offset: Offset(dx, dy),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.red.withAlpha((0.2 * 255).toInt()),
                                    Colors.transparent
                                  ],
                                  stops: const [0.4, 0.6],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 250,
                                height: 250,
                              ),
                            ),
                          ),

                        // Blue glitch effect
                        if (_showGlitch)
                          Transform.translate(
                            offset: Offset(-dx, -dy),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.blue.withAlpha((0.2 * 255).toInt()),
                                    Colors.transparent
                                  ],
                                  stops: const [0.4, 0.6],
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topLeft,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 250,
                                height: 250,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}