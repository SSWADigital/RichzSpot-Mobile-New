import 'package:flutter/material.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/feautures/claim/widgets/custome_input.dart';
import 'package:richzspot/feautures/claim/widgets/receipt_upload.dart';
import '../widgets/custom_text_area.dart';

class AddClaimScreen extends StatefulWidget {
  const AddClaimScreen({Key? key}) : super(key: key);

  @override
  State<AddClaimScreen> createState() => _AddClaimScreenState();
}

class _AddClaimScreenState extends State<AddClaimScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _receiptImage;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _handleSubmit() {
    // Implement submit logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.secondaryText),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: AppColors.input.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text('Add New Claim', style: AppColors.title),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomInputField(
                      label: 'Title',
                      placeholder: 'add title',
                      controller: _titleController,
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      label: 'Amount (IDR)',
                      placeholder: '0',
                      controller: _amountController,
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          'Rp',
                          style: AppColors.input.copyWith(
                            color: AppColors.inputText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      label: 'Date',
                      placeholder: 'DD/MM/YYYY',
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDate,
                      suffix: const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.inputText,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextArea(
                      label: 'Description',
                      placeholder: 'Add description',
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 20),
                    ReceiptUploadWidget(
                      onImageSelected: (String path) {
                        setState(() {
                          _receiptImage = path;
                        });
                      },
                      currentImage: _receiptImage,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.secondaryText),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Submit', style: AppColors.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
