import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/foldable_layout.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= FoldableLayout.expandedBreakpoint;
        final isMainScreen = constraints.maxWidth >= FoldableLayout.compactBreakpoint;
        final isTabletop = FoldableUtils.isTabletopPosture(context);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isWide ? 900 : 560),
              padding: EdgeInsets.symmetric(
                horizontal: isMainScreen ? 32 : 20,
                vertical: isMainScreen ? 32 : 20,
              ),
              child: isWide && !isTabletop
                  ? _buildWideScanLayout(context)
                  : _buildStandardScanLayout(context, isMainScreen),
            ),
          ),
        );
      },
    );
  }

  // Dual column wide presentation for landscape / expanded unfolded screens
  Widget _buildWideScanLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: _buildHolographicCard(height: 320),
        ),
        const SizedBox(width: 36),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressSpinner(),
              const SizedBox(height: 24),
              _buildStatusTitle(),
              const SizedBox(height: 10),
              _buildStatusSubtitle(),
              const SizedBox(height: 24),
              _buildAnalysisStepsList(),
            ],
          ),
        ),
      ],
    );
  }

  // Standard vertical stack (Adaptive for Cover Screen & Main Screen portrait)
  Widget _buildStandardScanLayout(BuildContext context, bool isMainScreen) {
    final imageHeight = isMainScreen ? 300.0 : 220.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHolographicCard(height: imageHeight),
        SizedBox(height: isMainScreen ? 32 : 20),
        _buildProgressSpinner(),
        const SizedBox(height: 16),
        _buildStatusTitle(),
        const SizedBox(height: 6),
        _buildStatusSubtitle(),
      ],
    );
  }

  Widget _buildHolographicCard({required double height}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
            Image.memory(
              widget.imageBytes,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: height,
              color: Colors.black.withValues(alpha: 0.55),
            ),
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
                            const Color(0xff10b981).withValues(alpha: 0.2),
                            const Color(0xff10b981),
                            const Color(0xff10b981),
                            const Color(0xff10b981).withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff10b981).withValues(alpha: 0.8),
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
    );
  }

  Widget _buildProgressSpinner() {
    return const SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: Color(0xff10b981),
      ),
    );
  }

  Widget _buildStatusTitle() {
    return AnimatedSwitcher(
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
    );
  }

  Widget _buildStatusSubtitle() {
    return Text(
      'Gemini AI is examining dish nutrition structures...',
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: const Color(0xff64748b),
      ),
    );
  }

  Widget _buildAnalysisStepsList() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        children: [
          _buildMiniStep('Vision Analysis', isComplete: true),
          const SizedBox(height: 8),
          _buildMiniStep('Macro Estimation', isComplete: _currentStatusIndex >= 1),
          const SizedBox(height: 8),
          _buildMiniStep('Micronutrient Mapping', isComplete: _currentStatusIndex >= 4),
        ],
      ),
    );
  }

  Widget _buildMiniStep(String title, {required bool isComplete}) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 16,
          color: isComplete ? const Color(0xff10b981) : const Color(0xff94a3b8),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
            color: isComplete ? const Color(0xff1e293b) : const Color(0xff64748b),
          ),
        ),
      ],
    );
  }
}
