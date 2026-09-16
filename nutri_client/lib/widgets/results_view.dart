import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/nutrition_analysis.dart';
import '../utils/foldable_layout.dart';
import 'donut_chart.dart';

class ResultsView extends StatelessWidget {
  final NutritionAnalysis analysis;
  final Uint8List imageBytes;
  final VoidCallback onAnalyzeAnother;
  final ValueChanged<NutritionAnalysis> onAnalysisChanged;

  const ResultsView({
    super.key,
    required this.analysis,
    required this.imageBytes,
    required this.onAnalyzeAnother,
    required this.onAnalysisChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMainScreen = constraints.maxWidth >= FoldableLayout.compactBreakpoint;
        final isTabletop = FoldableUtils.isTabletopPosture(context);
        final hingeGutter = FoldableLayout.getHingeGutter(context);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1240),
              padding: EdgeInsets.symmetric(
                horizontal: isMainScreen ? 28 : 16,
                vertical: isMainScreen ? 28 : 20,
              ),
              child: isTabletop
                  ? _buildTabletopLayout(context, hingeGutter)
                  : isMainScreen
                      ? _buildDualPaneLayout(context, hingeGutter)
                      : _buildCoverScreenLayout(context),
            ),
          ),
        );
      },
    );
  }

  // 7.6" Main Screen Dual-Pane Layout (Landscape & Portrait unfolded)
  Widget _buildDualPaneLayout(BuildContext context, double hingeGutter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Food Visuals, Energy & Health Insights)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFoodVisualsCard(context, isMainScreen: true),
              const SizedBox(height: 20),
              _buildHealthInsightCard(),
            ],
          ),
        ),
        // Hinge Gutter avoids placing elements right on the screen crease
        SizedBox(width: hingeGutter),
        // Right Column (Macronutrients, Ingredients & Portions, Vitamins & Action Button)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMacronutrientsCard(isMainScreen: true),
              const SizedBox(height: 20),
              _buildIngredientsCard(context),
              const SizedBox(height: 20),
              _buildVitaminsCard(),
              const SizedBox(height: 28),
              _buildActionBtn(),
            ],
          ),
        ),
      ],
    );
  }

  // Samsung Fold Tabletop / Flex Mode Layout (Device partially folded on table)
  Widget _buildTabletopLayout(BuildContext context, double hingeGutter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Half (Visuals & Health summary on the upright screen)
        _buildFoodVisualsCard(context, isMainScreen: true, compactImage: true),
        const SizedBox(height: 16),
        _buildHealthInsightCard(),
        // Fold Crease spacing
        SizedBox(height: hingeGutter),
        // Bottom Half (Interactive controls on the flat surface)
        _buildMacronutrientsCard(isMainScreen: true),
        const SizedBox(height: 16),
        _buildIngredientsCard(context),
        const SizedBox(height: 16),
        _buildVitaminsCard(),
        const SizedBox(height: 24),
        _buildActionBtn(),
      ],
    );
  }

  // 5.5" Cover Screen Scrolling Single Column Layout
  Widget _buildCoverScreenLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoodVisualsCard(context, isMainScreen: false),
        const SizedBox(height: 16),
        _buildMacronutrientsCard(isMainScreen: false),
        const SizedBox(height: 16),
        _buildIngredientsCard(context),
        const SizedBox(height: 16),
        _buildVitaminsCard(),
        const SizedBox(height: 16),
        _buildHealthInsightCard(),
        const SizedBox(height: 24),
        _buildActionBtn(),
      ],
    );
  }

  // 1. Food Image + Floating Badge + Dish Title + Confidence Pill + Energy Card
  Widget _buildFoodVisualsCard(
    BuildContext context, {
    required bool isMainScreen,
    bool compactImage = false,
  }) {
    final imageHeight = compactImage
        ? 200.0
        : isMainScreen
            ? 300.0
            : 220.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMainScreen ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Styled Image with Anchored Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: imageHeight,
                  fit: BoxFit.cover,
                ),
                // Floating Portion/Serving Size Badge (Top Right)
                if (analysis.servingSize.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        analysis.servingSize,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1e293b),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Dish Title with Edit Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  analysis.foodName,
                  style: GoogleFonts.outfit(
                    fontSize: isMainScreen ? 26 : 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff0f172a),
                    height: 1.2,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xff10b981),
                  size: 26,
                ),
                onPressed: () => _showEditTitleDialog(context),
                tooltip: 'Edit meal details',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xffebfdf5),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Confidence pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffebfdf5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Confidence: ${analysis.confidenceScore.toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xff047857),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Energy Card (Warm glowing box)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xfffff7ed),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xfffed7aa), width: 1),
            ),
            child: Row(
              children: [
                // Glowing orange flame icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xfff97316),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xfff97316).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENERGY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff9a3412),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${analysis.calories.toInt()} ',
                            style: GoogleFonts.outfit(
                              fontSize: isMainScreen ? 26 : 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xff7c2d12),
                            ),
                          ),
                          TextSpan(
                            text: 'kcal',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff9a3412),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Macronutrient card (Responsive Donut Chart + proportional stats breakdown)
  Widget _buildMacronutrientsCard({required bool isMainScreen}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMainScreen ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                color: Color(0xff10b981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Macronutrients',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1e293b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, boxConstraints) {
              final isVeryNarrow = boxConstraints.maxWidth < 320;
              final chartDiameter = isVeryNarrow
                  ? 130.0
                  : isMainScreen
                      ? 170.0
                      : 140.0;

              if (isVeryNarrow) {
                // Stack vertically on extremely tight viewports
                return Column(
                  children: [
                    Center(
                      child: DonutChart(
                        protein: analysis.macros.protein,
                        carbs: analysis.macros.carbs,
                        fat: analysis.macros.fat,
                        size: chartDiameter,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildLegend(),
                    const SizedBox(height: 16),
                    _buildMacroRows(),
                  ],
                );
              }

              // Side by side on standard cover screen & main screen
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        DonutChart(
                          protein: analysis.macros.protein,
                          carbs: analysis.macros.carbs,
                          fat: analysis.macros.fat,
                          size: chartDiameter,
                        ),
                        const SizedBox(height: 14),
                        _buildLegend(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 6,
                    child: _buildMacroRows(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 4,
      children: [
        _buildLegendDot('Carbs', const Color(0xff3498db)),
        _buildLegendDot('Fat', const Color(0xfff1c40f)),
        _buildLegendDot('Protein', const Color(0xff2ecc71)),
      ],
    );
  }

  Widget _buildMacroRows() {
    return Column(
      children: [
        _buildMacroDetailRow(
            'Protein', '${analysis.macros.protein.toInt()}g', const Color(0xff2ecc71)),
        _buildMacroDetailRow(
            'Carbs', '${analysis.macros.carbs.toInt()}g', const Color(0xff3498db)),
        _buildMacroDetailRow(
            'Fats', '${analysis.macros.fat.toInt()}g', const Color(0xfff1c40f)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Divider(color: Color(0xfff1f5f9), height: 1),
        ),
        _buildMacroDetailRow(
            'Fiber', '${analysis.macros.fiber.toInt()}g', const Color(0xffcbd5e1)),
        _buildMacroDetailRow(
            'Sugar', '${analysis.macros.sugar.toInt()}g', const Color(0xffcbd5e1)),
      ],
    );
  }

  Widget _buildLegendDot(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xff64748b),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroDetailRow(String name, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff475569),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xff0f172a),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Vitamins & Minerals Card
  Widget _buildVitaminsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vitamins & Minerals',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 14),
          if (analysis.vitaminsAndMinerals.isEmpty)
            Text(
              'No significant vitamins or minerals noted.',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xff94a3b8)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analysis.vitaminsAndMinerals.map((item) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f5f9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff475569),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // 4. Health Insights Card
  Widget _buildHealthInsightCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xffebfdf5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xff10b981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Health Insight',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1e293b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            analysis.healthSummary,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.normal,
              color: const Color(0xff475569),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // 5. "Analyze Another Photo" Action Button
  Widget _buildActionBtn() {
    return ElevatedButton(
      onPressed: onAnalyzeAnother,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1e293b),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Text(
        'Analyze Another Photo',
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // --- Dynamic Ingredient Breakdown & Editing Section ---

  Widget _buildIngredientsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Color(0xff10b981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ingredients & Portions',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1e293b),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showAddEditIngredientDialog(context),
                icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xff10b981)),
                tooltip: 'Add ingredient',
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (analysis.ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No ingredients listed. Tap "+" to add one!',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xff94a3b8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analysis.ingredients.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xfff1f5f9),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final ing = analysis.ingredients[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ing.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff0f172a),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff1f5f9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ing.amount,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildIngMacroBadge('${ing.calories.toInt()} kcal', const Color(0xfff97316)),
                                _buildIngMacroBadge('P: ${ing.protein.toInt()}g', const Color(0xff2ecc71)),
                                _buildIngMacroBadge('C: ${ing.carbs.toInt()}g', const Color(0xff3498db)),
                                _buildIngMacroBadge('F: ${ing.fat.toInt()}g', const Color(0xfff1c40f)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Action buttons (Edit & Delete)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xff64748b)),
                            onPressed: () => _showAddEditIngredientDialog(
                              context,
                              ingredient: ing,
                              index: index,
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xffef4444)),
                            onPressed: () => _deleteIngredient(context, index),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildIngMacroBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  void _showEditTitleDialog(BuildContext context) {
    final nameController = TextEditingController(text: analysis.foodName);
    final servingController = TextEditingController(text: analysis.servingSize);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Meal Details',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: const Color(0xff1e293b),
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Meal Name',
                      labelStyle: GoogleFonts.inter(color: const Color(0xff64748b)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xffcbd5e1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xff10b981), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: servingController,
                    decoration: InputDecoration(
                      labelText: 'Serving Size',
                      labelStyle: GoogleFonts.inter(color: const Color(0xff64748b)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xffcbd5e1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xff10b981), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: const Color(0xff64748b), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = analysis.copyWith(
                  foodName: nameController.text.trim().isNotEmpty
                      ? nameController.text.trim()
                      : analysis.foodName,
                  servingSize: servingController.text.trim(),
                );
                onAnalysisChanged(updated);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff10b981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditIngredientDialog(BuildContext context, {Ingredient? ingredient, int? index}) {
    final nameController = TextEditingController(text: ingredient?.name ?? '');
    final amountController = TextEditingController(text: ingredient?.amount ?? '100g');
    final calController = TextEditingController(text: ingredient != null ? ingredient.calories.toInt().toString() : '100');
    final protController = TextEditingController(text: ingredient != null ? ingredient.protein.toInt().toString() : '5');
    final carbController = TextEditingController(text: ingredient != null ? ingredient.carbs.toInt().toString() : '15');
    final fatController = TextEditingController(text: ingredient != null ? ingredient.fat.toInt().toString() : '2');
    final fiberController = TextEditingController(text: ingredient != null ? ingredient.fiber.toInt().toString() : '1');
    final sugarController = TextEditingController(text: ingredient != null ? ingredient.sugar.toInt().toString() : '2');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            ingredient == null ? 'Add Ingredient' : 'Edit Ingredient',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: const Color(0xff1e293b),
            ),
          ),
          content: Form(
            key: formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: _dialogInputDecoration('Ingredient Name', 'e.g. Avocado'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      style: GoogleFonts.inter(fontSize: 13.5),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      decoration: _dialogInputDecoration('Amount / Serving', 'e.g. 1 half, 150g'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                      style: GoogleFonts.inter(fontSize: 13.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: calController,
                            decoration: _dialogInputDecoration('Calories (kcal)', '0'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _numberValidator,
                            style: GoogleFonts.inter(fontSize: 13.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: fatController,
                            decoration: _dialogInputDecoration('Fat (g)', '0'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _numberValidator,
                            style: GoogleFonts.inter(fontSize: 13.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: carbController,
                            decoration: _dialogInputDecoration('Carbs (g)', '0'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _numberValidator,
                            style: GoogleFonts.inter(fontSize: 13.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: protController,
                            decoration: _dialogInputDecoration('Protein (g)', '0'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _numberValidator,
                            style: GoogleFonts.inter(fontSize: 13.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: fiberController,
                            decoration: _dialogInputDecoration('Fiber (g)', '0'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _numberValidator,
                            style: GoogleFonts.inter(fontSize: 13.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: sugarController,
                            decoration: _dialogInputDecoration('Sugar (g)', '0'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _numberValidator,
                            style: GoogleFonts.inter(fontSize: 13.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: const Color(0xff64748b), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newIng = Ingredient(
                    name: nameController.text.trim(),
                    amount: amountController.text.trim(),
                    calories: double.tryParse(calController.text) ?? 0.0,
                    protein: double.tryParse(protController.text) ?? 0.0,
                    carbs: double.tryParse(carbController.text) ?? 0.0,
                    fat: double.tryParse(fatController.text) ?? 0.0,
                    fiber: double.tryParse(fiberController.text) ?? 0.0,
                    sugar: double.tryParse(sugarController.text) ?? 0.0,
                  );

                  final list = List<Ingredient>.from(analysis.ingredients);
                  if (ingredient != null && index != null) {
                    list[index] = newIng;
                  } else {
                    list.add(newIng);
                  }

                  _recalculateMacros(list);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff10b981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                ingredient == null ? 'Add' : 'Save',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _dialogInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.inter(color: const Color(0xff64748b), fontSize: 13),
      hintStyle: GoogleFonts.inter(color: const Color(0xffcbd5e1), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffcbd5e1)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xff10b981), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffef4444)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffef4444), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final num = double.tryParse(value);
    if (num == null) return 'Must be a number';
    if (num < 0) return 'Cannot be negative';
    return null;
  }

  void _recalculateMacros(List<Ingredient> updatedIngredients) {
    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    double totalFiber = 0.0;
    double totalSugar = 0.0;

    for (var ing in updatedIngredients) {
      totalCalories += ing.calories;
      totalProtein += ing.protein;
      totalCarbs += ing.carbs;
      totalFat += ing.fat;
      totalFiber += ing.fiber;
      totalSugar += ing.sugar;
    }

    final updatedAnalysis = analysis.copyWith(
      calories: totalCalories,
      macros: MacroData(
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        fiber: totalFiber,
        sugar: totalSugar,
      ),
      ingredients: updatedIngredients,
    );

    onAnalysisChanged(updatedAnalysis);
  }

  void _deleteIngredient(BuildContext context, int index) {
    final list = List<Ingredient>.from(analysis.ingredients);
    list.removeAt(index);
    _recalculateMacros(list);
  }
}
