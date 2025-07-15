import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:uni_links/uni_links.dart'; // Uncomment this when uni_links is ready
import '../booking_screen.dart';
import 'auth_entry.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  StreamSubscription? _sub;
  bool openBookingScreenFromLink = false;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    // Deep linking temporarily disabled for now
    // Uncomment below when uni_links is properly configured
    /*
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }

    _sub = linkStream.listen((link) {
      if (link != null) _handleIncomingLink(link);
    }, onError: (err) {
      print('Link stream error: $err');
    });
    */
  }

  void _handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    print('Deep link received: $link');

    if (uri.scheme == 'salonapp' && uri.host == 'booking') {
      setState(() {
        openBookingScreenFromLink = true;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel(); // safe even if null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const Scaffold(
                  body: Center(child: Text('User data not found.')),
                );
              }

              final role = userSnap.data!.get('role') as String;
              return BookingScreen(role: role);
            },
          );
        } else {
          return const AuthEntry();
        }
      },
    );
  }
}
