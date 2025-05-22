import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/leave/service/leave_service.dart';
import 'package:richzspot/feautures/leave/widgets/absence_history_cart.dart';
import 'package:richzspot/feautures/leave/widgets/leave_application_form.dart';
import 'package:richzspot/feautures/leave/widgets/leave_balance.dart';
import 'package:richzspot/feautures/time_off/service/timeoff_application_form.dart';
import 'package:richzspot/feautures/time_off/service/timeoff_service.dart';
import 'package:richzspot/feautures/time_off/widgets/timeoff_history_cart.dart';

class TimeOffScreen extends StatefulWidget {
  const TimeOffScreen({Key? key}) : super(key: key);

  @override
  State<TimeOffScreen> createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {
  List<dynamic> timeOff = [];
  

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchtimeOff();
  }

  Future<void> _fetchtimeOff() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await AppStorage.getUser();
    final userId = prefs?['user_id']; // Replace 'user_id' with your actual key

    if (userId != null) {
      try {
        final data = await TimeOffService.getTimeOffRequestsByUserId(userId);
        setState(() {
          timeOff = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        // Handle error appropriately, e.g., show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch Time Off history: $e')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            // padding: const EdgeInsets.symmetric(vertical: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new) 
                    ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Time Off Management',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                ),
                  ],
                ),
                const LeaveBalanceCard(),
                const SizedBox(height: 24),
                TimeOffApplicationForm(onCall: _fetchtimeOff),
                const SizedBox(height: 24),
                isLoading ? Center(child: CircularProgressIndicator(color: AppColors.primary,),) :
                TimeOffHistorySection(leaveData: timeOff),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
