import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/models/tax_model.dart';
import 'package:lib_app/providers/tax_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTax extends StatefulWidget {
  const AddTax({super.key});

  @override
  State<AddTax> createState() => _AddtaxState();
}

class _AddtaxState extends State<AddTax> {
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();

  addtaxData() {
    final name = _nameController.text.trim();
    final rate = double.tryParse(_rateController.text.trim());

    if (name.isEmpty || rate == null) {
      Fluttertoast.showToast(
        msg: "Please fill all fields correctly",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // Assuming you have a taxProvider and a tax model
    final tax = TaxModel(name: name, percentage: rate);
    Provider.of<TaxProvider>(
      context,
      listen: false,
    ).addtax(FirebaseAuth.instance.currentUser!.uid, tax);

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(const SnackBar(content: Text('tax added successfully')));

    Fluttertoast.showToast(
      msg: "Tax added successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    _nameController.clear();
    _rateController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Add Tax"),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tax Name',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your tax name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Percentage',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your tax percentage';
                } else if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                } else if (int.parse(value) < 0 && int.parse(value) > 100) {
                  return 'Please enter a proper percentage';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  addtaxData();
                },
                child: const Text('Add Tax'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
