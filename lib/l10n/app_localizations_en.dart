// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Farmer Voice';

  @override
  String get scanYourCrop => 'Scan Your Crop';

  @override
  String get takeClearPhoto => 'Take a clear photo of the crop leaf';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get analyzeCropWithAI => 'Analyze Crop with AI';

  @override
  String get aiAnalysis => 'AI Analysis';

  @override
  String get imageSuccessfullyCaptured => 'Image successfully captured!';

  @override
  String get ok => 'OK';
}
