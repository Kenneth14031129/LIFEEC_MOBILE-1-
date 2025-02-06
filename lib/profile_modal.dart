import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ProfileModal extends StatefulWidget {
  final VoidCallback onLogout;
  final String userId;

  const ProfileModal({
    super.key,
    required this.onLogout,
    required this.userId,
  });

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5001/api/users/profile/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw json.decode(response.body)['message'] ??
            'Failed to fetch profile';
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? _buildErrorState()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(
          'Error Loading Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage ?? 'Unknown error occurred',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isLoading = true;
              errorMessage = null;
            });
            _fetchUserProfile();
          },
          child: Text(
            'Retry',
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    final String userInitial =
        userData?['fullName']?.substring(0, 1).toUpperCase() ?? 'N';
    final String userType = userData?['userType']?.toString() ?? 'User';
    final String formattedUserType =
        userType[0].toUpperCase() + userType.substring(1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Profile Settings',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue[100],
          child: Text(
            userInitial,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userData?['fullName'] ?? 'User Name',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          userData?['email'] ?? 'email@example.com',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          formattedUserType,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 24),
        _buildSettingsItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {
            // Add edit profile functionality
          },
        ),
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: () {
            // Add change password functionality
          },
        ),
        const Divider(height: 32),
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Logout',
          color: Colors.red[700],
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Confirm Logout',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Are you sure you want to logout?',
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onLogout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color ?? Colors.grey[800],
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: color ?? Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
