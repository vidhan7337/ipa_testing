import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lib_app/screens/expense/view_expense.dart';
import 'package:lib_app/screens/inovice/view_invoice.dart';
import 'package:lib_app/screens/member/view_members.dart';
import 'package:lib_app/screens/plan/view_plans.dart';
import 'package:lib_app/screens/seat/view_seats.dart';

class LibraryManagement extends StatelessWidget {
  const LibraryManagement({super.key});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.05),
          child: Container(
            height: screenHeight * 0.05,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SizedBox(),
          ),
        ),
        title: Text('Library Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10, // Number of columns
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ViewSeats();
                    },
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Color(0xFF3629B7), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.chair,
                      color: Color(0xFF3629B7),
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Seats',
                      style: TextStyle(color: Color(0xFF3629B7), fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ViewMembers();
                    },
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Color(0xFF52D5BA), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: Color(0xFF52D5BA), size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Members',
                      style: TextStyle(color: Color(0xFF52D5BA), fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ViewPlans();
                    },
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Color(0xFFFF4267), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money, color: Color(0xFFFF4267), size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Plans',
                      style: TextStyle(color: Color(0xFFFF4267), fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ViewInvoices();
                    },
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Color(0xFF0890FE), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.document_scanner,
                      color: Color(0xFF0890FE),
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Invoices',
                      style: TextStyle(color: Color(0xFF0890FE), fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) {
            //           return const ViewTaxes();
            //         },
            //       ),
            //     );
            //   },
            //   child: Card(
            //     color: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(20),
            //       side: BorderSide(color: Color(0xFFFFAF2A), width: 2),
            //     ),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(Icons.discount, color: Color(0xFFFFAF2A), size: 50),
            //         SizedBox(height: 10),
            //         Text(
            //           'Tax',
            //           style: TextStyle(color: Color(0xFFFFAF2A), fontSize: 18),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Viewexpenses();
                    },
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Color(0xFFFFAF2A), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore, color: Color(0xFFFFAF2A), size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Expense',
                      style: TextStyle(color: Color(0xFFFFAF2A), fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
