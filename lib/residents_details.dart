import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'HealthUpdateModal.dart';
import 'activity_update_modal.dart';
import 'meal_update_modal.dart';

class ResidentDetails extends StatefulWidget {
  final String residentId;

  const ResidentDetails({
    super.key,
    required this.residentId,
  });

  @override
  State<ResidentDetails> createState() => _ResidentDetailsState();
}

class _ResidentDetailsState extends State<ResidentDetails> {
  bool isLoading = true;
  Map<String, dynamic> residentData = {};
  Map<String, dynamic> healthData = {};
  List<Map<String, dynamic>> meals = [];
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      await Future.wait([
        _fetchResidentData(),
        _fetchHealthData(),
        _fetchMealData(),
        _fetchActivityData(),
      ]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchResidentData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/api/residents/${widget.residentId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          residentData = {
            'id': data['_id'],
            'name': data['fullName'] ?? 'Unknown',
            'dateOfBirth': _formatDate(data['dateOfBirth']),
            'status': data['status'] == 'critical' ? 'Critical' : 'Active',
            'location': data['address'] ?? 'No address',
            'gender': data['gender'] ?? 'Not specified',
            'phone': data['contactNumber'] ?? 'No phone',
            'email': 'No email',
            'emergencyContact': {
              'name': data['emergencyContact']['name'] ?? 'No name',
              'phone': data['emergencyContact']['phone'] ?? 'No phone',
              'email': data['emergencyContact']['email'] ?? 'No email',
            },
            'nurseAssigned': data['createdBy']?['fullName'] ?? 'Not Assigned',
          };
        });
      } else {
        throw Exception('Failed to load resident data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching resident data: $e');
      }
    }
  }

  Future<void> _fetchHealthData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5001/api/healthplans/resident/${widget.residentId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          healthData = {
            'allergies': data['allergies'] ?? 'None',
            'medications': [
              {
                'medication': data['medications'] ?? 'None',
                'dosage': data['dosage'] ?? 'Not specified',
                'quantity': data['quantity'] ?? 'Not specified',
                'time': [data['medicationTime'] ?? 'Not specified'],
                'status': data['isMedicationTaken'] ? 'Taken' : 'Not taken'
              }
            ],
            'conditions': data['medicalCondition'] ?? 'None',
            'assessment': data['assessment'] ?? 'No assessment available',
            'instructions': data['instructions'] ?? 'No special instructions',
            'status': data['status'] ?? 'Active',
            'date': data['date'] ?? 'Not specified',
          };
        });
      } else {
        throw Exception('Failed to load health data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching health data: $e');
      }
      // Set default health data in case of error
      setState(() {
        healthData = {
          'allergies': 'None',
          'medications': [],
          'conditions': 'None',
          'assessment': 'No assessment available',
          'instructions': 'No special instructions',
          'status': 'Active',
          'date': 'Not specified',
        };
      });
    }
  }

