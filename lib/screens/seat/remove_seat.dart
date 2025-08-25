import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoveSeat extends StatefulWidget {
  const RemoveSeat({super.key});

  @override
  State<RemoveSeat> createState() => _RemoveSeatState();
}

class _RemoveSeatState extends State<RemoveSeat> {
  bool isLoading = false;
  final _seatNumberController = TextEditingController();
  final _seriesController = TextEditingController(text: 'A');
  String? currentLibraryId;
  String selectedSeries = 'A';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadLibraryId();
  }

  Future<void> _loadLibraryId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLibraryId = prefs.getString('currentLibraryId');
    });
  }

  Future<void> removeSeats() async {
    final seatNumber = int.tryParse(_seatNumberController.text.trim());
    if (seatNumber == null || seatNumber <= 0) {
      _showToast("Please enter a valid number of seats");
      return;
    }
    if (currentLibraryId == null) {
      _showToast("Library ID not found");
      return;
    }
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);
    if (seatProvider.getSeatsBySeries(selectedSeries).isEmpty) {
      _showToast("No seats found in Series $selectedSeries");
      return;
    }
    if (seatNumber > seatProvider.getTotalSeatsBySeries(selectedSeries)) {
      _showToast(
        "Cannot remove more seats than exist in Series $selectedSeries",
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await Provider.of<SeatProvider>(
        context,
        listen: false,
      ).removeSeat(currentLibraryId!, seatNumber, selectedSeries);
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        '$seatNumber seats removed successfully from Series $selectedSeries',
        AppColors.successColor,
      );
      _seatNumberController.clear();
      Navigator.pop(context);
    } catch (_) {
      _showToast("Failed to remove seats. Please try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.errorColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/chair_icon.svg',
                      color: AppColors.grey900Color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remove Seats',
                      style: AppTextStyles.appbarTitleText(
                        AppColors.grey900Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomLLabelTextField(
                        controller: _seriesController,
                        hintText: "Enter seat series (A-Z)",
                        maxLength: 1,
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a seat series';
                          } else if (!RegExp(r'^[A-Za-z]$').hasMatch(value)) {
                            return 'Enter a single letter (A-Z)';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedSeries = value.toUpperCase();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomLLabelTextField(
                        controller: _seatNumberController,
                        hintText: "Enter number of seats",
                        keyboardType: TextInputType.number,
                        validator: validateIntField,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Remove Seats from Series $selectedSeries',
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate()) {
                      removeSeats();
                    }
                  },
                  icon: const Icon(
                    FontAwesomeIcons.minus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _seatNumberController.dispose();
    _seriesController.dispose();
    super.dispose();
  }
}
