import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_app/src/presentation/widgets/custom_button.dart';
import 'package:qr_scanner_app/src/presentation/widgets/custom_snackbar.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late AnimationController _radarAnimationController;
  late Animation<double> _radarAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: true,
    );

    // Animación de línea que sube y baja
    _radarAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _radarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _radarAnimationController, curve: Curves.linear),
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));

    showCustomSnackbar(
      context: context,
      message: 'Código copiado exitosamente',
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
            tooltip: 'Cambiar cámara',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => _controller.toggleTorch(),
            tooltip: 'Linterna',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Escáner QR
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isProcessing) return;

              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;

                if (code != null && code.isNotEmpty) {
                  _isProcessing = true;
                  _controller.stop();

                  final String decodedCode = Uri.decodeComponent(code);

                  if (mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (dialogContext) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Código Escaneado',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (capture.image != null)
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.memory(
                                      capture.image!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SelectableText(
                                    decodedCode,
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          CustomButton(
                            width: 130, 
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  if (mounted) {
                                    _isProcessing = false;
                                    _controller.start();
                                  }
                                },
                              );
                            },
                            text: 'Cerrar',
                            color: Colors.redAccent,
                          ),
                          CustomButton(
                            width: 130, 
                            onPressed: () {
                              _copyToClipboard(decodedCode, dialogContext);
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  if (mounted) {
                                    _isProcessing = false;
                                    _controller.start();
                                  }
                                },
                              );
                            },
                            text: 'Copiar código',
                          ),
                        ],
                        actionsAlignment:
                            MainAxisAlignment.center, 
                        actionsPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    );
                  }
                }
              }
            },
          ),

          // Efecto Radar - Línea horizontal que sube y baja
          IgnorePointer(
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _radarAnimation,
                      builder: (context, child) {
                        final linePosition = _radarAnimation.value * 280;
                        return Positioned(
                          top: linePosition,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  Colors.green.withValues(alpha: 0.3),
                                  Colors.green,
                                  Colors.green.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Texto guía
                    const Positioned(
                      bottom: -30,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Centra el código QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _radarAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
