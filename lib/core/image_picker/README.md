# Image Picker

The Image Picker module provides comprehensive image selection, processing, and upload functionality. It includes custom gallery interfaces, media picking utilities, and Firebase Storage integration for seamless image management.

## Folder Structure

```
lib/core/image_picker/
├── upload_image.dart           # Firebase Storage image upload
├── media_picker_utils.dart     # Image picking utilities
├── media_picker_widget.dart    # Custom image picker widget
└── custom_gallery_screen.dart  # Custom gallery interface
```

## Key Components

### 1. Upload Image (`upload_image.dart`)
Firebase Storage integration providing:
- **Image Upload**: Direct upload to Firebase Storage
- **Metadata Support**: Custom metadata attachment
- **URL Generation**: Public download URL creation
- **Error Handling**: Comprehensive upload error management

### 2. Media Picker Utils (`media_picker_utils.dart`)
Utility functions for image operations:
- **Source Selection**: Camera or gallery picking
- **Image Processing**: Resize, crop, and compression
- **Format Conversion**: Image format handling
- **Permission Management**: Camera and storage permissions

### 3. Media Picker Widget (`media_picker_widget.dart`)
Custom image picker UI component:
- **Interactive Interface**: Touch-friendly picker interface
- **Preview Support**: Image preview before selection
- **Multiple Selection**: Single or multi-image picking
- **Custom Styling**: Branded picker appearance

### 4. Custom Gallery Screen (`custom_gallery_screen.dart`)
Full-screen gallery interface:
- **Grid Layout**: Responsive image grid display
- **Image Browser**: Navigate through device images
- **Selection Interface**: Multi-select functionality
- **Search and Filter**: Find specific images

## Usage

### Basic Image Upload
```dart
import '../core/image_picker/upload_image.dart';

final result = await uploadImage(
  imageFile,
  storagePath: 'profile_images',
  fileName: 'user_${userId}_profile',
  userId: currentUser.uid,
  customMetadata: {
    'uploadedBy': currentUser.email,
    'category': 'profile_picture',
  },
);

if (result.isSuccess) {
  final downloadUrl = result.data!;
  // Use the download URL
}
```

### Pick Image from Camera/Gallery
```dart
import '../core/image_picker/media_picker_utils.dart';

// Pick from gallery
final galleryResult = await MediaPickerUtils.pickFromGallery();
if (galleryResult.isSuccess) {
  final imageFile = galleryResult.data!;
  // Process selected image
}

// Pick from camera
final cameraResult = await MediaPickerUtils.pickFromCamera();
if (cameraResult.isSuccess) {
  final imageFile = cameraResult.data!;
  // Process captured image
}
```

### Custom Media Picker Widget
```dart
import '../core/image_picker/media_picker_widget.dart';

MediaPickerWidget(
  onImageSelected: (File imageFile) {
    // Handle selected image
  },
  maxImages: 5,
  allowCamera: true,
  allowGallery: true,
  imageQuality: 80,
)
```

### Custom Gallery Screen
```dart
import '../core/image_picker/custom_gallery_screen.dart';

// Navigate to custom gallery
final selectedImages = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CustomGalleryScreen(
      maxSelection: 3,
      allowMultiple: true,
    ),
  ),
);

if (selectedImages != null) {
  // Process selected images
}
```

## Image Processing Options

### Image Compression
```dart
import '../core/image_picker/media_picker_utils.dart';

final compressedImage = await MediaPickerUtils.compressImage(
  imageFile,
  quality: 70,
  maxWidth: 1920,
  maxHeight: 1080,
);
```

### Image Cropping
```dart
final croppedImage = await MediaPickerUtils.cropImage(
  imageFile,
  aspectRatio: CropAspectRatio.square,
  maxWidth: 512,
  maxHeight: 512,
);
```

### Image Resizing
```dart
final resizedImage = await MediaPickerUtils.resizeImage(
  imageFile,
  width: 300,
  height: 300,
  maintainAspectRatio: true,
);
```

## Firebase Storage Integration

### Upload Configuration
```dart
// Upload with custom path structure
final result = await uploadImage(
  imageFile,
  storagePath: 'users/${userId}/images',
  fileName: 'image_${DateTime.now().millisecondsSinceEpoch}',
  oldImageUrl: previousImageUrl, // Will delete old image
);
```

