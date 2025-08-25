import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/providers/library_provider.dart';
import 'package:lib_app/screens/library/addLibrary.dart';
import 'package:lib_app/screens/library/editLibrary.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Libraries extends StatefulWidget {
  final bool? isNavigation;
  const Libraries({super.key, this.isNavigation});

  @override
  State<Libraries> createState() => _LibrariesState();
}

class _LibrariesState extends State<Libraries> {
  String? currentLibraryId;
  String? currentLibraryName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeLibraries();
  }

  Future<void> _initializeLibraries() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    currentLibraryName = prefs.getString('currentLibraryName');

    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    await libraryProvider.loadlibraries(FirebaseAuth.instance.currentUser!.uid);

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _selectLibrary(library) async {
    setState(() {
      isLoading = true;
      currentLibraryId = library.id;
      currentLibraryName = library.name;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentLibraryName', library.name ?? '');
    await prefs.setString('currentLibraryId', library.id ?? '');

    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    await libraryProvider.loadlibraries(FirebaseAuth.instance.currentUser!.uid);

    Fluttertoast.showToast(
      msg: "Library selected: ${library.name}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.successColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = Provider.of<LibraryProvider>(context);
    final libraries = libraryProvider.librarys;

    return Scaffold(
      appBar:
          (widget.isNavigation ?? false)
              ? AppAppBar(title: 'View Libraries')
              : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddLibrary()),
            ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : libraries.isEmpty
              ? Center(
                child: Text(
                  'No Libraries Found (Add One)',
                  style: AppTextStyles.bodyTitleText(AppColors.primaryColor),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: RefreshIndicator(
                  onRefresh: _initializeLibraries,
                  child: ListView.builder(
                    itemCount: libraries.length,
                    itemBuilder: (context, index) {
                      final library = libraries[index];
                      final isActive = library.id == currentLibraryId;

                      return GestureDetector(
                        onTap: () => _selectLibrary(library),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 20.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? AppColors.primaryColor.withOpacity(0.08)
                                    : AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isActive
                                      ? AppColors.primaryColor
                                      : const Color(0x0D000000),
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              // Row with name + Active badge
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffe6e8f6),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            size: 15,
                                            Icons.library_books,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.6,
                                        child: Text(
                                          library.name ?? '',
                                          style: AppTextStyles.bodyTitleText(
                                            AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Active badge with animation
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder:
                                        (child, animation) => ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                    child:
                                        isActive
                                            ? Container(
                                              key: ValueKey(
                                                "active-${library.id}",
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child:
                                                  (isLoading &&
                                                          currentLibraryId ==
                                                              library.id)
                                                      ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                      : Text(
                                                        'Active',
                                                        style:
                                                            AppTextStyles.smallText(
                                                              Colors.white,
                                                            ),
                                                      ),
                                            )
                                            : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: const Color(0x0D000000),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                library.address ?? '',

                                style: AppTextStyles.bodyText(
                                  AppColors.grey800Color,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      text: "Edit",
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      onPressed:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => EditLibrary(
                                                    libraryModel: library,
                                                  ),
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppButton(
                                      text: "Delete",
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      onPressed:
                                          () => _showMyDialog(library.id!),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }

  Future<void> _showMyDialog(String id) async {
    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return isLoading
            ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
            : AlertDialog(
              backgroundColor: AppColors.backgroundBlueColor,
              title: Text(
                'Delete Library',
                style: AppTextStyles.appbarTitleText(AppColors.primaryColor),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'This Library will be deleted',
                      style: AppTextStyles.bodyText(Colors.black),
                    ),
                    Text(
                      'Would you like to delete this Library?',
                      style: AppTextStyles.bodyText(Colors.black),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                  onPressed: () async {
                    setState(() => isLoading = true);
                    if (currentLibraryId == id) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('currentLibraryName', 'null');
                      await prefs.setString('currentLibraryId', 'null');
                    }
                    await libraryProvider.deletelibrary(
                      FirebaseAuth.instance.currentUser!.uid,
                      id,
                    );

                    if (!mounted) return;
                    AppSnackbar.showSnackbar(
                      context,
                      'Library Deleted Successfully',
                      AppColors.errorColor,
                    );
                    setState(() => isLoading = false);

                    if (mounted) Navigator.of(context).pop();
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
