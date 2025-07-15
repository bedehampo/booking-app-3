import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../booking_screen.dart';

class PinConfirmationScreen extends StatefulWidget {
  final String expectedPin;
  final String email;
  final String role;

  const PinConfirmationScreen({
    super.key,
    required this.expectedPin,
    required this.email,
    required this.role,
  });

  @override
  State<PinConfirmationScreen> createState() => _PinConfirmationScreenState();
}

class _PinConfirmationScreenState extends State<PinConfirmationScreen> {
  String currentPin = '';
  String? errorMessage;
  bool isVerifying = false;

  void _verifyPin() {
    if (currentPin == widget.expectedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingScreen(role: widget.role),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Incorrect PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the 4-digit PIN sent to your WhatsApp number.'),
              const SizedBox(height: 16),
              PinCodeTextField(
                length: 4,
                appContext: context,
                autoFocus: true,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  activeColor: Colors.deepPurple,
                  selectedColor: Colors.deepPurple.shade300,
                  inactiveColor: Colors.grey.shade400,
                ),
                enableActiveFill: true,
                onChanged: (value) {
                  setState(() {
                    currentPin = value;
                    errorMessage = null; // clear error on input change
                  });
                },
                onCompleted: (value) => _verifyPin(),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: currentPin.length == 4 ? _verifyPin : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Verify PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
