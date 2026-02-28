import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw 'Failed to pick image: $e';
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw 'Failed to take photo: $e';
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    required String imageName,
  }) async {
    try {
      // Create a unique file path
      final String filePath = 'users/$userId/verification/$imageName';
      
      // Upload file
      final Reference ref = _storage.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete image: $e';
    }
  }

  // Upload driver verification images
  Future<Map<String, String>> uploadVerificationImages({
    required String userId,
    required File? licensePlateImage,
    required File? vehicleImage,
  }) async {
    final Map<String, String> imageUrls = {};

    try {
      if (licensePlateImage != null) {
        final licensePlateUrl = await uploadImage(
          imageFile: licensePlateImage,
          userId: userId,
          imageName: 'license_plate_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        imageUrls['licensePlateImageUrl'] = licensePlateUrl;
      }

      if (vehicleImage != null) {
        final vehicleUrl = await uploadImage(
          imageFile: vehicleImage,
          userId: userId,
          imageName: 'vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        imageUrls['vehicleImageUrl'] = vehicleUrl;
      }

      return imageUrls;
    } catch (e) {
      // Clean up any uploaded images if one fails
      if (imageUrls.isNotEmpty) {
        for (var url in imageUrls.values) {
          try {
            await deleteImage(url);
          } catch (_) {}
        }
      }
      rethrow;
    }
  }
}