// Update the _fetchMealData method
  Future<void> _fetchMealData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5001/api/meals/resident/${widget.residentId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          meals = data
              .map((meal) => {
                    'id': meal['_id'],
                    'date': meal['date'] ?? 'Not specified',
                    'breakfast': meal['breakfast'] ?? 'Not specified',
                    'lunch': meal['lunch'] ?? 'Not specified',
                    'snacks': meal['snacks'] ?? 'Not specified',
                    'dinner': meal['dinner'] ?? 'Not specified',
                    'dietary needs': meal['dietaryNeeds'] ?? 'None specified',
                    'nutritional goals':
                        meal['nutritionalGoals'] ?? 'None specified',
                    'completed':
                        false // You might want to add this field to your backend
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load meal data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching meal data: $e');
      }
      setState(() {
        meals = [];
      });
    }
  }

  Future<void> _fetchActivityData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5001/api/residents/${widget.residentId}/activities'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          activities =
              data.map((activity) => activity as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Failed to load activity data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching activity data: $e');
      }
      // Set default activity data in case of error
      setState(() {
        activities = [];
      });
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildExpandableSections(),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      elevation: 2,
      leading: null,
      automaticallyImplyLeading: false,
      expandedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan[500] ?? Colors.cyan,
                Colors.blue[600] ?? Colors.blue,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Resident Details',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyan[500] ?? Colors.cyan,
            Colors.blue[600] ?? Colors.blue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[700]!.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              residentData['name']?.toString()[0] ?? 'U',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  residentData['name'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      residentData['location'] ?? 'No location',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: residentData['status'] == 'Critical'
                  ? Colors.red[700]!.withOpacity(0.2)
                  : Colors.green[700]!.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: residentData['status'] == 'Critical'
                    ? Colors.red[700]!.withOpacity(0.6)
                    : Colors.green[700]!.withOpacity(0.6),
              ),
            ),
            child: Text(
              residentData['status'] ?? 'Unknown',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSections() {
    return Column(
      children: [
        _buildExpandableSection(
          'Personal Information',
          Icons.person_outline,
          _buildPersonalInformation(),
          0,
        ),
        _buildExpandableSection(
          'Health Plan',
          Icons.favorite_outline,
          _buildHealth(),
          1,
        ),
        _buildExpandableSection(
          'Meal Plan',
          Icons.restaurant_outlined,
          _buildMeals(),
          2,
        ),
        _buildExpandableSection(
          'Activity Plan',
          Icons.directions_run_outlined,
          _buildActivities(),
          3,
        ),
      ],
    );
  }

  Widget _buildExpandableSection(
      String title, IconData icon, Widget content, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.blue.shade600),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [content],
        ),
      ),
    );
  }

  Widget _buildPersonalInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('DOB:', residentData['dateOfBirth'] ?? 'Not specified'),
        _buildInfoRow('Gender:', residentData['gender'] ?? 'Not specified'),
        _buildInfoRow('Phone:', residentData['phone'] ?? 'Not specified'),
        _buildInfoRow('Email:', residentData['email'] ?? 'Not specified'),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Emergency Contact',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Name:',
          residentData['emergencyContact']?['name'] ?? 'Not specified',
        ),
        _buildInfoRow(
          'Phone:',
          residentData['emergencyContact']?['phone'] ?? 'Not specified',
        ),
        _buildInfoRow(
          'Email:',
          residentData['emergencyContact']?['email'] ?? 'Not specified',
        ),
      ],
    );
  }

  Widget _buildHealth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConditionsAndAllergies(),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        _buildMedications(),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        _buildHealthAssessment(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildGradientButton(
                'Update Health Plan',
                () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => HealthUpdateModal(
                      currentHealthData: healthData,
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      healthData = result;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGradientButton(
                'View Health History',
                () {
                  // Add your view health history logic here
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionsAndAllergies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildInfoRow(
          'Allergies:',
          healthData['allergies']?.toString() ?? 'None',
        ),
        _buildInfoRow(
          'Medical Conditions:',
          healthData['conditions']?.toString() ?? 'None',
        ),
      ],
    );
  }

  Widget _buildMedications() {
    final medications = healthData['medications'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medication Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              healthData['date'] ?? 'Not specified',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (medications.isEmpty)
          Text(
            'No medications prescribed',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
            ),
          )
        else
          ListView.builder(
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
                      _buildInfoRow('Medication:', medication['medication']),
                      _buildInfoRow('Dosage:', medication['dosage']),
                      _buildInfoRow('Quantity:', medication['quantity']),
                      _buildInfoRow('Time:',
                          medication['time']?.join(', ') ?? 'Not specified'),
                      _buildInfoRow('Status:', medication['status']),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildHealthAssessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Assessment',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'Assessment Notes:',
          healthData['assessment'] ?? 'No specific notes at this time.',
        ),
        _buildInfoRow(
          'Special Instructions:',
          healthData['instructions'] ?? 'No special instructions at this time.',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'Status:',
          healthData['status'] ?? 'Active',
        ),
      ],
    );
  }

  Widget _buildMeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (meals.isEmpty)
          Center(
            child: Text(
              'No meal plans available',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              return _buildMealCard(meals[index]);
            },
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildGradientButton(
                'Update Meal Plan',
                () async {
                  final currentMeal =
                      meals.isNotEmpty ? meals[0] : <String, dynamic>{};
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => MealUpdateModal(
                      currentMealData:
                          currentMeal, // Now passing a non-nullable Map
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      if (meals.isEmpty) {
                        meals.add(result);
                      } else {
                        meals[0] = result;
                      }
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGradientButton(
                'View Meal History',
                () {
                  // Add your view meal history logic here
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  meal['date'] ?? 'No date',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _buildStatusChip(meal['completed'] ?? false),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Meal Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildMealTime('Breakfast:', meal['breakfast']),
            _buildMealTime('Lunch:', meal['lunch']),
            _buildMealTime('Snacks:', meal['snacks']),
            _buildMealTime('Dinner:', meal['dinner']),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('Dietary Needs:', meal['dietary needs']),
            _buildInfoRow('Nutritional Goals:', meal['nutritional goals']),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTime(String time, String? meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              meal ?? 'Not specified',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activities.isEmpty)
          Center(
            child: Text(
              'No activities scheduled',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(activities[index]);
            },
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildGradientButton(
                'Update Activity Plan',
                () async {
                  final currentActivity = activities.isNotEmpty
                      ? activities[0]
                      : <String, dynamic>{};
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => ActivityUpdateModal(
                      currentActivityData: currentActivity,
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      if (activities.isEmpty) {
                        activities.add(result);
                      } else {
                        activities[0] = result;
                      }
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGradientButton(
                'View Activity History',
                () {
                  // Add your view activity history logic here
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activity['activity name'] == 'Physical Therapy'
                        ? Icons.fitness_center
                        : Icons.groups,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['activity name'] ?? 'Unknown Activity',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        activity['date'] ?? 'No date',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(activity['completed'] ?? false),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Location:', activity['location']),
            _buildInfoRow('Duration:', activity['duration']),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Description:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              activity['description'] ?? 'No description available',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (activity['notes'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Notes:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activity['notes'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: completed ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        completed ? 'Completed' : 'Scheduled',
        style: GoogleFonts.poppins(
          color: completed ? Colors.green[700] : Colors.orange[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
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
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
