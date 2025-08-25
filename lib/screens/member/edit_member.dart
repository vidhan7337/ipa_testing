import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/models/seat_model.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/providers/plan_provider.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:lib_app/utils/Drop_down_text_field.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/date_picker.dart';
import 'package:lib_app/utils/date_picker_text_field.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditMember extends StatefulWidget {
  final MemberModel? member;
  const EditMember({super.key, required this.member});

  @override
  State<EditMember> createState() => _EditMemberState();
}

class _EditMemberState extends State<EditMember> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _seatIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  String? currentLibraryId;
  List<String> _availableSeats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (!mounted) return;

    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    await planProvider.loadPlans(FirebaseAuth.instance.currentUser!.uid);

    final seatProvider = Provider.of<SeatProvider>(context, listen: false);
    await seatProvider.loadseats(currentLibraryId!);

    _availableSeats =
        seatProvider.availableSeats.map((seat) => seat.seatId!).toList();
    if (widget.member?.seatId != null &&
        !_availableSeats.contains(widget.member!.seatId)) {
      _availableSeats.add(widget.member!.seatId!);
    }

    _idController.text = widget.member?.id ?? '';
    _nameController.text = widget.member?.name ?? '';
    _emailController.text = widget.member?.email ?? '';
    _phoneController.text = widget.member?.phone ?? '';
    _addressController.text = widget.member?.address ?? '';
    _selectedGender = widget.member?.gender;
    _dobController.text =
        widget.member?.dateOfBirth != null
            ? formatDate(widget.member!.dateOfBirth!)
            : '';
    _seatIdController.text = widget.member?.seatId ?? '';

    setState(() => _isLoading = false);
  }

  Future<void> editMember() async {
    setState(() => _isLoading = true);

    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedGender == null ||
        _seatIdController.text.isEmpty) {
      AppSnackbar.showSnackbar(
        context,
        'Please fill all the required fields',
        AppColors.errorColor,
      );
      setState(() => _isLoading = false);
      return;
    }

    final seatProvider = Provider.of<SeatProvider>(context, listen: false);

    if (_seatIdController.text != widget.member?.seatId) {
      // Unbook previous seat if not rotational
      if (widget.member?.seatId != 'Rotational Seat') {
        _updateSeatBooking(
          seatProvider,
          widget.member?.seatId,
          false,
          null,
          null,
          false,
        );
      }
      // Book new seat
      _updateSeatBooking(
        seatProvider,
        _seatIdController.text,
        true,
        widget.member?.id,
        widget.member?.planEndDate,
        false,
      );
      widget.member?.seatId = _seatIdController.text;
    }

    widget.member?.name = _nameController.text;
    widget.member?.email =
        _emailController.text.isNotEmpty ? _emailController.text : null;
    widget.member?.phone = _phoneController.text;
    widget.member?.address =
        _addressController.text.isNotEmpty ? _addressController.text : null;
    widget.member?.gender = _selectedGender;
    widget.member?.dateOfBirth =
        _dobController.text.isEmpty
            ? null
            : DateFormat('dd-MM-yyyy').parse(_dobController.text);

    if (!mounted) return;
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.updatemember(widget.member!, currentLibraryId!);

    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'Member updated successfully',
      AppColors.successColor,
    );
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  Future<void> _updateSeatBooking(
    SeatProvider seatProvider,
    String? seatId,
    bool isBooked,
    String? memberId,
    DateTime? expirationDate,
    bool? isNoticed,
  ) async {
    if (seatId == null || seatId == 'Rotational Seat') return;
    String? series;
    int? seatNumber;
    if (seatId.contains('_')) {
      var parts = seatId.split('_');
      if (parts.length == 2) {
        series = parts[0];
        seatNumber = int.tryParse(parts[1]);
      }
    }
    final seat = SeatModel(
      seatId: seatId,
      seatNumber: seatNumber,
      series: series,
      isBooked: isBooked,
      memberId: memberId,
      expirationDate: expirationDate,
      isNoticed: isNoticed ?? false,
    );
    await seatProvider.updateseat(currentLibraryId!, seat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Edit Member'),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _idController,
                          hintText: 'Member ID',
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _nameController,
                          hintText: 'Member Name',
                          keyboardType: TextInputType.name,
                          validator: validateName,
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _emailController,
                          hintText: 'Email (optional)',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _phoneController,
                          hintText: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: validatePhone,
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _addressController,
                          hintText: 'Address (Optional)',
                          keyboardType: TextInputType.streetAddress,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        FormField<String>(
                          validator:
                              (_) =>
                                  _selectedGender == null
                                      ? 'Please select a gender'
                                      : null,
                          builder: (formFieldState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Gender :',
                                      style: AppTextStyles.subBodyText(
                                        AppColors.grey500Color,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ...['Male', 'Female'].map(
                                      (gender) => Row(
                                        children: [
                                          Radio<String>(
                                            fillColor:
                                                MaterialStateProperty.all(
                                                  AppColors.primaryColor,
                                                ),
                                            value: gender,
                                            groupValue: _selectedGender,
                                            onChanged: (value) {
                                              setState(
                                                () => _selectedGender = value!,
                                              );
                                              formFieldState.didChange(value);
                                            },
                                          ),
                                          Text(
                                            gender,
                                            style: AppTextStyles.subBodyText(
                                              AppColors.grey500Color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (formFieldState.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      top: 4,
                                    ),
                                    child: Text(
                                      formFieldState.errorText ?? '',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        DatePickerTextField(
                          controller: _dobController,
                          hintText: 'Date of Birth',
                          onTap: () async {
                            DateTime? pickedDate = await showAppDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dobController.text = formatDate(pickedDate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (widget.member!.isActive! &&
                            widget.member!.seatId != "Rotational Seat")
                          DropDownTextField(
                            hintText: "Select Seat",
                            value:
                                _availableSeats.contains(_seatIdController.text)
                                    ? _seatIdController.text
                                    : null,
                            Item:
                                _availableSeats
                                    .map(
                                      (seat) => DropdownMenuItem<String>(
                                        value: seat,
                                        child: Text(seat),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) => setState(
                                  () => _seatIdController.text = value!,
                                ),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a seat'
                                        : null,
                          ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: "Update member",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              editMember();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