### Metadata Management
```dart
final result = await uploadImage(
  imageFile,
  storagePath: 'posts/images',
  customMetadata: {
    'contentType': 'image/jpeg',
    'category': 'user_post',
    'uploadedAt': DateTime.now().toIso8601String(),
    'deviceInfo': 'mobile_app',
  },
);
```

### Progress Tracking
```dart
class ImageUploadService {
  static Future<Result<String>> uploadWithProgress(
    File imageFile,
    String storagePath, {
    Function(double)? onProgress,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(storagePath);
    
    final uploadTask = ref.putFile(imageFile);
    
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress?.call(progress);
    });
    
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    return Result.success(downloadUrl);
  }
}
```

## Permission Management

### Check Permissions
```dart
import '../core/image_picker/media_picker_utils.dart';

// Check camera permission
bool hasCameraPermission = await MediaPickerUtils.hasCameraPermission();

// Check storage permission
bool hasStoragePermission = await MediaPickerUtils.hasStoragePermission();
```

### Request Permissions
```dart
// Request camera permission
final cameraGranted = await MediaPickerUtils.requestCameraPermission();

// Request storage permission
final storageGranted = await MediaPickerUtils.requestStoragePermission();

// Request all permissions
final allGranted = await MediaPickerUtils.requestAllPermissions();
```

## Custom UI Components

### Image Preview Widget
```dart
class ImagePreviewWidget extends StatelessWidget {
  final File imageFile;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit),
                  backgroundColor: Colors.black54,
                ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete),
                backgroundColor: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### Multiple Image Picker
```dart
class MultipleImagePicker extends StatefulWidget {
  final int maxImages;
  final Function(List<File>) onImagesSelected;

  @override
  _MultipleImagePickerState createState() => _MultipleImagePickerState();
}

class _MultipleImagePickerState extends State<MultipleImagePicker> {
  List<File> selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == selectedImages.length) {
              return AddImageButton(
                onPressed: _pickImage,
                isEnabled: selectedImages.length < widget.maxImages,
              );
            }
            return ImagePreviewWidget(
              imageFile: selectedImages[index],
              onDelete: () => _removeImage(index),
            );
          },
        ),
      ],
    );
  }

  void _pickImage() async {
    final result = await MediaPickerUtils.pickFromGallery();
    if (result.isSuccess) {
      setState(() {
        selectedImages.add(result.data!);
      });
      widget.onImagesSelected(selectedImages);
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
    widget.onImagesSelected(selectedImages);
  }
}
```

## Image Optimization

### Automatic Compression
```dart
class ImageOptimizer {
  static Future<File> optimizeImage(File imageFile) async {
    // Compress large images
    final fileSize = await imageFile.length();
    if (fileSize > 1024 * 1024) { // > 1MB
      return await MediaPickerUtils.compressImage(
        imageFile,
        quality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );
    }
    
    return imageFile;
  }
  
  static Future<File> optimizeForProfile(File imageFile) async {
    return await MediaPickerUtils.compressImage(
      imageFile,
      quality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
  }
}
```

### Format Conversion
```dart
class ImageConverter {
  static Future<File> convertToJPEG(File imageFile) async {
    // Convert image to JPEG format
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image != null) {
      final jpegBytes = img.encodeJpg(image, quality: 85);
      final convertedFile = File('${imageFile.path}.jpg');
      await convertedFile.writeAsBytes(jpegBytes);
      return convertedFile;
    }
    
    return imageFile;
  }
}
```

## Error Handling

### Common Error Scenarios
- Permission denied by user
- Network issues during upload
- Storage quota exceeded
- Invalid image format
- File size limitations
- Device storage issues

### Error Recovery
```dart
class ImagePickerErrorHandler {
  static void handleError(AppErrorCode error) {
    switch (error) {
      case AppErrorCode.permissionDenied:
        // Guide user to settings
        break;
      case AppErrorCode.networkError:
        // Retry option
        break;
      case AppErrorCode.storageQuotaExceeded:
        // Upgrade storage option
        break;
      default:
        // Generic error handling
        break;
    }
  }
}
```

## Important Notes

- All image operations use the Result pattern for error handling
- Firebase Storage integration provides secure cloud storage
- Automatic image optimization reduces bandwidth usage
- Permission handling ensures proper device access
- Custom UI components follow the app's design system
- Multiple image selection supports various use cases
- Progress tracking provides user feedback during uploads
- Image processing includes compression, cropping, and resizing
- Error handling covers all common failure scenarios
- Memory management prevents app crashes with large images