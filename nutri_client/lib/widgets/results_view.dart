import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/nutrition_analysis.dart';
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
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              if (isDesktop) {
                return _buildDesktopLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  // Large-screen side-by-side layout (matches visual mock 2 perfectly)
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Food Visuals, Ingredients, Energy & Insights)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFoodVisualsCard(context),
              const SizedBox(height: 24),
              _buildIngredientsCard(context),
              const SizedBox(height: 24),
              _buildHealthInsightCard(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Right Column (Macronutrients, Vitamins & Action Button)
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMacronutrientsCard(),
              const SizedBox(height: 24),
              _buildVitaminsCard(),
              const SizedBox(height: 32),
              _buildActionBtn(),
            ],
          ),
        ),
      ],
    );
  }

  // Narrow-screen scrolling single column layout
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoodVisualsCard(context),
        const SizedBox(height: 24),
        _buildMacronutrientsCard(),
        const SizedBox(height: 24),
        _buildIngredientsCard(context),
        const SizedBox(height: 24),
        _buildVitaminsCard(),
        const SizedBox(height: 24),
        _buildHealthInsightCard(),
        const SizedBox(height: 32),
        _buildActionBtn(),
      ],
    );
  }

  // 1. Food Image + Floating Badge + Dish Title + Confidence Pill + Energy Card
  Widget _buildFoodVisualsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Styled Image with Anchored Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
                // Floating Portion/Serving Size Badge (Top Right)
                if (analysis.servingSize.isNotEmpty)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        analysis.servingSize,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1e293b),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Dish Title with Edit Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  analysis.foodName,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff0f172a), // Slate 900
                    height: 1.25,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xff10b981),
                  size: 28,
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
          const SizedBox(height: 12),
          // Confidence pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffebfdf5), // Emerald light
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Confidence: ${analysis.confidenceScore.toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff047857), // Green 700
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Energy Card (Warm glowing box)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xfffff7ed), // Orange warm 50
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xfffed7aa), width: 1),
            ),
            child: Row(
              children: [
                // Glowing orange flame icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xfff97316), // Orange 500
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xfff97316).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENERGY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff9a3412), // Orange 800
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
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xff7c2d12),
                            ),
                          ),
                          TextSpan(
                            text: 'kcal',
                            style: GoogleFonts.inter(
                              fontSize: 14,
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

  // 2. Macronutrient card (Donut Chart + proportional stats breakdown)
  Widget _buildMacronutrientsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                color: Color(0xff10b981),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Macronutrients',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1e293b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Donut + list details side-by-side or stacked
          LayoutBuilder(builder: (context, boxConstraints) {
            final double diameter = 160;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom Donut widget left-aligned
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      DonutChart(
                        protein: analysis.macros.protein,
                        carbs: analysis.macros.carbs,
                        fat: analysis.macros.fat,
                      ),
                      const SizedBox(height: 18),
                      // Mini Legend
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _buildLegendDot('Carbs', const Color(0xff3498db)),
                          _buildLegendDot('Fat', const Color(0xfff1c40f)),
                          _buildLegendDot('Protein', const Color(0xff2ecc71)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Detailed text rows right-aligned
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _buildMacroDetailRow(
                          'Protein', '${analysis.macros.protein.toInt()}g', const Color(0xff2ecc71)),
                      _buildMacroDetailRow(
                          'Carbs', '${analysis.macros.carbs.toInt()}g', const Color(0xff3498db)),
                      _buildMacroDetailRow(
                          'Fats', '${analysis.macros.fat.toInt()}g', const Color(0xfff1c40f)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(color: Color(0xfff1f5f9), height: 1),
                      ),
                      _buildMacroDetailRow(
                          'Fiber', '${analysis.macros.fiber.toInt()}g', const Color(0xffcbd5e1)),
                      _buildMacroDetailRow(
                          'Sugar', '${analysis.macros.sugar.toInt()}g', const Color(0xffcbd5e1)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xff64748b),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroDetailRow(String name, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff475569),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vitamins & Minerals',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 16),
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f5f9), // Slate 100 light chip
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xffebfdf5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xff10b981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Health Insight',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1e293b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Detailed paragraph
          Text(
            analysis.healthSummary,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xff475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // 5. "Analyze Another Photo" Slate Action Button
  Widget _buildActionBtn() {
    return ElevatedButton(
      onPressed: onAnalyzeAnother,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1e293b), // Slate 800 (#1E293B)
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Text(
        'Analyze Another Photo',
        style: GoogleFonts.inter(
          fontSize: 16,
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
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
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ingredients & Portions',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
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
          const SizedBox(height: 16),
          if (analysis.ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No ingredients listed. Tap "+" to add one!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff0f172a),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
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
                              spacing: 8,
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
                      const SizedBox(width: 8),
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
                            padding: const EdgeInsets.all(8),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xffef4444)),
                            onPressed: () => _deleteIngredient(context, index),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
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
          fontSize: 11,
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
          content: SingleChildScrollView(
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
                  style: GoogleFonts.inter(fontSize: 15),
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
                  style: GoogleFonts.inter(fontSize: 15),
                ),
              ],
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
                   borderRadius: BorderRadius.circular(8),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: _dialogInputDecoration('Ingredient Name', 'e.g. Avocado'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    decoration: _dialogInputDecoration('Amount / Serving', 'e.g. 1 half, 150g'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    style: GoogleFonts.inter(fontSize: 14),
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
                           style: GoogleFonts.inter(fontSize: 14),
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: TextFormField(
                           controller: fatController,
                           decoration: _dialogInputDecoration('Fat (g)', '0'),
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           validator: _numberValidator,
                           style: GoogleFonts.inter(fontSize: 14),
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
                           style: GoogleFonts.inter(fontSize: 14),
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: TextFormField(
                           controller: protController,
                           decoration: _dialogInputDecoration('Protein (g)', '0'),
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           validator: _numberValidator,
                           style: GoogleFonts.inter(fontSize: 14),
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
                           style: GoogleFonts.inter(fontSize: 14),
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         child: TextFormField(
                           controller: sugarController,
                           decoration: _dialogInputDecoration('Sugar (g)', '0'),
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           validator: _numberValidator,
                           style: GoogleFonts.inter(fontSize: 14),
                         ),
                       ),
                     ],
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
                   borderRadius: BorderRadius.circular(8),
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
