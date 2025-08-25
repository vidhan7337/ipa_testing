import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:lib_app/screens/member/add_member.dart';
import 'package:lib_app/screens/seat/add_seat.dart';
import 'package:lib_app/screens/seat/remove_seat.dart';
import 'package:lib_app/screens/seat/seat_detail.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/widgets/seatTabContainers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewSeats extends StatefulWidget {
  final bool? isNavigation;
  const ViewSeats({super.key, this.isNavigation});

  @override
  State<ViewSeats> createState() => _ViewSeatsState();
}

class _ViewSeatsState extends State<ViewSeats> {
  String selectedSeries = 'All';
  String? currentLibraryId;
  bool isLoading = false;
  String currentView = 'total';

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _loadLibraryAndSeats();
  }

  Future<void> _loadLibraryAndSeats() async {
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (currentLibraryId == null) {
      setState(() => isLoading = false);
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select a library first.',
        AppColors.errorColor,
      );
      return;
    }
    if (!mounted) return;
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);
    await seatProvider.loadseats(currentLibraryId!);
    if (mounted) setState(() => isLoading = false);
  }

  List<String> _getSeriesList(List seats) => [
    'All',
    ...{
      ...seats
          .map((s) => s.series?.toUpperCase() ?? '')
          .where((s) => s.isNotEmpty),
    },
  ];

  List filteredSeats(List seats) =>
      selectedSeries == 'All'
          ? seats
          : seats
              .where((s) => (s.series?.toUpperCase() ?? '') == selectedSeries)
              .toList();

  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);
    final seriesList = _getSeriesList(seatProvider.seats);

    List getCurrentSeats() {
      switch (currentView) {
        case 'booked':
          return filteredSeats(seatProvider.bookedSeats);
        case 'noticed':
          return filteredSeats(seatProvider.noticedSeats);
        case 'available':
          return filteredSeats(seatProvider.availableSeats);
        default:
          return filteredSeats(seatProvider.seats);
      }
    }

    Widget buildTab(
      String label,
      int count,
      String view, {
      Color? textColor,
      Color? backgroundColor,
    }) {
      return Seattabcontainers(
        textColor: textColor ?? AppColors.grey800Color,
        backgroundColor: backgroundColor ?? AppColors.surfaceColor,
        text: count.toString(),
        onTap: () => setState(() => currentView = view),
      );
    }

    return Scaffold(
      appBar:
          (widget.isNavigation ?? false)
              ? AppAppBar(title: 'View Seats')
              : null,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'addSeat',
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              if (currentLibraryId == null) {
                AppSnackbar.showSnackbar(
                  context,
                  'No library selected. Please select a library first.',
                  AppColors.errorColor,
                );
                return;
              }
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const AddSeat(),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'removeSeat',
            backgroundColor: AppColors.errorColor,
            onPressed: () {
              // Add your logic for the second FAB here
              if (currentLibraryId == null) {
                AppSnackbar.showSnackbar(
                  context,
                  'No library selected. Please select a library first.',
                  AppColors.errorColor,
                );
                return;
              }
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const RemoveSeat(),
              );
            },
            child: const Icon(
              FontAwesomeIcons.minus,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : seatProvider.seats.isEmpty
              ? Center(
                child: Text(
                  'No Seats Available',
                  style: AppTextStyles.bodyTitleText(AppColors.primaryColor),
                ),
              )
              : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    isLoading = true;
                  });
                  _loadLibraryAndSeats();
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Series Dropdown
                            Row(
                              children: [
                                Text(
                                  "Series:",
                                  style: AppTextStyles.bodyText(
                                    AppColors.grey800Color,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: selectedSeries,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(8),
                                    dropdownColor: Colors.white,
                                    style: AppTextStyles.bodyTitleText2(
                                      AppColors.grey900Color,
                                    ),
                                    selectedItemBuilder:
                                        (context) =>
                                            seriesList
                                                .map(
                                                  (s) => Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      s,
                                                      style:
                                                          AppTextStyles.bodyTitleText2(
                                                            AppColors
                                                                .grey900Color,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                    items:
                                        seriesList
                                            .map(
                                              (s) => DropdownMenuItem(
                                                value: s,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        selectedSeries == s
                                                            ? AppColors
                                                                .primaryColor
                                                                .withOpacity(
                                                                  0.1,
                                                                )
                                                            : Colors
                                                                .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 8,
                                                      ),
                                                  child: Text(
                                                    s,
                                                    style:
                                                        AppTextStyles.bodyTitleText2(
                                                          selectedSeries == s
                                                              ? AppColors
                                                                  .primaryColor
                                                              : AppColors
                                                                  .grey900Color,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (val) {
                                      if (val != null)
                                        setState(() => selectedSeries = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                for (final label in [
                                  'Total',
                                  'Allotted',
                                  'Notice',
                                  'Available',
                                ])
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: AppTextStyles.bodyText(
                                          AppColors.grey800Color,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                buildTab(
                                  'Total',
                                  filteredSeats(seatProvider.seats).length,
                                  'total',
                                ),
                                const SizedBox(width: 10),
                                buildTab(
                                  'Allotted',
                                  filteredSeats(
                                    seatProvider.bookedSeats,
                                  ).length,
                                  'booked',
                                  textColor: Colors.white,
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 10),
                                buildTab(
                                  'Notice',
                                  filteredSeats(
                                    seatProvider.noticedSeats,
                                  ).length,
                                  'noticed',
                                  textColor: Colors.white,
                                  backgroundColor: AppColors.errorColor,
                                ),
                                const SizedBox(width: 10),
                                buildTab(
                                  'Available',
                                  filteredSeats(
                                    seatProvider.availableSeats,
                                  ).length,
                                  'available',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: getCurrentSeats().length,
                          itemBuilder: (context, index) {
                            final seat = getCurrentSeats()[index];
                            return GestureDetector(
                              onTap: () {
                                if (seat.isBooked == false &&
                                    seat.isNoticed == false) {
                                  _showMyDialog(seat.seatId!);
                                } else {
                                  showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder:
                                        (context) => SeatDetail(
                                          seat: seat,
                                          memberId: seat.memberId,
                                        ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          seat.isNoticed == true
                                              ? AppColors.errorColor
                                              : seat.isBooked == true
                                              ? AppColors.primaryColor
                                              : AppColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0x0d000000),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/chair_icon.svg',
                                        color:
                                            (seat.isNoticed == true ||
                                                    seat.isBooked == true)
                                                ? Colors.white
                                                : AppColors.grey800Color,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    seat.fullSeatNumber,
                                    style: AppTextStyles.bodySmallSemiBoldText(
                                      AppColors.grey600Color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<void> _showMyDialog(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundBlueColor,
          title: Text(
            'Empty Seat',
            style: AppTextStyles.appbarTitleText(AppColors.primaryColor),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'This Seat is Empty',
                  style: AppTextStyles.bodyText(Colors.black),
                ),
                Text(
                  'Would you like to add new member to this seat?',
                  style: AppTextStyles.bodyText(Colors.black),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMember(seatId: id),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
