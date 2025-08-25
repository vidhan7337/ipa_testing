import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/invoice_model.dart';
import 'package:lib_app/providers/library_provider.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfPreviewPage extends StatefulWidget {
  final InvoiceModel? invoiceData;
  const PdfPreviewPage({super.key, required this.invoiceData});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  String? libraryName;
  String? libraryAddress;
  String? libraryLogo;
  String? currentLibraryId;
  pw.MemoryImage? image;
  bool isLoading = false;
  String? uploadedPdfUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      currentLibraryId = prefs.getString('currentLibraryId');
      if (!mounted || currentLibraryId == null) return;

      final libraryProvider = Provider.of<LibraryProvider>(
        context,
        listen: false,
      );
      await libraryProvider.loadlibraries(
        FirebaseAuth.instance.currentUser!.uid,
      );

      final libraryData = libraryProvider.getlibrary(
        FirebaseAuth.instance.currentUser!.uid,
        currentLibraryId!,
      );

      libraryName = libraryData.name;
      libraryAddress = libraryData.address;
      libraryLogo = libraryData.logoUrl;

      // Fetch logo
      if (libraryLogo != null && libraryLogo!.isNotEmpty) {
        final response = await http.get(Uri.parse(libraryLogo!));
        if (response.statusCode == 200) {
          image = pw.MemoryImage(response.bodyBytes);
        }
      }
      setState(() => isLoading = false);
      // Generate and upload PDF when page loads
      final pdfData = await generatePdf(PdfPageFormat.a4);
      await uploadPdfToFirebase(pdfData);
    } catch (e) {
      AppSnackbar.showSnackbar(
        context,
        'Initialization failed: $e',
        AppColors.errorColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> uploadPdfToFirebase(Uint8List pdfData) async {
    setState(() => isUploading = true);
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName =
          'invoices/${currentLibraryId!}/${widget.invoiceData?.seatId}/${widget.invoiceData?.memberName}/${widget.invoiceData?.id}.pdf';
      final pdfRef = storageRef.child(fileName);

      final uploadTask = pdfRef.putData(
        pdfData,
        SettableMetadata(contentType: 'application/pdf'),
      );

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        uploadedPdfUrl = downloadUrl;
      });
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          'PDF uploaded successfully',
          AppColors.successColor,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          'Failed to upload PDF: $e',
          AppColors.errorColor,
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _saveAndNotify(Uint8List pdfData) async {
    if (uploadedPdfUrl == null) {
      AppSnackbar.showSnackbar(
        context,
        'PDF not uploaded yet. Please wait...',
        AppColors.errorColor,
      );
      return;
    }
    await savePdfFile(pdfData);
    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'PDF saved successfully',
      AppColors.successColor,
    );
    Navigator.pop(context);
  }

  Future<void> _shareOnWhatsApp() async {
    if (uploadedPdfUrl == null) {
      AppSnackbar.showSnackbar(
        context,
        'PDF not uploaded yet. Please wait...',
        AppColors.errorColor,
      );
      return;
    }

    try {
      final shortUrlResponse = await http.get(
        Uri.parse('https://tinyurl.com/api-create.php?url=$uploadedPdfUrl'),
      );
      final shortUrl =
          shortUrlResponse.statusCode == 200
              ? shortUrlResponse.body
              : uploadedPdfUrl;

      final memberPhone = "91${widget.invoiceData?.memberPhone}";
      if (memberPhone.isNotEmpty) {
        final whatsappUrl = Uri.parse(
          "https://wa.me/$memberPhone?text=Here%20is%20your%20invoice:%20$shortUrl",
        );
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        } else {
          AppSnackbar.showSnackbar(
            context,
            'Could not open WhatsApp',
            AppColors.errorColor,
          );
        }
      }
    } catch (e) {
      AppSnackbar.showSnackbar(
        context,
        'Failed to share on WhatsApp: $e',
        AppColors.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: "PDF Preview"),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : PdfPreview(
                actionBarTheme: const PdfActionBarTheme(
                  backgroundColor: AppColors.primaryColor,
                ),
                build: (format) => generatePdf(format),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.done),
                    onPressed: () async {
                      final pdfData = await generatePdf(PdfPageFormat.a4);
                      await _saveAndNotify(pdfData);
                    },
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.whatsapp),
                    onPressed: _shareOnWhatsApp,
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      final pdfData = await generatePdf(PdfPageFormat.a4);
                      await _saveAndNotify(pdfData);
                    },
                  ),
                ],
              ),
    );
  }

  Future<Uint8List> generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Container(
                padding: const pw.EdgeInsets.all(50),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex("#F5F7FF"),
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey400, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "INVOICE",
                      style: pw.TextStyle(
                        fontSize: 30,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#1E40AF"),
                      ),
                    ),
                    pw.SizedBox(
                      width: 200,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              if (image != null)
                                pw.Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const pw.BoxDecoration(
                                    shape: pw.BoxShape.circle,
                                  ),
                                  child: pw.Image(image!, fit: pw.BoxFit.cover),
                                ),
                              pw.SizedBox(width: 8),
                              pw.SizedBox(
                                width: 150,
                                child: pw.Text(
                                  libraryName ?? "Library Name",
                                  overflow: pw.TextOverflow.clip,
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            libraryAddress ?? "",
                            overflow: pw.TextOverflow.clip,
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // INVOICE INFO
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 50),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(
                      width: 300,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Name : ${widget.invoiceData?.memberName ?? ""}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: PdfColor.fromHex("#212121"),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "Phone : +91${widget.invoiceData?.memberPhone ?? ""}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: PdfColor.fromHex("#616161"),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "Seat No : ${widget.invoiceData?.seatId ?? ""}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: PdfColor.fromHex("#616161"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(
                      width: 200,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Date: ${formatDate(widget.invoiceData?.date)}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: PdfColor.fromHex("#212121"),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "Member ID : ${widget.invoiceData?.memberId ?? ""}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: PdfColor.fromHex("#616161"),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "Invoice ID: ${widget.invoiceData?.id ?? ""}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: PdfColor.fromHex("#616161"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey400, thickness: 2),

              // MEMBERSHIP DETAILS
              pw.SizedBox(height: 30),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 50),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Membership Details:",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                        color: PdfColor.fromHex("#212121"),
                      ),
                    ),
                    pw.SizedBox(height: 15),

                    _buildInfoTable({
                      'Start Date':
                          widget.invoiceData?.startDate?.toString().split(
                            ' ',
                          )[0] ??
                          '',
                      'End Date':
                          widget.invoiceData?.endDate?.toString().split(
                            ' ',
                          )[0] ??
                          '',
                      'Mode Of Payment':
                          widget.invoiceData?.paymentMethod ?? '',
                      'Total Amount':
                          widget.invoiceData?.total.toString() ?? '',
                      'Amount Paid':
                          widget.invoiceData?.amountPaid.toString() ?? '',
                      'Amount Due':
                          widget.invoiceData?.amountDue.toString() ?? '',
                    }),

                    pw.SizedBox(height: 24),

                    // TERMS & CONDITIONS
                    pw.Text(
                      "Terms & conditions:",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Bullet(text: "Lorem ipsum dolor sit amet consectetur."),
                    pw.Bullet(text: "In augue est sed interdum nunc tristique"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> savePdfFile(Uint8List pdfData) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/my_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(pdfData);
  }

  pw.Widget _buildInfoTable(Map<String, String> data) {
    final rows = data.entries.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xff616161), width: 1),
      columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(5)},
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: List.generate(rows.length, (index) {
        final entry = rows[index];
        final bgColor =
            index.isEven ? PdfColor.fromInt(0xfff5f7ff) : PdfColors.white;

        return pw.TableRow(
          decoration: pw.BoxDecoration(color: bgColor),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              child: pw.Text(
                '${entry.key}:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColor.fromInt(0xff212121),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              child: pw.Text(
                entry.value,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColor.fromInt(0xff616161),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
