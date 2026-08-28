import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Stores the user's profile photo locally on-device, keyed by user id.
/// Deliberately simple — no backend involved, so picking a new photo can
/// never break the working API layer. The photo is saved to a fixed
/// filename per user, so re-picking overwrites the old one automatically.
class ProfilePhotoService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAndSave(int userId) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last;
    final savedPath = '${dir.path}/profile_photo_$userId.$ext';

    final saved = await File(picked.path).copy(savedPath);
    return saved;
  }

  /// Returns the photo file for this user if one was ever saved, else null.
  static Future<File?> getExisting(int userId) async {
    final dir = await getApplicationDocumentsDirectory();
    // Try common extensions since we don't know which one was used.
    for (final ext in ['jpg', 'jpeg', 'png']) {
      final file = File('${dir.path}/profile_photo_$userId.$ext');
      if (await file.exists()) return file;
    }
    return null;
  }
}
