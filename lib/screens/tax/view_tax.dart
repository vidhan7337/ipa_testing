import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/providers/tax_provider.dart';
import 'package:lib_app/screens/tax/add_tax.dart';
import 'package:lib_app/screens/tax/edit_tax.dart';
import 'package:provider/provider.dart';

class ViewTaxes extends StatefulWidget {
  const ViewTaxes({super.key});

  @override
  State<ViewTaxes> createState() => _ViewtaxsState();
}

class _ViewtaxsState extends State<ViewTaxes> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final taxProvider = Provider.of<TaxProvider>(context, listen: false);
      taxProvider.loadtaxs(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taxProvider = Provider.of<TaxProvider>(context);
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.07),
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
        title: const Text('View Tax'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTax(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body:
          taxProvider.taxs.length == 0
              ? Center(
                child: Text(
                  'No taxes Available',
                  style: TextStyle(fontSize: 20),
                ),
              )
              : ListView.builder(
                itemCount: taxProvider.taxs.length,
                itemBuilder: (context, index) {
                  final tax = taxProvider.taxs[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tax.name!, style: TextStyle(fontSize: 20)),
                              Text('Rate: ' + tax.percentage!.toString() + "%"),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  taxProvider.deletetax(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    tax.id!,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Tax Deleted'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.delete_forever),
                              ),

                              IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (context) => EditTax(tax: tax),
                                  );
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
