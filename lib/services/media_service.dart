import 'package:photo_manager/photo_manager.dart';
import '../models/media_model.dart';

class MediaService {
  static Future<List<MediaModel>> getAllAudios() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
    );

    final List<AssetEntity> audios = [];
    for (final path in paths) {
      final media = await path.getAssetListPaged(page: 0, size: 200);
      audios.addAll(media);
    }

    return audios.map((audio) => MediaModel(
      id: audio.id,
      title: audio.title ?? 'Unknown',
      duration: audio.videoDuration,
      path: audio.relativePath,
      isVideo: false,
    )).toList();
  }
}
