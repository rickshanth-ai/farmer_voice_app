import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'l10n/app_localizations.dart';

void main() {
  runApp(const AgriVisionApp());
}

// ============================================================
// APP
// ============================================================

class AgriVisionApp extends StatefulWidget {
  const AgriVisionApp({super.key});

  @override
  State<AgriVisionApp> createState() => _AgriVisionAppState();
}

class _AgriVisionAppState extends State<AgriVisionApp> {
  Locale _locale = const Locale('en');

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Agri Vision',

      // Current selected language
      locale: _locale,

      // Available languages
      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
      ],

      // Flutter localization
      localizationsDelegates:
          AppLocalizations.localizationsDelegates,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        scaffoldBackgroundColor:
            const Color(0xFFF9FBF5),
      ),

      home: HomeScreen(
        onLanguageChanged: changeLanguage,
        currentLocale: _locale,
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  final void Function(Locale) onLanguageChanged;
  final Locale currentLocale;

  const HomeScreen({
    super.key,
    required this.onLanguageChanged,
    required this.currentLocale,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText speech = stt.SpeechToText();

  bool isListening = false;
  String recognizedText = '';

  // ==========================================================
  // START VOICE
  // ==========================================================

  Future<void> startVoice() async {
    final bool available = await speech.initialize();

    if (!available) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.speechUnavailable,
          ),
        ),
      );

      return;
    }

    setState(() {
      isListening = true;
      recognizedText = '';
    });

    String? localeId;

    if (widget.currentLocale.languageCode == 'ta') {
      localeId = 'ta_IN';
    } else {
      localeId = 'en_US';
    }

    await speech.listen(
      localeId: localeId,
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          recognizedText = result.recognizedWords;
        });
      },
    );
  }

  // ==========================================================
  // STOP VOICE
  // ==========================================================

  Future<void> stopVoice() async {
    await speech.stop();

    if (!mounted) return;

    setState(() {
      isListening = false;
    });
  }

  // ==========================================================
  // OPEN SCAN SCREEN
  // ==========================================================

  void openScanScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanScreen(),
      ),
    );
  }

  // ==========================================================
  // ABOUT APP
  // ==========================================================

  void showAboutApp() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.aboutApp),
          content: Text(
            l10n.aboutDescription,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // LANGUAGE MENU
  // ==========================================================

  void showLanguageMenu() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: Colors.green,
                  ),
                  title: Text(
                    l10n.english,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  trailing:
                      widget.currentLocale.languageCode == 'en'
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                  onTap: () {
                    Navigator.pop(context);

                    widget.onLanguageChanged(
                      const Locale('en'),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: Colors.green,
                  ),
                  title: Text(
                    l10n.tamil,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  trailing:
                      widget.currentLocale.languageCode == 'ta'
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                  onTap: () {
                    Navigator.pop(context);

                    widget.onLanguageChanged(
                      const Locale('ta'),
                    );
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          IconButton(
            onPressed: showLanguageMenu,
            tooltip: l10n.language,
            icon: const Icon(
              Icons.language,
              color: Colors.green,
              size: 28,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // =================================================
              // LOGO
              // =================================================

              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 80,
                  color: Colors.green.shade600,
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // APP NAME
              // =================================================

              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                l10n.smartFarmingAssistant,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 45),

              // =================================================
              // VOICE BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  onPressed: isListening
                      ? stopVoice
                      : startVoice,
                  icon: Icon(
                    isListening
                        ? Icons.stop
                        : Icons.mic,
                    size: 30,
                  ),
                  label: Text(
                    isListening
                        ? l10n.stopListening
                        : l10n.startVoice,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green.shade50,
                    foregroundColor:
                        Colors.green.shade800,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(35),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // SCAN CROP
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 65,
                child: OutlinedButton.icon(
                  onPressed: openScanScreen,
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: 30,
                    color: Colors.green.shade700,
                  ),
                  label: Text(
                    l10n.scanCrop,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.green.shade400,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(35),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // ABOUT
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: showAboutApp,
                  icon: Icon(
                    Icons.info_outline,
                    size: 28,
                    color: Colors.green.shade700,
                  ),
                  label: Text(
                    l10n.aboutApp,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.grey.shade500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(35),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // VOICE RESULT
              // =================================================

              if (recognizedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 15,
                        offset: Offset(0, 5),
                        color: Color(0x15000000),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.youSaid,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        recognizedText,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              recognizedText = '';
                            });
                          },
                          child: Text(l10n.clear),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SCAN SCREEN
// ============================================================

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker picker = ImagePicker();

  XFile? selectedImage;
  bool isAnalyzing = false;

  // ==========================================================
  // CAMERA
  // ==========================================================

  Future<void> takePhoto() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .cameraError,
          ),
        ),
      );
    }
  }

  // ==========================================================
  // GALLERY
  // ==========================================================

  Future<void> chooseFromGallery() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          selectedImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .galleryError,
          ),
        ),
      );
    }
  }

  // ==========================================================
  // AI ANALYSIS
  // ==========================================================

  Future<void> analyzeImage() async {
    final l10n = AppLocalizations.of(context)!;

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.selectImageFirst,
          ),
        ),
      );

      return;
    }

    setState(() {
      isAnalyzing = true;
    });

    // Temporary AI processing delay.
    // Later actual AI model/API connect pannalam.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      isAnalyzing = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.aiAnalysis),
          content: Text(
            l10n.analysisPlaceholder,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // REMOVE IMAGE
  // ==========================================================

  void removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.cropScan,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // =================================================
              // ICON
              // =================================================

              const Icon(
                Icons.eco,
                size: 70,
                color: Colors.green,
              ),

              const SizedBox(height: 15),

              // =================================================
              // TITLE
              // =================================================

              Text(
                l10n.scanYourCrop,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                l10n.cropInstruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // IMAGE PREVIEW
              // =================================================

              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 1.5,
                  ),
                ),
                child: selectedImage == null
                    ? Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 80,
                            color:
                                Colors.green.shade300,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            l10n.noImageSelected,
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(25),
                        child: Image.file(
                          File(selectedImage!.path),
                          width: double.infinity,
                          height: 320,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // CAMERA + GALLERY
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: takePhoto,
                      icon: const Icon(
                        Icons.camera_alt,
                      ),
                      label: Text(
                        l10n.camera,
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        minimumSize:
                            const Size(0, 55),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          chooseFromGallery,
                      icon: const Icon(
                        Icons.photo_library,
                      ),
                      label: Text(
                        l10n.gallery,
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        minimumSize:
                            const Size(0, 55),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // REMOVE IMAGE
              // =================================================

              if (selectedImage != null)
                TextButton.icon(
                  onPressed: removeImage,
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: Text(
                    l10n.removeImage,
                  ),
                ),

              const SizedBox(height: 10),

              // =================================================
              // ANALYZE BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: isAnalyzing
                      ? null
                      : analyzeImage,
                  icon: isAnalyzing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.psychology,
                          size: 28,
                        ),
                  label: Text(
                    isAnalyzing
                        ? l10n.analyzing
                        : l10n.analyzeCrop,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // INFORMATION
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        l10n.scanTip,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}