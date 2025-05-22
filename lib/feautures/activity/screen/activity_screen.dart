// lib/feautures/activity/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:richzspot/feautures/activity/widgets/activity_timeline.dart';
import 'package:richzspot/feautures/activity/widgets/activity_tab.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Today', 'Yesterday', 'This Week', 'Last Week'];

  // Data aktivitas dummy (ganti dengan data dari API Anda)
  // Untuk setiap tab, Anda akan memuat data yang berbeda
  List<Map<String, dynamic>> _todayActivities = [
    {'time': '9:00 AM', 'title': 'Check-in', 'icon': Icons.arrow_forward}, // Contoh icon
    {'time': '12:00 PM', 'title': 'Project Review', 'icon': Icons.loop},
    {'time': '1:30 PM', 'title': 'Break End', 'icon': Icons.access_time},
    {'time': '2:00 PM', 'title': 'Team Meeting', 'icon': Icons.group},
    {'time': '6:00 PM', 'title': 'Check-out', 'icon': Icons.arrow_back},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          // constraints: const BoxConstraints(maxWidth: 480), // Hapus jika tidak ada batasan lebar layar
          // margin: const EdgeInsets.symmetric(horizontal: 16), // Padding di sini akan duplikat dengan Padding widget di bawah
          child: Column(
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
                Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // Padding kiri-kanan untuk teks judul
                  vertical: 21,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600, // Sedikit lebih tebal dari W400
                    ),
                  ),
                ),
              ),
              
                  ],
                ),
              // Judul "Activity"
              // Area Tabs
              Container(
                // Warna latar belakang keseluruhan baris tab
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, // Padding kiri-kanan untuk konten di dalam container ini
                  vertical: 12,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _tabs.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActivityTab(
                          label: _tabs[index],
                          isSelected: _selectedTabIndex == index,
                          onTap: () => setState(() {
                            _selectedTabIndex = index;
                            // Di sini Anda akan memuat data aktivitas yang sesuai dengan tab yang dipilih
                            // Contoh: _loadActivitiesForTab(index);
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Konten Timeline Aktivitas
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, // Padding kiri-kanan untuk timeline
                    vertical: 24,
                  ),
                  child: Column(
                    children: List.generate(_todayActivities.length, (index) {
                      final activity = _todayActivities[index];
                      final isLastItem = index == _todayActivities.length - 1;
                      return ActivityTimelineItem(
                        time: activity['time'] as String,
                        title: activity['title'] as String,
                        icon: activity['icon'] as IconData,
                        isLast: isLastItem, // Tandai item terakhir
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}