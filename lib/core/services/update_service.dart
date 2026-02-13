import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'update_cache_service.dart';

enum UpdateStatus {
  upToDate,
  updateAvailable,
  error
}

class AppVersionInfo {
  final String version;
  final int build;
  final String downloadUrl;
  final List<String> changelog;

  AppVersionInfo({
    required this.version,
    required this.build,
    required this.downloadUrl,
    required this.changelog,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      version: json['version'] as String,
      build: json['build'] as int,
      downloadUrl: json['download_url'] as String,
      changelog: List<String>.from(json['changelog'] as List),
    );
  }
}

class UpdateCheckResult {
  final UpdateStatus status;
  final AppVersionInfo? newVersion;
  final String? errorMessage;

  UpdateCheckResult({
    required this.status,
    this.newVersion,
    this.errorMessage,
  });
}

class UpdateService {
  final String _versionUrl = 'https://klypt.vercel.app/version.json';
  final UpdateCacheService _cacheService = UpdateCacheService();

  Future<UpdateCheckResult> checkForUpdate({bool isAutoCheck = false}) async {
    if (isAutoCheck) {
      final shouldCheck = await _cacheService.shouldAutoCheck();
      if (!shouldCheck) {
        return UpdateCheckResult(status: UpdateStatus.upToDate);
      }
    }

    try {
      final response = await http.get(Uri.parse(_versionUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final remoteVersion = AppVersionInfo.fromJson(json);
        
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        // Parse build number safely, default to 0 if not present or invalid
        final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

        if (_isNewerVersion(remoteVersion, currentVersion, currentBuild)) {
          // Update the cache only if we successfully checked
          if (isAutoCheck) {
            await _cacheService.saveLastCheckTime();
          }
          return UpdateCheckResult(
            status: UpdateStatus.updateAvailable, 
            newVersion: remoteVersion
          );
        } else {
           if (isAutoCheck) {
            await _cacheService.saveLastCheckTime();
          }
          return UpdateCheckResult(status: UpdateStatus.upToDate);
        }
      } else {
        return UpdateCheckResult(
          status: UpdateStatus.error, 
          errorMessage: 'Server returned ${response.statusCode}'
        );
      }
    } catch (e) {
      // In auto-check mode, we fail silently (log only if needed for debug)
      if (!isAutoCheck) {
        debugPrint('Update check failed: $e');
      }
      return UpdateCheckResult(
        status: UpdateStatus.error, 
        errorMessage: e.toString()
      );
    }
  }

  bool _isNewerVersion(AppVersionInfo remote, String localVersionStr, int localBuild) {
    try {
      // 1. Compare semantic version structure (major.minor.patch)
      // Normalize versions (e.g., 1.0 -> 1.0.0) isn't strictly needed if we assume semver compliance
      // but let's be robust
      List<int> remoteParts = remote.version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> localParts = localVersionStr.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < remoteParts.length && i < localParts.length; i++) {
          if (remoteParts[i] > localParts[i]) return true;
          if (remoteParts[i] < localParts[i]) return false;
      }

      // If one is longer than the other (e.g. 1.2 vs 1.2.1)
      if (remoteParts.length != localParts.length) {
         return remoteParts.length > localParts.length;
      }

      // If versions are equal, check build number
      return remote.build > localBuild;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }
}
