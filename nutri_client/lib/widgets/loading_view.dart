import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingView extends StatefulWidget {
  final Uint8List imageBytes;

  const LoadingView({
    super.key,
    required this.imageBytes,
  });

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<Alignment> _laserAnimation;

  final List<String> _statuses = [
    'Scanning food dish...',
    'Deconstructing macro ratios...',
    'Estimating calorie counts...',
    'Sizing portion boundaries...',
    'Isolating micronutrients...',
    'Running chemical approximations...',
    'Consulting Gemini AI models...',
    'Styling dashboard metrics...',
  ];

  int _currentStatusIndex = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    // 1. Setup infinite looping scanner laser animation
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _laserAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));

    _scanController.repeat();

    // 2. Setup status messages cycling timer
    _statusTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          _currentStatusIndex = (_currentStatusIndex + 1) % _statuses.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Holographic scan card container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The uploaded/captured image
                    Image.memory(
                      widget.imageBytes,
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                    // Translucent sci-fi scanning overlay
                    Container(
                      width: double.infinity,
                      height: 350,
                      color: Colors.black.withOpacity(0.55),
                    ),
                    // Infinite neon laser line
                    AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: Align(
                            alignment: _laserAnimation.value,
                            child: Container(
                              width: double.infinity,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xff10b981).withOpacity(0.2),
                                    const Color(0xff10b981),
                                    const Color(0xff10b981),
                                    const Color(0xff10b981).withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff10b981)
                                        .withOpacity(0.8),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Progress loader spinner
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xff10b981), // Emerald green progress indicator
              ),
            ),
            const SizedBox(height: 24),
            // Cycling descriptive status message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _statuses[_currentStatusIndex],
                key: ValueKey<int>(_currentStatusIndex),
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff1e293b),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Reassuring subtitle
            Text(
              'Gemini AI is examining portion structures...',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xff64748b),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
