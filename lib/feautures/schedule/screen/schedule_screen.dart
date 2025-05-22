import 'package:flutter/material.dart';
import 'package:richzspot/feautures/schedule/widgets/calender_widget.dart';
import 'package:richzspot/feautures/schedule/widgets/event_card_widget.dart';
import '../styles/schedule_styles.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Schedule Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: const Text(
                    'Schedule',
                    style: ScheduleStyles.headerStyle,
                  ),
                ),

                // Calendar Widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CalendarWidget(),
                ),

                // Upcoming Events Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming Events',
                        style: ScheduleStyles.sectionHeaderStyle,
                      ),
                      const SizedBox(height: 20),
                      // Event Cards
                      EventCard(
                        time: '09:00 AM - 10:00 AM',
                        title: 'Team Stand-up Meeting',
                        location: 'Conference Room A',
                        iconData: Icons.people, // Gunakan IconData
                        locationIconData: Icons.location_on, // Gunakan IconData
                        iconColor: Colors.blueAccent, // Atur warna icon
                      ),
                      const SizedBox(height: 12),
                      EventCard(
                        time: '11:30 AM - 12:30 PM',
                        title: 'Project Review',
                        location: 'Virtual Meeting Room',
                        iconData: Icons.assessment,
                        locationIconData: Icons.link,
                        iconColor: Colors.orangeAccent,
                      ),
                      const SizedBox(height: 12),
                      EventCard(
                        time: '02:00 PM - 03:30 PM',
                        title: 'Client Presentation',
                        location: 'Main Board Room',
                        iconData: Icons.present_to_all,
                        locationIconData: Icons.room,
                        iconColor: Colors.greenAccent[700]!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}