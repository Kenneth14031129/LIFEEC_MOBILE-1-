import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthUpdateModal extends StatefulWidget {
  final Map<String, dynamic> currentHealthData;

  const HealthUpdateModal({
    super.key,
    required this.currentHealthData,
  });

  @override
  State<HealthUpdateModal> createState() => _HealthUpdateModalState();
}

class _HealthUpdateModalState extends State<HealthUpdateModal> {
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _assessmentNotesController;
  late TextEditingController _specialInstructionsController;
  late List<Map<String, dynamic>> medications;

  @override
  void initState() {
    super.initState();

    // Handle allergies that might be a string or a list
    final allergies = widget.currentHealthData['allergies'];
    String allergiesText = '';
    if (allergies != null) {
      if (allergies is List) {
        allergiesText = allergies.join(', ');
      } else {
        allergiesText = allergies.toString();
      }
    }
    _allergiesController = TextEditingController(text: allergiesText);

    // Handle conditions that might be a string or a list
    final conditions = widget.currentHealthData['conditions'];
    String conditionsText = '';
    if (conditions != null) {
      if (conditions is List) {
        conditionsText = conditions.join(', ');
      } else {
        conditionsText = conditions.toString();
      }
    }
    _conditionsController = TextEditingController(text: conditionsText);

    _assessmentNotesController = TextEditingController(
      text: widget.currentHealthData['assessment'] ??
          widget.currentHealthData['assessmentNotes'] ??
          'No specific notes at this time.',
    );

    _specialInstructionsController = TextEditingController(
      text: widget.currentHealthData['instructions'] ??
          widget.currentHealthData['specialInstructions'] ??
          'No special instructions at this time.',
    );

    // Handle medications that might be a single object or a list
    if (widget.currentHealthData['medications'] is List) {
      medications = List<Map<String, dynamic>>.from(
        widget.currentHealthData['medications'],
      );
    } else if (widget.currentHealthData['medications'] != null) {
      // If it's a single medication object, create a list with one item
      medications = [
        {
          'medication': widget.currentHealthData['medications'],
          'dosage': widget.currentHealthData['dosage'] ?? '',
          'quantity': widget.currentHealthData['quantity'] ?? '',
          'time': widget.currentHealthData['medicationTime'] ?? '',
          'status': widget.currentHealthData['isMedicationTaken']
              ? 'Taken'
              : 'Not taken'
        }
      ];
    } else {
      medications = [];
    }
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _assessmentNotesController.dispose();
    _specialInstructionsController.dispose();
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
                    'Update Health Plan',
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
              _buildTextField(
                'Allergies',
                'Enter allergies (comma-separated)',
                _allergiesController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Medical Conditions',
                'Enter medical conditions (comma-separated)',
                _conditionsController,
              ),
              const SizedBox(height: 24),
              Text(
                'Medication Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              _buildMedicationsList(),
              const SizedBox(height: 24),
              Text(
                'Health Assessment',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              _buildHealthAssessment(),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Medication ${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          medications.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMedicationField(
                  'Medication',
                  medication['medication'] ?? '',
                  (value) {
                    setState(() {
                      medication['medication'] = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMedicationField(
                        'Dosage',
                        medication['dosage'] ?? '',
                        (value) {
                          setState(() {
                            medication['dosage'] = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMedicationField(
                        'Quantity',
                        medication['quantity'] ?? '',
                        (value) {
                          setState(() {
                            medication['quantity'] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMedicationField(
                  'Time',
                  medication['time']?.join(', ') ?? '',
                  (value) {
                    setState(() {
                      medication['time'] =
                          value.split(',').map((e) => e.trim()).toList();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicationField(
    String label,
    String initialValue,
    Function(String) onChanged,
  ) {
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
          controller: TextEditingController(text: initialValue),
          onChanged: onChanged,
          decoration: InputDecoration(
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

  Widget _buildHealthAssessment() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessment Notes',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _assessmentNotesController,
                  maxLines: 3,
                  decoration: InputDecoration(
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
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _specialInstructionsController,
                  maxLines: 3,
                  decoration: InputDecoration(
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
            ),
          ],
        ),
      ),
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
                final updatedHealthData = {
                  'allergies': _allergiesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'conditions': _conditionsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'medications': medications
                      .map((med) => {
                            'medication': med['medication'],
                            'dosage': med['dosage'],
                            'quantity': med['quantity'],
                            'time': med['time'] is List
                                ? med['time']
                                : med['time']
                                    .toString()
                                    .split(',')
                                    .map((e) => e.trim())
                                    .toList(),
                            'status': med['status']
                          })
                      .toList(),
                  'assessmentNotes': _assessmentNotesController.text,
                  'specialInstructions': _specialInstructionsController.text,
                };
                Navigator.pop(context, updatedHealthData);
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
