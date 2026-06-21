// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import '../../core/models/course.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/services/auth_service.dart';
// import 'package:intl/intl.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:universal_html/html.dart' as html;
//
// class CertificateScreen extends StatefulWidget {
//   final Course course;
//   const CertificateScreen({super.key, required this.course});
//
//   @override
//   State<CertificateScreen> createState() => _CertificateScreenState();
// }
//
// class _CertificateScreenState extends State<CertificateScreen> {
//   final ScreenshotController _screenshotController = ScreenshotController();
//   bool _isSaving = false;
//
//   Future<void> _downloadCertificate() async {
//     setState(() => _isSaving = true);
//     try {
//       final Uint8List? image = await _screenshotController.capture(
//         delay: const Duration(milliseconds: 100),
//         pixelRatio: 3.0, // High quality for both web and mobile
//       );
//
//       if (image == null) throw Exception("Failed to capture certificate image");
//
//       if (kIsWeb) {
//         // Web Download Logic
//         final blob = html.Blob([image]);
//         final url = html.Url.createObjectUrlFromBlob(blob);
//         final anchor = html.AnchorElement(href: url)
//           ..setAttribute("download", "Certificate_${widget.course.title.replaceAll(' ', '_')}.png")
//           ..click();
//         html.Url.revokeObjectUrl(url);
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Certificate download started! 🎓"), backgroundColor: Colors.green),
//           );
//         }
//       } else {
//         // Mobile Save Logic
//         if (await Permission.storage.request().isGranted || await Permission.photos.request().isGranted) {
//           final result = await ImageGallerySaver.saveImage(
//             image,
//             quality: 100,
//             name: "Certificate_${widget.course.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}",
//           );
//
//           if (mounted) {
//             if (result['isSuccess']) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Certificate saved to gallery! 🎓"), backgroundColor: Colors.green),
//               );
//             } else {
//               throw Exception("Failed to save image to gallery");
//             }
//           }
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Permission denied to save certificate.")),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error saving certificate: $e")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = AuthService().currentUser;
//     final String studentName = user?.userMetadata?['full_name'] ?? 'Scholar';
//     final String date = DateFormat('MMMM dd, yyyy').format(DateTime.now());
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F5),
//       appBar: AppBar(
//         title: const Text("Your Achievement", style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.primaryDark,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//           child: Column(
//             children: [
//               FittedBox(
//                 child: Screenshot(
//                   controller: _screenshotController,
//                   child: Container(
//                     width: 800,
//                     height: 560,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))
//                       ],
//                     ),
//                     child: Stack(
//                       children: [
//                         Positioned.fill(
//                           child: CustomPaint(
//                             painter: CertificateBorderPainter(),
//                           ),
//                         ),
//
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // Header Logo
//                               const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.school, color: AppColors.primary, size: 36),
//                                   SizedBox(width: 12),
//                                   Text(
//                                     "CLARITY LEARNING",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w900,
//                                       color: AppColors.primary,
//                                       letterSpacing: 2
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 30),
//
//                               const Text(
//                                 "CERTIFICATE OF COMPLETION",
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF1A1A1A),
//                                   letterSpacing: 4,
//                                 ),
//                               ),
//                               const SizedBox(height: 15),
//                               const Text(
//                                 "This is to officially recognize that",
//                                 style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
//                               ),
//                               const SizedBox(height: 20),
//                               Text(
//                                 studentName.toUpperCase(),
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontSize: 48,
//                                   fontWeight: FontWeight.w900,
//                                   color: AppColors.primaryDark,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Container(height: 1.5, width: 400, color: AppColors.primary.withOpacity(0.3)),
//                               const SizedBox(height: 25),
//                               const Text(
//                                 "has successfully completed all requirements for",
//                                 style: TextStyle(fontSize: 14, color: Colors.grey),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 widget.course.title,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.primary,
//                                 ),
//                               ),
//                               const SizedBox(height: 40),
//
//                               // Footer
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   _buildSignature("Date Issued", date),
//                                   // Authenticity Seal
//                                   Container(
//                                     width: 80,
//                                     height: 80,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: Colors.orange.withOpacity(0.1),
//                                       border: Border.all(color: Colors.orange, width: 2),
//                                     ),
//                                     child: const Center(
//                                       child: Icon(Icons.verified_user, color: Colors.orange, size: 40),
//                                     ),
//                                   ),
//                                   _buildSignature("Course Instructor", "Clarity Verified"),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               const Text(
//                 "Congratulations on your achievement!",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "Your hard work has paid off. Download your certificate below.",
//                 style: TextStyle(color: Colors.black54),
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
//         ),
//         child: ElevatedButton.icon(
//           onPressed: _isSaving ? null : _downloadCertificate,
//           icon: _isSaving
//             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//             : const Icon(Icons.download_rounded),
//           label: Text(
//             _isSaving ? "SAVING..." : "DOWNLOAD CERTIFICATE",
//             style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 18),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             elevation: 0,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSignature(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
//         ),
//         const SizedBox(height: 4),
//         Container(height: 1, width: 150, color: Colors.black26),
//         const SizedBox(height: 4),
//         Text(
//           label.toUpperCase(),
//           style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
//         ),
//       ],
//     );
//   }
// }
//
// class CertificateBorderPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = AppColors.primary
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 12;
//
//     // Outer thick border
//     canvas.drawRect(Offset.zero & size, paint);
//
//     // Inner thin border
//     paint.strokeWidth = 1.5;
//     paint.color = AppColors.primary.withValues(alpha: 0.2);
//     canvas.drawRect(
//       Rect.fromLTWH(15, 15, size.width - 30, size.height - 30),
//       paint,
//     );
//
//     // Corner Accents
//     final accentPaint = Paint()
//       ..color = AppColors.primary
//       ..style = PaintingStyle.fill;
//
//     const double s = 45;
//     canvas.drawRect(const Rect.fromLTWH(0, 0, s, s), accentPaint);
//     canvas.drawRect(Rect.fromLTWH(size.width - s, 0, s, s), accentPaint);
//     canvas.drawRect(Rect.fromLTWH(0, size.height - s, s, s), accentPaint);
//     canvas.drawRect(Rect.fromLTWH(size.width - s, size.height - s, s, s), accentPaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/models/course.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class CertificateScreen extends StatefulWidget {
  final Course course;

  const CertificateScreen({
    super.key,
    required this.course,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final ScreenshotController _screenshotController =
  ScreenshotController();

  bool _isSaving = false;

  Future<void> _downloadCertificate() async {
    setState(() => _isSaving = true);

    try {
      final Uint8List? image =
      await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (image == null) {
        throw Exception(
          "Failed to capture certificate image",
        );
      }

      if (kIsWeb) {
        final blob = html.Blob([image]);

        final url =
        html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
            "download",
            "Certificate_${widget.course.title.replaceAll(' ', '_')}.png",
          )
          ..click();

        html.Url.revokeObjectUrl(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Certificate download started! 🎓",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        bool granted = false;

        if (await Permission.photos.isGranted ||
            await Permission.storage.isGranted) {
          granted = true;
        } else {
          final storage =
          await Permission.storage.request();

          final photos =
          await Permission.photos.request();

          granted =
              storage.isGranted || photos.isGranted;
        }

        if (!granted) {
          throw Exception(
            "Permission denied to save certificate",
          );
        }

        await Gal.putImageBytes(
          image,
          name:
          "Certificate_${widget.course.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Certificate saved to gallery! 🎓",
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("Error saving certificate: $e"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    final String studentName =
        user?.userMetadata?['full_name'] ??
            'Scholar';

    final String date = DateFormat(
      'MMMM dd, yyyy',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Your Achievement",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          child: Column(
            children: [
              FittedBox(
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    width: 800,
                    height: 560,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter:
                            CertificateBorderPainter(),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 40,
                          ),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                                children: [
                                  Icon(
                                    Icons.school,
                                    color:
                                    AppColors.primary,
                                    size: 36,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "CLARITY LEARNING",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.w900,
                                      color: AppColors
                                          .primary,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: 30),
                              const Text(
                                "CERTIFICATE OF COMPLETION",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                  FontWeight.bold,
                                  color:
                                  Color(0xFF1A1A1A),
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(
                                  height: 15),
                              const Text(
                                "This is to officially recognize that",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle:
                                  FontStyle.italic,
                                ),
                              ),
                              const SizedBox(
                                  height: 20),
                              Text(
                                studentName
                                    .toUpperCase(),
                                textAlign:
                                TextAlign.center,
                                style:
                                const TextStyle(
                                  fontSize: 48,
                                  fontWeight:
                                  FontWeight.w900,
                                  color: AppColors
                                      .primaryDark,
                                ),
                              ),
                              const SizedBox(
                                  height: 10),
                              Container(
                                height: 1.5,
                                width: 400,
                                color: AppColors.primary
                                    .withOpacity(0.3),
                              ),
                              const SizedBox(
                                  height: 25),
                              const Text(
                                "has successfully completed all requirements for",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                  height: 10),
                              Text(
                                widget.course.title,
                                textAlign:
                                TextAlign.center,
                                style:
                                const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                  FontWeight.bold,
                                  color:
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(
                                  height: 40),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  _buildSignature(
                                    "Date Issued",
                                    date,
                                  ),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration:
                                    BoxDecoration(
                                      shape: BoxShape
                                          .circle,
                                      color: Colors
                                          .orange
                                          .withOpacity(
                                          0.1),
                                      border: Border.all(
                                        color: Colors
                                            .orange,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons
                                            .verified_user,
                                        color: Colors
                                            .orange,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  _buildSignature(
                                    "Course Instructor",
                                    "Clarity Verified",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Congratulations on your achievement!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your hard work has paid off. Download your certificate below.",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          24,
          12,
          24,
          32,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed:
          _isSaving ? null : _downloadCertificate,
          icon: _isSaving
              ? const SizedBox(
            width: 20,
            height: 20,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.download_rounded,
          ),
          label: Text(
            _isSaving
                ? "SAVING..."
                : "DOWNLOAD CERTIFICATE",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(
              vertical: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSignature(
      String label,
      String value,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          width: 150,
          color: Colors.black26,
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class CertificateBorderPainter
    extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawRect(
      Offset.zero & size,
      paint,
    );

    paint.strokeWidth = 1.5;
    paint.color = AppColors.primary.withOpacity(
      0.2,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        15,
        15,
        size.width - 30,
        size.height - 30,
      ),
      paint,
    );

    final accentPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    const double s = 45;

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, s, s),
      accentPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - s,
        0,
        s,
        s,
      ),
      accentPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height - s,
        s,
        s,
      ),
      accentPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - s,
        size.height - s,
        s,
        s,
      ),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) =>
      false;
}