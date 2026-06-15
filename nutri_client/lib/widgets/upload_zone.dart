import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffcbd5e1).withValues(alpha: 0.5)),
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
                        const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8)),
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffcbd5e1).withValues(alpha: 0.5)),
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
                        const Icon(Icons.chevron_right_rounded, color: Color(0xff94a3b8)),
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
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Headline: "Know What You Eat"
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff0f172a), // Slate 900
                  height: 1.2,
                ),
                children: [
                  const TextSpan(text: 'Know What You '),
                  TextSpan(
                    text: 'Eat',
                    style: GoogleFonts.outfit(
                      color: const Color(0xff10b981), // Glowing Emerald
                      shadows: [
                        Shadow(
                          color: const Color(0xff10b981).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Subtitle
            Container(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Text(
                'Instantly analyze your meals for calories, macros, and nutrients. Just upload a photo and let our AI do the rest.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: const Color(0xff475569), // Slate 600
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Dotted Dash Card Upload Zone
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showImageSourceActionSheet(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 580),
                  height: 280,
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? const Color(0xffebfdf5).withOpacity(0.4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isHovered
                          ? const Color(0xff10b981)
                          : const Color(0xffcbd5e1),
                      width: 2,
                      style: BorderStyle
                          .solid, // Note: Dashed borders require a custom painter. We use a thick clean responsive line or solid for simplicity.
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered
                            ? const Color(0xff10b981).withOpacity(0.06)
                            : Colors.black.withOpacity(0.02),
                        blurRadius: _isHovered ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Recreate Dashed border using custom painter for maximum fidelity
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
                      // Core details
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glowing green cloud icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _isHovered
                                    ? const Color(0xffd1fae5)
                                    : const Color(0xffebfdf5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 30,
                                color: Color(0xff10b981),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Bold Action text
                            Text(
                              'Click to upload or drag and drop',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff1e293b),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Details
                            Text(
                              'SVG, PNG, JPG or GIF (max. 10MB)',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xff64748b),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Premium button
                            AnimatedScale(
                              scale: _isHovered ? 1.03 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xff00a86b,
                                  ), // Emerald Green
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xff00a86b,
                                      ).withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Select Photo',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw high fidelity dashed border around the card
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

    // Render dashed path manually
    final double dashWidth = gap * 1.5;
    final double dashSpace = gap;

    // We can draw dash slices using dash path effect or manual segments.
    // Let's implement a clean manual dash approximation.
    final Path dashPath = Path();

    // Simplify dashed borders by calculating segments
    for (
      double i = 0;
      i < size.width + size.height * 2;
      i += dashWidth + dashSpace
    ) {
      // Draw simple dashed segments or rely on neat stroke dashes.
      // In Flutter Web/Mobile, we draw sub-segments manually or approximate.
      // To ensure maximum compatibility and zero performance hit,
      // let's draw neat segment sections for a beautiful dashed border:
    }

    // An elegant custom dashed outline
    final PathMetrics = path.computeMetrics();
    for (final metric in PathMetrics) {
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
