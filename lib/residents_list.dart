import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bottomappbar.dart';
import 'residents_details.dart';

class ResidentsList extends StatefulWidget {
  const ResidentsList({super.key});

  @override
  State<ResidentsList> createState() => _ResidentsListState();
}

class _ResidentsListState extends State<ResidentsList> {
  bool isLoading = true;
  List<Map<String, dynamic>> residents = [];
  int _selectedIndex = 1;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResidents();
  }

  Future<void> _fetchResidents() async {
    setState(() {
      isLoading = true;
      _error = null;
    });

    try {
      final Uri url = Uri.parse('http://localhost:5001/api/residents/search');

      if (kDebugMode) {
        print('Fetching from URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          residents = data
              .map((resident) => {
                    'id': resident['_id'],
                    'name': resident['fullName'] ?? 'Unknown',
                    'dateOfBirth': _formatDate(resident['dateOfBirth']),
                    'status': resident['status'] == 'critical'
                        ? 'Critical'
                        : 'Active',
                    'location': resident['address'] ?? 'No address',
                    'lastUpdated': DateTime.parse(resident['updatedAt']),
                    'gender': resident['gender'] ?? 'Not specified',
                    'phone': resident['contactNumber'] ?? 'No phone',
                    'email':
                        'No email', // Since email is not in your backend model
                    'emergencyContact': {
                      'name': resident['emergencyContact']['name'] ?? 'No name',
                      'phone':
                          resident['emergencyContact']['phone'] ?? 'No phone',
                      'email':
                          resident['emergencyContact']['email'] ?? 'No email',
                    },
                    'nurseAssigned':
                        resident['createdBy']?['fullName'] ?? 'Not Assigned',
                  })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load residents');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching residents: $e');
      }
      setState(() {
        _error = 'Failed to load residents. Please try again. Error: $e';
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // Add debounce for search
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _fetchResidents();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredResidents {
    return residents.where((resident) {
      final matchesSearch = resident['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'All' || resident['status'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildResidentsList(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      elevation: 2,
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
                Text(
                  'LIFEEC',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    'N',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Residents List',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and monitor residents',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search residents...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButton<String>(
            value: _selectedFilter,
            underline: const SizedBox(),
            items: ['All', 'Active', 'Critical']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: GoogleFonts.poppins()),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedFilter = value!);
              _fetchResidents();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResidentsList() {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: GoogleFonts.poppins(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchResidents,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (residents.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No residents found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildResidentCard(residents[index]),
          childCount: residents.length,
        ),
      ),
    );
  }

  Widget _buildResidentCard(Map<String, dynamic> resident) {
    final bool isCritical = resident['status'] == 'Critical';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue[50],
                  child: Text(
                    resident['name'].toString()[0],
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resident['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resident['location'],
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
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
                    color: isCritical ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    resident['status'],
                    style: GoogleFonts.poppins(
                      color: isCritical ? Colors.red[700] : Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('DOB:', resident['dateOfBirth']),
                const SizedBox(height: 8),
                _buildInfoRow('Gender:', resident['gender']),
                const SizedBox(height: 8),
                _buildInfoRow('Phone:', resident['phone']),
                const SizedBox(height: 8),
                _buildInfoRow('Email:', resident['email']),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Emergency Contact',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Name:', resident['emergencyContact']['name']),
                const SizedBox(height: 4),
                _buildInfoRow('Phone:', resident['emergencyContact']['phone']),
                const SizedBox(height: 4),
                _buildInfoRow('Email:', resident['emergencyContact']['email']),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResidentDetails(
                      residentId: resident['id'],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue.shade800,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
