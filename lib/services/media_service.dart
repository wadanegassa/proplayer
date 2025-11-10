import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  /// Request proper permissions for both Android 13+ and older versions.
  Future<bool> requestPermission() async {
    try {
      // 👇 Add a short delay to ensure Flutter activity is ready before asking permission.
      await Future.delayed(const Duration(milliseconds: 400));

      // 1️⃣ Try PhotoManager first (this internally handles Android 13+ media access)
      final PermissionState result =
          await PhotoManager.requestPermissionExtend();
      if (result.isAuth) return true;

      // 2️⃣ If not granted, fallback using permission_handler
      if (Platform.isAndroid) {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.videos, // READ_MEDIA_VIDEO
          Permission.audio, // READ_MEDIA_AUDIO
          Permission.photos, // READ_MEDIA_IMAGES
          Permission.storage, // Fallback for older Android versions
        ].request();

        // Return true only if all granted
        return statuses.values.any((status) => status.isGranted);
      }

      // 3️⃣ For iOS — PhotoManager already handles permissions
      return result.isAuth;
    } catch (e) {
      // Catch null Activity or Permission errors
      debugPrint("⚠️ Permission request failed: $e");
      return false;
    }
  }

  /// Load audio or video files from the device
  Future<List<AssetEntity>> loadMedia({bool videos = false}) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Permission not granted');
    }

    // 4️⃣ Fetch media paths based on type
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: videos ? RequestType.video : RequestType.audio,
      filterOption: FilterOptionGroup(
        videoOption: videos
            ? FilterOption(
                durationConstraint: DurationConstraint(
                  min: Duration.zero,
                  max: const Duration(hours: 24),
                ),
              )
            : FilterOption(),
        audioOption: !videos
            ? FilterOption(
                durationConstraint: DurationConstraint(
                  min: Duration.zero,
                  max: const Duration(hours: 24),
                ),
              )
            : FilterOption(),
      ),
    );

    final List<AssetEntity> mediaFiles = [];

    // 5️⃣ Get files from each path
    for (final path in paths) {
      final files = await path.getAssetListPaged(page: 0, size: 200);
      mediaFiles.addAll(files);
    }

    return mediaFiles;
  }
}
