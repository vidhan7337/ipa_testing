// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lib_app/models/seat_model.dart';
// import 'package:lib_app/providers/expense_provider.dart';
// import 'package:lib_app/providers/invoice_provider.dart';
// import 'package:lib_app/providers/member_provider.dart';
// import 'package:lib_app/providers/plan_provider.dart';
// import 'package:lib_app/providers/seat_provider.dart';
// import 'package:lib_app/screens/expense/view_expense.dart';
// import 'package:lib_app/screens/follow_up.dart';
// import 'package:lib_app/screens/inovice/view_invoice.dart';
// import 'package:lib_app/screens/member/add_member.dart';
// import 'package:lib_app/screens/member/view_member.dart';
// import 'package:lib_app/screens/seat/view_seats.dart';
// import 'package:lib_app/utils/drawer.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
//   String? currentLibraryId;
//   String? currentLibraryName;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() async {
//       final prefs = await SharedPreferences.getInstance();
//       currentLibraryId = prefs.getString('currentLibraryId');
//       currentLibraryName = prefs.getString('currentLibraryName');
//       final seatProvider = Provider.of<SeatProvider>(context, listen: false);
//       final memberProvider = Provider.of<MemberProvider>(
//         context,
//         listen: false,
//       );
//       final expenseProvider = Provider.of<ExpenseProvider>(
//         context,
//         listen: false,
//       );
//       final planProvider = Provider.of<PlanProvider>(context, listen: false);
//       final invoiceProvider = Provider.of<InvoiceProvider>(
//         context,
//         listen: false,
//       );
//       await expenseProvider.loadexpenses(currentUserId!, currentLibraryId!);
//       await planProvider.loadPlans(currentUserId!);
//       await invoiceProvider.loadinvoices(currentUserId!, currentLibraryId!);
//       await seatProvider.loadseats(currentUserId!, currentLibraryId!);
//       await memberProvider.loadmembers(currentUserId!, currentLibraryId!);

//       for (var member in memberProvider.members) {
//         if (member.planEndDate!.difference(DateTime.now()).inDays == 0) {
//           if (member.isActive == true) {
//             member.isActive = false;
//             final seat = SeatModel(
//               seatId: member.seatId,
//               seatNumber: member.seatId != null ? int.parse(member.seatId!) : 0,
//               isBooked: false,
//               memberId: null,
//               libraryId: currentLibraryId,
//             );
//             await seatProvider.updateseat(
//               currentUserId!,
//               currentLibraryId!,
//               seat,
//             );
//             member.seatId = null;
//             await memberProvider.updatemember(
//               currentUserId!,
//               member,
//               currentLibraryId!,
//             );
//           }
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final seatProvider = Provider.of<SeatProvider>(context);
//     final memberProvider = Provider.of<MemberProvider>(context);
//     final planProvider = Provider.of<PlanProvider>(context);
//     final expenseProvider = Provider.of<ExpenseProvider>(context);
//     var screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(screenHeight * 0.05),
//           child: Container(
//             height: screenHeight * 0.05,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(30),
//                 topRight: Radius.circular(30),
//               ),
//             ),
//             child: SizedBox(),
//           ),
//         ),
//         title: Text(
//           style: TextStyle(fontFamily: 'Inter'),
//           currentLibraryName == 'null'
//               ? 'Select Library'
//               : '$currentLibraryName',
//         ),
//         backgroundColor: Color(0xFF3629B7),
//       ),
//       drawer: AppDrawer(),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: GridView.count(
//           crossAxisCount: 3,
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 5,
//           childAspectRatio: 0.8,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewSeats();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: SizedBox(
//                   height: screenHeight * 0.2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           FontAwesomeIcons.chair,
//                           size: 28,
//                           color: Color(0xFF3629B7),
//                         ),
//                         SizedBox(height: 5),
//                         Text(
//                           'Total Seats',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Color(0xFF979797),
//                             overflow: TextOverflow.clip,
//                           ),
//                         ),
//                         Text(
//                           seatProvider.totalSeats.toString(),
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF343434),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewSeats();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.chair,
//                         size: 28,
//                         color: Color(0xFF52D5BA),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Available Seats',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         seatProvider.totalAvailableSeats.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewSeats();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.chair,
//                         size: 28,
//                         color: Color(0xFFFF4267),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Booked Seats',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         seatProvider.totalBookedSeats.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewMember();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.userLarge,
//                         size: 28,
//                         color: Color(0xFF3629B7),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Total Members',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         memberProvider.membersCount.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewMember();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.userLarge,
//                         size: 28,
//                         color: Color(0xFF52D5BA),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Active Members',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         memberProvider.activeMembersCount.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewMember();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.userLarge,
//                         size: 28,
//                         color: Color(0xFFFF4267),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Expired Members',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         memberProvider.inactiveMembersCount.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewInvoices();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.moneyCheck,
//                         size: 28,
//                         color: Color(0xFF3629B7),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Total Amount',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         memberProvider.totalpayment.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewInvoices();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.moneyCheck,
//                         size: 28,
//                         color: Color(0xFF52D5BA),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Paid Amount',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         memberProvider.totalPaidAmt.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewInvoices();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.moneyCheck,
//                         size: 28,
//                         color: Color(0xFFFF4267),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Amount Due',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         memberProvider.totalDueAmt.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const Viewexpenses();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.bookBookmark,
//                         size: 28,
//                         color: Color(0xFFFF4267),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Expenses',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         expenseProvider.totalExpense.toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const ViewInvoices();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.bookBookmark,
//                         size: 28,
//                         color: Color(0xFFFF4267),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Earnings',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         '${memberProvider.totalpayment - expenseProvider.totalExpense}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const FollowUp();
//                     },
//                   ),
//                 );
//               },
//               child: Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.all(5.0),
//                 shadowColor: Color(0xFF979797),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         FontAwesomeIcons.bookBookmark,
//                         size: 28,
//                         color: Color(0xFFFF4267),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         'Follow Up Members',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF979797),
//                           overflow: TextOverflow.clip,
//                         ),
//                       ),
//                       Text(
//                         memberProvider.membersWithPlanEndingSoonCount
//                             .toString(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF343434),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Color(0xFF3629B7),
//         foregroundColor: Colors.white,
//         onPressed: () {
//           if (seatProvider.totalSeats == 0 || planProvider.plans.isEmpty) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Please add seats and plan first'),
//                 duration: Duration(seconds: 2),
//               ),
//             );
//             return;
//           }
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddMember()),
//           );
//         },
//         child: Icon(FontAwesomeIcons.userPlus),
//       ),
//     );
//   }
// }
