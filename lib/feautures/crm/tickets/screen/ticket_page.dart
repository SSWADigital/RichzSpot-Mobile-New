import 'package:flutter/material.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  String selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom AppBar
          Container(
            padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
                Spacer(),
                Text(
                  'Ticket',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                SizedBox(width: 24), // Agar title tetap di tengah
              ],
            ),
          ),

          // Search Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari tiket...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterTab('All', Colors.blue),
                SizedBox(width: 12),
                _buildFilterTab('Open', Colors.grey),
                SizedBox(width: 12),
                _buildFilterTab('Close', Colors.grey),
                SizedBox(width: 12),
                _buildFilterTab('Confirmation', Colors.grey),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Ticket List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTicketCard(
                  'TK-001',
                  'Masalah Koneksi Internet',
                  'Internet terputus di lantai 3 kantor pusat',
                  'IT Support',
                  '14:20',
                  'Open',
                  Colors.blue,
                ),
                _buildTicketCard(
                  'TK-002',
                  'Printer Tidak Berfungsi',
                  'Printer di ruang marketing tidak bisa mencetak dokumen',
                  'Perangkat Keras',
                  '11:15',
                  'Close',
                  Colors.orange,
                ),
                _buildTicketCard(
                  'TK-003',
                  'Permintaan Software Baru',
                  'Permintaan instalasi Adobe Photoshop untuk tim desain',
                  'Software',
                  '16:45',
                  'Open',
                  Colors.blue,
                ),
                _buildTicketCard(
                  'TK-004',
                  'Penggantian Laptop',
                  'Laptop untuk karyawan baru di departemen keuangan',
                  'Perangkat Keras',
                  '09:20',
                  'Confirmation',
                  Colors.green,
                ),
                _buildTicketCard(
                  'TK-005',
                  'Akses Database',
                  'Permintaan akses ke database pelanggan untuk tim sales',
                  'Keamanan',
                  '13:10',
                  'Confirmation',
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String text, Color color) {
    bool isSelected = text == selectedFilter;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    String ticketId,
    String title,
    String description,
    String category,
    String time,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.confirmation_number, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        ticketId,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      'Hari ini, $time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
