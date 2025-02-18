import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String userId;
  final String email;

  const OTPVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  OTPVerificationScreenState createState() => OTPVerificationScreenState();
}

class OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> verifyOTP() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print('Verifying OTP');
        print('User ID: ${widget.userId}');
        print('OTP: ${_otpController.text}');
      }

      final response = await http.post(
        Uri.parse('https://lifeec-mobile-1.onrender.com/api/users/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'otp': _otpController.text,
        }),
      );

      if (kDebugMode) {
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', widget.userId);
        await prefs.setString('userEmail', data['user']['email']);
        await prefs.setString('userName', data['user']['fullName']);
        await prefs.setString('userRole', data['user']['userType']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate based on user type
          final userType = data['user']['userType'];
          Navigator.pushReplacementNamed(context,
              userType.toLowerCase() == 'nurse' ? '/dashboard' : '/contacts');
        }
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Verification failed';
        });

        if (kDebugMode) {
          print('Verification Error: $errorMessage');
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error during verification: $e';
      });

      if (kDebugMode) {
        print('Verification Exception: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendOTP() async {
    try {
      if (kDebugMode) {
        print('Attempting to resend OTP');
        print('User ID: ${widget.userId}');
      }

      final response = await http.post(
        Uri.parse('https://lifeec-mobile-1.onrender.com/api/users/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
        }),
      );

      if (kDebugMode) {
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      final data = json.decode(response.body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Unknown response'),
            backgroundColor:
                response.statusCode == 200 ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Resend OTP Catch Error: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error resending OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please enter the 6-digit code sent to:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                widget.email,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Verify Email'),
              ),
              TextButton(
                onPressed: resendOTP,
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
