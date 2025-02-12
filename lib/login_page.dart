import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_list_screen.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool showPassword = false;
  bool isLoading = false;
  late AnimationController _animationController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedUserType = 'nurse';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

// Add this function outside the class to handle the API response
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:5001/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    return json.decode(response.body);
  }

// Add this function outside the class to handle registration
  Future<Map<String, dynamic>> registerUser(String fullName, String email,
      String password, String phone, String userType) async {
    final response = await http.post(
      Uri.parse('http://localhost:5001/api/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'userType': userType,
      }),
    );

    return json.decode(response.body);
  }

// Replace the existing _handleSubmit with this version
  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> response;

      if (isLogin) {
        // Handle login
        response =
            await loginUser(_emailController.text, _passwordController.text);

        if (response.containsKey('error') || response.containsKey('message')) {
          throw response['error'] ?? response['message'];
        }

        // Check if user is archived
        if (response['user']['isArchived'] == true) {
          throw 'This account has been archived. Please contact your administrator.';
        }

        // Check if user type is valid
        final userType = response['user']['userType'];
        if (!['nurse', 'nutritionist', 'relative'].contains(userType)) {
          throw 'Invalid user type. Access denied.';
        }

        // Save user ID to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', response['user']['id']);
        await prefs.setString('userRole', response['user']['userType']);
        await prefs.setString('userEmail', response['user']['email']);
        await prefs.setString('userName', response['user']['fullName']);

        if (kDebugMode) {
          print('Saved userId: ${response['user']['id']}');
          print('Saved userRole: ${response['user']['userType']}');
          print('Saved userEmail: ${response['user']['email']}');
          print('Saved userName: ${response['user']['fullName']}');
        }
      } else {
        // Handle registration
        if (!['nurse', 'nutritionist', 'relative']
            .contains(_selectedUserType)) {
          throw 'Invalid user type. Only nurses, nutritionists, and relatives can register.';
        }

        response = await registerUser(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
          _phoneController.text,
          _selectedUserType!,
        );

        if (response.containsKey('error') || response.containsKey('message')) {
          throw response['error'] ?? response['message'];
        }

        // After successful registration, automatically save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', response['user']['id']);
        await prefs.setString('userRole', response['user']['userType']);
        await prefs.setString('userEmail', response['user']['email']);
        await prefs.setString('userName', response['user']['fullName']);

        if (kDebugMode) {
          print('Saved new user data:');
          print('userId: ${response['user']['id']}');
          print('userRole: ${response['user']['userType']}');
          print('userEmail: ${response['user']['email']}');
          print('userName: ${response['user']['fullName']}');
        }
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLogin ? 'Successfully logged in!' : 'Successfully registered!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate based on user role
        final userRole = response['user']['userType'].toString().toLowerCase();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (userRole == 'nurse') {
                return const DashboardScreen();
              } else {
                return const ContactsListScreen();
              }
            },
          ),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

// Also update _validateForm to include email validation:
  bool _validateForm() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return false;
    }

    // Basic email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(_emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return false;
    }

    if (!isLogin) {
      if (_fullNameController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your full name';
        });
        return false;
      }

      if (_phoneController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your phone number';
        });
        return false;
      }
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE3F2FD).withOpacity(0.9),
              const Color(0xFFE8EAF6).withOpacity(0.9),
              const Color(0xFFF3E5F5).withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 60,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and Title
                      _buildLogoAndTitle(),
                      const SizedBox(height: 40),

                      // Error Message
                      if (_errorMessage != null) _buildErrorMessage(),

                      // Form Fields
                      _buildFormFields(),
                      const SizedBox(height: 32),

                      // Submit Button
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        // Just the SVG without container
        SvgPicture.asset(
          'assets/Health.svg',
          width: 120,
          height: 120,
        ),
        const SizedBox(height: 24),
        // Gradient Text for LIFEEC
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.cyan[500]!,
              Colors.blue[600]!,
            ],
          ).createShader(bounds),
          child: Text(
            'LIFEEC',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Professional Elderly Care System',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  color: Colors.red[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          if (!isLogin) ...[
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: !showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () => setState(() => showPassword = !showPassword),
            ),
          ),
          if (!isLogin) ...[
            const SizedBox(height: 16),
            _buildDropdownField(),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: Colors.cyan[500], size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedUserType,
      style: GoogleFonts.poppins(
        color: Colors.black87,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: 'Role',
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: Icon(Icons.work_outline, color: Colors.blue[700], size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'nurse',
          child: Text('Nurse'),
        ),
        DropdownMenuItem(
          value: 'nutritionist',
          child: Text('Nutritionist'),
        ),
        DropdownMenuItem(
          value: 'relative',
          child: Text('Family Member/Relative'),
        ),
      ],
      onChanged: (value) => setState(() => _selectedUserType = value),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyan[500]!,
              Colors.blue[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isLogin ? 'Sign In' : 'Sign Up',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
