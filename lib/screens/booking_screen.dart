import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon/screens/auth/auth_entry.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.role});
  final String role;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String selectedService = 'Haircut';
  DateTime? selectedDateTime;
  final List<String> services = [
    'Haircut',
    'Makeup',
    'Pedicure',
    'Facial',
    'Massage',
  ];
  final dateFormatter = DateFormat('EEE, MMM d, y');
  final timeFormatter = DateFormat('hh:mm a');

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitBooking() async {
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date and time.')),
      );
      return;
    }

    final booking = {
      'service': selectedService,
      'timestamp': selectedDateTime!.toIso8601String(),
      'status': 'pending',
      'userId': auth.currentUser!.uid,
      'whatsappMessage':
          'Hi, I\'d like to book a $selectedService service on ${dateFormatter.format(selectedDateTime!)} at ${timeFormatter.format(selectedDateTime!)}.',
      'bookingLink':
          'https://dummybookingapp.com/book?service=$selectedService&time=${selectedDateTime!.toIso8601String()}',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore.collection('bookings').add(booking);

    setState(() {
      selectedDateTime = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking submitted!')));
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    await firestore.collection('bookings').doc(bookingId).update({
      'status': status,
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthEntry()),
        );
      }
    }
  }

  DateTime parseTimestamp(dynamic timestampField) {
    if (timestampField is String) {
      return DateTime.parse(timestampField);
    } else if (timestampField is Timestamp) {
      return timestampField.toDate();
    } else {
      throw Exception('Unknown timestamp format');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.role == 'customer';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: Text('${isCustomer ? 'Customer' : 'Vendor'} Booking',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, color: Colors.white,),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isCustomer) ...[
              const Text('Select a Service:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedService,
                    isExpanded: true,
                    onChanged: (value) =>
                        setState(() => selectedService = value!),
                    items: services
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.teal.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDateTime == null
                              ? 'Pick Date & Time'
                              : '${dateFormatter.format(selectedDateTime!)} at ${timeFormatter.format(selectedDateTime!)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitBooking,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Submit Booking',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.teal.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
            const Text(
              'Bookings:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: isCustomer
                    ? firestore
                          .collection('bookings')
                          .where('userId', isEqualTo: auth.currentUser!.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots()
                    : firestore
                          .collection('bookings')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No bookings yet.'));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final booking = docs[index];
                      final data = booking.data()! as Map<String, dynamic>;
                      final date = parseTimestamp(data['timestamp']);
                      final status = data['status'] ?? 'pending';

                      Color statusColor = Colors.orange;
                      IconData statusIcon = Icons.hourglass_top;
                      if (status == 'approved') {
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                      } else if (status == 'rejected') {
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                      }

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(statusIcon, color: Colors.teal),
                          title: Text(data['service'] ?? ''),
                          subtitle: Text(
                            '${dateFormatter.format(date)} at ${timeFormatter.format(date)}\nStatus: $status',
                          ),
                          trailing: !isCustomer && status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => _updateBookingStatus(
                                        booking.id,
                                        'approved',
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _updateBookingStatus(
                                        booking.id,
                                        'rejected',
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
