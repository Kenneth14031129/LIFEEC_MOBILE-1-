import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealUpdateModal extends StatefulWidget {
  final Map<String, dynamic> currentMealData;

  const MealUpdateModal({
    super.key,
    required this.currentMealData,
  });

  @override
  State<MealUpdateModal> createState() => _MealUpdateModalState();
}

class _MealUpdateModalState extends State<MealUpdateModal> {
  late TextEditingController _breakfastController;
  late TextEditingController _lunchController;
  late TextEditingController _dinnerController;
  late TextEditingController _snacksController;
  late TextEditingController _dietaryNeedsController;
  late TextEditingController _nutritionalGoalsController;

  @override
  void initState() {
    super.initState();
    _breakfastController = TextEditingController(
      text: widget.currentMealData['breakfast'] ?? '',
    );
    _lunchController = TextEditingController(
      text: widget.currentMealData['lunch'] ?? '',
    );
    _dinnerController = TextEditingController(
      text: widget.currentMealData['dinner'] ?? '',
    );
    _snacksController = TextEditingController(
      text: widget.currentMealData['snacks'] ?? '',
    );
    _dietaryNeedsController = TextEditingController(
      text: widget.currentMealData['dietary needs'] ?? '',
    );
    _nutritionalGoalsController = TextEditingController(
      text: widget.currentMealData['nutritional goals'] ?? '',
    );
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _snacksController.dispose();
    _dietaryNeedsController.dispose();
    _nutritionalGoalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Meal Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMealSection(),
              const SizedBox(height: 24),
              _buildDietarySection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Details',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(
                  'Breakfast',
                  'Enter breakfast details',
                  _breakfastController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Lunch',
                  'Enter lunch details',
                  _lunchController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Dinner',
                  'Enter dinner details',
                  _dinnerController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Snacks',
                  'Enter snacks details',
                  _snacksController,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Requirements',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(
                  'Dietary Needs',
                  'Enter dietary restrictions and requirements',
                  _dietaryNeedsController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Nutritional Goals',
                  'Enter nutritional goals',
                  _nutritionalGoalsController,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[800],
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan[500] ?? Colors.cyan,
                  Colors.blue[600] ?? Colors.blue,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[700]!.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                final updatedMealData = {
                  'date': DateTime.now().toString().split(' ')[0],
                  'breakfast': _breakfastController.text,
                  'lunch': _lunchController.text,
                  'dinner': _dinnerController.text,
                  'snacks': _snacksController.text,
                  'dietary needs': _dietaryNeedsController.text,
                  'nutritional goals': _nutritionalGoalsController.text,
                  'completed': false,
                };
                Navigator.pop(context, updatedMealData);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
