import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return photo?.path;
    } catch (_) {
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image?.path;
    } catch (_) {
      return null;
    }
  }
}
