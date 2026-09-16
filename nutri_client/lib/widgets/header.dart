import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/foldable_layout.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = FoldableLayout.isCoverScreen(context);
    final hPadding = isCompact ? 16.0 : 24.0;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Logo + Title
          Row(
            children: [
              // Logo Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xff10b981), // Emerald green
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff10b981).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'N',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Title
              Text(
                'NutriScan AI',
                style: GoogleFonts.outfit(
                  fontSize: isCompact ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff0f172a), // Slate 900
                ),
              ),
            ],
          ),
          // Right Powered By
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff10b981),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isCompact ? 'Gemini AI' : 'Powered by Gemini',
                style: GoogleFonts.inter(
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff64748b), // Slate 500
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
