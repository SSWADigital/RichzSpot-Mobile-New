import 'package:flutter/material.dart';
import 'package:richzspot/core/storage/app_storage.dart';
import 'package:richzspot/feautures/notification/service/notification_service.dart';
import 'package:richzspot/feautures/payslip/models/salary_slip.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/feautures/payslip/service/payslip_service.dart';
import 'package:intl/intl.dart';

class ApprovalPayslipDetailScreen extends StatefulWidget {
  final SalarySlip salarySlip;
  final VoidCallback? onStatusChanged;

  const ApprovalPayslipDetailScreen({
    Key? key,
    required this.salarySlip,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<ApprovalPayslipDetailScreen> createState() => _ApprovalPayslipDetailScreenState();
}

class _ApprovalPayslipDetailScreenState extends State<ApprovalPayslipDetailScreen> {
  final SalaryService _apiService = SalaryService();
  bool _isLoading = false;
  TextEditingController _keteranganController = TextEditingController();

  // Base Salary tidak akan memiliki controller karena tidak editable
  late TextEditingController _allowancesController;
  late TextEditingController _bonusController;
  late TextEditingController _deductionsController;

  double _netSalary = 0.0;

  @override
  void initState() {
    super.initState();
    // Base Salary akan langsung menggunakan nilai dari widget.salarySlip
    _allowancesController = TextEditingController(text: _formatRupiahInputString((widget.salarySlip.gajiUangMakan ?? 0.0) + (widget.salarySlip.gajiPremiHadir ?? 0.0)));
    _bonusController = TextEditingController(text: _formatRupiahInputString(widget.salarySlip.bonus));
    _deductionsController = TextEditingController(text: _formatRupiahInputString(-((widget.salarySlip.gajiPotongan ?? 0.0) + (widget.salarySlip.gajiBpjsKes ?? 0.0) + (widget.salarySlip.gajiBpjsTk ?? 0.0))));

    _calculateNetSalary();

    // Listener hanya untuk field yang bisa di-edit
    _allowancesController.addListener(_updateAndRecalculate);
    _bonusController.addListener(_updateAndRecalculate);
    _deductionsController.addListener(_updateAndRecalculate);
  }

  // Fungsi untuk memformat double menjadi string rupiah untuk inisialisasi input
  String _formatRupiahInputString(double? value) {
    if (value == null) return '0';
    final NumberFormat numberFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '', // Tidak pakai simbol di dalam TextField
      decimalDigits: 0,
    );
    return numberFormatter.format(value.round()); // Bulatkan dan format
  }

  // Fungsi untuk memformat double menjadi string rupiah untuk tampilan final (Net Salary)
  String _formatRupiahDisplay(double? value) {
    if (value == null) return 'Rp 0';
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(value.round()); // Bulatkan dan format
  }

  // Fungsi untuk mengurai string input rupiah kembali ke double
  double _parseRupiahInput(String text) {
    // Hapus semua karakter non-digit kecuali tanda minus jika di awal
    final cleanText = text.replaceAll(RegExp(r'[^\d-]'), '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  // Fungsi yang dipanggil oleh listener untuk memformat input dan menghitung ulang
  void _updateAndRecalculate() {
    // Menghapus listener sementara untuk menghindari loop tak terbatas saat setel teks
    _allowancesController.removeListener(_updateAndRecalculate);
    _bonusController.removeListener(_updateAndRecalculate);
    _deductionsController.removeListener(_updateAndRecalculate);

    // Memformat ulang teks di controller
    _allowancesController.text = _formatRupiahInputString(_parseRupiahInput(_allowancesController.text));
    _bonusController.text = _formatRupiahInputString(_parseRupiahInput(_bonusController.text));
    _deductionsController.text = _formatRupiahInputString(_parseRupiahInput(_deductionsController.text));

    // Pindahkan kursor ke akhir teks setelah pemformatan
    _allowancesController.selection = TextSelection.fromPosition(TextPosition(offset: _allowancesController.text.length));
    _bonusController.selection = TextSelection.fromPosition(TextPosition(offset: _bonusController.text.length));
    _deductionsController.selection = TextSelection.fromPosition(TextPosition(offset: _deductionsController.text.length));

    // Tambahkan listener kembali
    _allowancesController.addListener(_updateAndRecalculate);
    _bonusController.addListener(_updateAndRecalculate);
    _deductionsController.addListener(_updateAndRecalculate);

    _calculateNetSalary(); // Hitung ulang setelah format dan perubahan
  }


  void _calculateNetSalary() {
    final double baseSalary = widget.salarySlip.gajiPokok ?? 0.0; // Base Salary tidak editable, pakai nilai asli
    final double allowances = _parseRupiahInput(_allowancesController.text);
    final double bonus = _parseRupiahInput(_bonusController.text);
    final double deductions = _parseRupiahInput(_deductionsController.text).abs();

    setState(() {
      _netSalary = baseSalary + allowances + bonus - deductions;
    });
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _allowancesController.dispose();
    _bonusController.dispose();
    _deductionsController.dispose();
    super.dispose();
  }

  Future<void> _showKeteranganDialog(Function(String?) actionType) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keterangan'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _keteranganController,
              decoration: const InputDecoration(
                hintText: 'Masukkan keterangan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                actionType(_keteranganController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleApproveWithData(String? keterangan) async {
    setState(() {
      _isLoading = true;
    });

    final double baseSalary = widget.salarySlip.gajiPokok ?? 0.0; // Ambil nilai asli Base Salary
    final double allowances = _parseRupiahInput(_allowancesController.text);
    final double bonus = _parseRupiahInput(_bonusController.text);
    final double deductions = _parseRupiahInput(_deductionsController.text).abs();

    // Init notification sercice
    final NotificationService notificationService = NotificationService();
    // ambil userId dari local storage
    final user = await AppStorage.getUser();
    final userId = user!['user_id']; 

    // send Notification
    await notificationService.sendFcmNotificationV1(
      userId: userId,
      title: 'Gaji Anda telah disetujui',
      body: 'Gaji Anda untuk periode ${widget.salarySlip.payPeriodFormatted} telah disetujui oleh HRD.',
      type: 'approve_gaji',
      action: 'approve_gaji',
      menu: 'approve_gaji',
      recipientUserId: widget.salarySlip.idUser!,
      additionalData: {
        'gajiId': widget.salarySlip.gajiId,
        'userId': widget.salarySlip.idUser,
        'status': 'approved',
      },
    );

    bool success = await _apiService.approveGaji(
      widget.salarySlip.gajiId,
      keteranganHrd: keterangan,
      gajiPokok: baseSalary, // Kirim Base Salary asli (tidak di-edit)
      gajiUangMakan: allowances,
      bonus: bonus,
      gajiPotongan: deductions,
      totalGaji: _netSalary,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payslip Approved and Updated successfully!')),
      );
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!();
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve payslip.')),
      );
    }
  }

  Future<void> _handleRejectWithData(String? keterangan) async {
    setState(() {
      _isLoading = true;
    });

    final double baseSalary = widget.salarySlip.gajiPokok ?? 0.0; // Ambil nilai asli Base Salary
    final double allowances = _parseRupiahInput(_allowancesController.text);
    final double bonus = _parseRupiahInput(_bonusController.text);
    final double deductions = _parseRupiahInput(_deductionsController.text).abs();

    bool success = await _apiService.rejectGaji(
      widget.salarySlip.gajiId, keterangan
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payslip Rejected and Updated successfully!')),
      );
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!();
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reject payslip.')),
      );
    }
  }

  // Widget pembantu untuk detail item yang BISA DI-EDIT
  Widget _buildEditableDetailCard({
    required String title,
    required TextEditingController controller,
    Color valueColor = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              decoration: const InputDecoration(
                prefixText: 'Rp ', // Simbol Rupiah di TextField
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk detail item yang TIDAK BISA DI-EDIT
  Widget _buildNonEditableDetailCard({
    required String title,
    required String value,
    Color valueColor = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showActionButtons = widget.salarySlip.gajiStatus?.toLowerCase() == 'p';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Payslip Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Employee Info
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.salarySlip.userNamaLengkap ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Employee ID: ${widget.salarySlip.idUser ?? 'N/A'}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Department: ${widget.salarySlip.idDep ?? 'N/A'}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pay Period: ${widget.salarySlip.payPeriodFormatted}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Base Salary (TIDAK BISA DI-EDIT)
                      _buildNonEditableDetailCard(
                        title: 'Base Salary',
                        value: _formatRupiahDisplay(widget.salarySlip.gajiPokok),
                      ),

                      // Allowances (BISA DI-EDIT)
                      _buildEditableDetailCard(
                        title: 'Allowances',
                        controller: _allowancesController,
                      ),
                      // Bonus (BISA DI-EDIT)
                      _buildEditableDetailCard(
                        title: 'Bonus',
                        controller: _bonusController,
                      ),
                      // Deductions (BISA DI-EDIT)
                      _buildEditableDetailCard(
                        title: 'Deductions',
                        controller: _deductionsController,
                        valueColor: Colors.red,
                      ),

                      // Net Salary (TIDAK BISA DI-EDIT)
                      _buildNonEditableDetailCard(
                        title: 'Net Salary',
                        value: _formatRupiahDisplay(_netSalary),
                      ),
                    ],
                  ),
                ),
              ),
              if (showActionButtons)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _showKeteranganDialog(_handleRejectWithData),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.red)
                              : const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _showKeteranganDialog(_handleApproveWithData),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}