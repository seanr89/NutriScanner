import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/foldable_layout.dart';

class UploadZone extends StatefulWidget {
  final Function(Uint8List bytes, String mimeType, String fileName)
      onPhotoSelected;

  const UploadZone({super.key, required this.onPhotoSelected});

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone> {
  bool _isHovered = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();

        // Resolve MIME type from extension if missing
        String mimeType = image.mimeType ?? '';
        if (mimeType.isEmpty) {
          final ext = image.name.split('.').last.toLowerCase();
          if (ext == 'png') {
            mimeType = 'image/png';
          } else if (ext == 'gif') {
            mimeType = 'image/gif';
          } else if (ext == 'webp') {
            mimeType = 'image/webp';
          } else {
            mimeType = 'image/jpeg';
          }
        }

        widget.onPhotoSelected(bytes, mimeType, image.name);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 500),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xffe2e8f0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'Select Photo Source',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1e293b),
                  ),
                ),
                const SizedBox(height: 24),
                // Camera Button
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xffcbd5e1).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xffecfdf5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Color(0xff10b981),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Take Photo',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff0f172a),
                                ),
                              ),
                              Text(
                                'Use your camera to snap a food photo',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xff64748b),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: Color(0xff94a3b8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Gallery Button
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xffcbd5e1).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xffeff6ff),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: Color(0xff3b82f6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose from Gallery',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff0f172a),
                                ),
                              ),
                              Text(
                                'Upload an existing photo from your gallery',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xff64748b),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: Color(0xff94a3b8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMainScreen = constraints.maxWidth >= FoldableLayout.compactBreakpoint;
        final isWideLandscape = constraints.maxWidth >= FoldableLayout.expandedBreakpoint;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              padding: EdgeInsets.symmetric(
                horizontal: isMainScreen ? 32 : 20,
                vertical: isMainScreen ? 36 : 24,
              ),
              child: isWideLandscape
                  ? _buildWideLandscapeLayout(context)
                  : _buildStandardLayout(context, isMainScreen),
            ),
          ),
        );
      },
    );
  }

  // Widescreen / Landscape layout (e.g. 7.6" Main Screen in landscape or tabletop mode)
  Widget _buildWideLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Hero branding & value prop
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(),
              const SizedBox(height: 16),
              _buildHeadline(fontSize: 42, textAlign: TextAlign.start),
              const SizedBox(height: 16),
              Text(
                'Instantly analyze meals for calories, macros, and micro-nutrients with Gemini AI.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xff475569),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildFeatureChips(),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Right Column: Drop Zone & Quick Actions
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildDropCard(context, height: 260),
              const SizedBox(height: 16),
              _buildDirectActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  // Standard vertical stack (Adaptive for Cover Screen & Main Screen portrait)
  Widget _buildStandardLayout(BuildContext context, bool isMainScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isMainScreen) ...[
          _buildBadge(),
          const SizedBox(height: 14),
        ],
        _buildHeadline(
          fontSize: isMainScreen ? 40 : 30,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMainScreen ? 14 : 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Instantly analyze your meals for calories, macros, and nutrients. Upload or snap a photo and let our AI do the rest.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isMainScreen ? 15 : 13.5,
              fontWeight: FontWeight.normal,
              color: const Color(0xff475569),
              height: 1.45,
            ),
          ),
        ),
        SizedBox(height: isMainScreen ? 32 : 24),
        _buildDropCard(context, height: isMainScreen ? 250 : 210),
        const SizedBox(height: 16),
        _buildDirectActionButtons(),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffebfdf5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xff10b981), size: 15),
          const SizedBox(width: 6),
          Text(
            'Smart Visual Recognition',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xff047857),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline({required double fontSize, required TextAlign textAlign}) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: const Color(0xff0f172a),
          height: 1.2,
        ),
        children: [
          const TextSpan(text: 'Know What You '),
          TextSpan(
            text: 'Eat',
            style: GoogleFonts.outfit(
              color: const Color(0xff10b981),
              shadows: [
                Shadow(
                  color: const Color(0xff10b981).withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _buildFeatureItem(Icons.bolt_rounded, 'Instant AI Scan'),
        _buildFeatureItem(Icons.pie_chart_rounded, 'Macro Breakdown'),
        _buildFeatureItem(Icons.edit_note_rounded, 'Custom Portions'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xff10b981)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xff334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropCard(BuildContext context, {required double height}) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showImageSourceActionSheet(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 580),
          height: height,
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color(0xffebfdf5).withValues(alpha: 0.4)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xff10b981)
                  : const Color(0xffcbd5e1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xff10b981).withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: _isHovered
                        ? const Color(0xff10b981)
                        : const Color(0xffcbd5e1),
                    strokeWidth: 2,
                    gap: 6,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: height > 220 ? 56 : 46,
                        height: height > 220 ? 56 : 46,
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? const Color(0xff10b981)
                              : const Color(0xfff1f5f9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: _isHovered
                              ? Colors.white
                              : const Color(0xff64748b),
                          size: height > 220 ? 28 : 22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Drop meal photo here, or tap to choose',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: height > 220 ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1e293b),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supports JPG, PNG, WEBP',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xff94a3b8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff10b981),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff10b981).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Select Photo',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick 1-tap buttons for camera or gallery directly accessible
  Widget _buildDirectActionButtons() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: Text(
                'Camera',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff334155),
                side: const BorderSide(color: Color(0xffcbd5e1)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_rounded, size: 18),
              label: Text(
                'Gallery',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff334155),
                side: const BorderSide(color: Color(0xffcbd5e1)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20),
    );
    path.addRRect(rrect);

    final double dashWidth = gap * 1.5;
    final double dashSpace = gap;
    final Path dashPath = Path();

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = min(dashWidth, metric.length - distance);
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
