import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaService {
  // Key name to remember permission status
  static const String _permissionKey = 'permission_granted';

  // Ask for permission only if not granted before
  Future<bool> requestPermissionOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getBool(_permissionKey) ?? false;

    // If already saved as granted, skip asking
    if (savedStatus) {
      return true;
    }

    // Check system permission
    final status = await Permission.storage.request();

    if (status.isGranted) {
      // Save the success so we never ask again
      await prefs.setBool(_permissionKey, true);
      return true;
    } else {
      // Save false just in case (optional)
      await prefs.setBool(_permissionKey, false);
      return false;
    }
  }

  // Load all media (music/video) after permission granted
  Future<List<AssetEntity>> loadMedia({bool videos = false}) async {
    final hasPermission = await requestPermissionOnce();

    if (!hasPermission) {
      throw Exception('Permission not granted');
    }

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: videos ? RequestType.video : RequestType.audio,
    );

    final List<AssetEntity> mediaFiles = [];
    for (final path in paths) {
      final List<AssetEntity> files = await path.getAssetListPaged(page: 0, size: 100);
      mediaFiles.addAll(files);
    }

    return mediaFiles;
  }
}
