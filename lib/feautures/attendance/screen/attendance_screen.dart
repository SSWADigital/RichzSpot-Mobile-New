import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/attendance/service/attendance_service.dart';
import 'package:richzspot/shared/widgets/back_icon.dart';
import '../widgets/attendance_record_card.dart';
import '../widgets/status_badge.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<dynamic> _allAttendanceRecords = [];
  List<dynamic> _filteredAttendanceRecords = [];
  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreAttendanceHistory();
    }
  }

  Future<void> _fetchAttendanceHistory({String? filter, DateTime? startDate, DateTime? endDate}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await AppStorage.getUser();
      final userId = user?['user_id']?.toString();
      if (userId != null) {
        final data = await AttendanceService.getAttendanceHistory(userId, _currentPage, _limit);
        setState(() {
          if (_currentPage == 1) {
            _allAttendanceRecords = data;
          } else {
            _allAttendanceRecords.addAll(data);
          }
          _filterAttendanceRecords(_selectedFilter, startDate: _startDate, endDate: _endDate);
          _isLoading = false;
          if (data.length < _limit) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch attendance history: $e')),
      );
    }
  }

  Future<void> _loadMoreAttendanceHistory() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await _fetchAttendanceHistory(filter: _selectedFilter, startDate: _startDate, endDate: _endDate);
  }

  void _handleFilterTabClick(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filteredAttendanceRecords = [];
      _currentPage = 1;
      _hasMore = true;
      _scrollController.jumpTo(0);
      _fetchAttendanceHistory(filter: filter, startDate: _startDate, endDate: _endDate);
    });
  }

  void _filterAttendanceRecords(String filter, {DateTime? startDate, DateTime? endDate}) {
    setState(() {
      _filteredAttendanceRecords = _allAttendanceRecords.where((record) {
        final recordDate = DateTime.parse(record['absen_tanggal']);
        final bool isInRange = (startDate == null || recordDate.isAfter(startDate.subtract(const Duration(days: 1)))) &&
            (endDate == null || recordDate.isBefore(endDate.add(const Duration(days: 1))));

        bool matchesFilter = true;
        if (filter == 'Present') {
          matchesFilter = record['absen_status'] == '2' && (record['absen_checkin'] != null && (record['absen_checkout'] != null || record['absen_status'] == '1'));
        } else if (filter == 'Absent') {
          matchesFilter = record['absen_status'] == '0';
        } else if (filter == 'Late') {
          matchesFilter = record['absen_status'] == '2' && record['absen_checkin'] != null && DateTime.parse(record['absen_checkin']).hour > 8;
        }
        return isInRange && (filter == 'All' || matchesFilter);
      }).toList();
    });
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null ? DateTimeRange(start: _startDate!, end: _endDate!) : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _filteredAttendanceRecords = [];
        _currentPage = 1;
        _hasMore = true;
        _scrollController.jumpTo(0);
        _fetchAttendanceHistory(filter: _selectedFilter, startDate: _startDate, endDate: _endDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF3F4F6),
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackIcon(context: context),
                  const Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF111827),
                      fontFamily: 'Inter',
                    ),
                  ),
                  GestureDetector(
                    onTap: _showDateRangePicker,
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF2D5FDA),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFFF3F4F6),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildFilterTab('All', _selectedFilter == 'All', () => _handleFilterTabClick('All')),
                  _buildFilterTab('Present', _selectedFilter == 'Present', () => _handleFilterTabClick('Present')),
                  _buildFilterTab('Absent', _selectedFilter == 'Absent', () => _handleFilterTabClick('Absent')),
                  _buildFilterTab('Late', _selectedFilter == 'Late', () => _handleFilterTabClick('Late')),
                ],
              ),
            ),
          ),

          // Date Range Display
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Date Range: ${DateFormat('d MMM yyyy').format(_startDate!)} - ${DateFormat('d MMM yyyy').format(_endDate!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

          // Attendance Records List
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ListView.separated(
                controller: _scrollController,
                itemCount: _filteredAttendanceRecords.length + (_isLoading && _filteredAttendanceRecords.isNotEmpty ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index < _filteredAttendanceRecords.length) {
                    final record = _filteredAttendanceRecords[index];
                    AttendanceStatus status = AttendanceStatus.present;
                    if (record['absen_status'] == '0') {
                      status = AttendanceStatus.absent;
                    } else if (record['absen_status'] == '2' &&
                        DateTime.parse(record['absen_checkin']).hour > 8) {
                      status = AttendanceStatus.late;
                    }

                    final checkInTime = record['absen_checkin'] != null
                        ? DateFormat('hh:mm a').format(DateTime.parse(record['absen_checkin']))
                        : null;
                    final checkOutTime = record['absen_checkout'] != null
                        ? DateFormat('hh:mm a').format(DateTime.parse(record['absen_checkout']))
                        : null;
                    final absenDate = record['absen_tanggal'] != null
                        ? DateFormat('EEEE, d MMMM yyyy').format(DateTime.parse(record['absen_tanggal']))
                        : 'N/A';

                    return AttendanceRecordCard(
                      date: absenDate,
                      status: status,
                      checkIn: checkInTime,
                      checkOut: checkOutTime,
                      isMissingCheckOut: record['absen_status'] == '1',
                    );
                  } else if (_isLoading && _filteredAttendanceRecords.isNotEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return null;
                },
              ),
            ),
          ),
          if (_isLoading && _filteredAttendanceRecords.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE6F0FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? const Color(0xFF2D5FDA) : const Color(0xFF4B5563),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }
}