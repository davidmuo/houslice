import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../error/exceptions.dart';

/// Picks photos from the device and puts them somewhere the app can show them
/// again later.
///
/// Split into pick and upload so the UI can show a preview the instant a photo
/// is chosen, and only pay the upload cost when the form is actually submitted.
abstract class PhotoService {
  /// Opens the gallery. Returns local file paths, newest selection first.
  Future<List<String>> pick({int limit});

  /// Uploads a local file and returns a URL that any device can load.
  Future<String> upload(String localPath, {required String folder});

  /// True when [path] is a file on this device that still needs uploading.
  static bool isLocal(String path) =>
      !path.startsWith('http://') &&
      !path.startsWith('https://') &&
      !isInline(path);

  /// True when [path] is an image embedded directly as a data URI.
  static bool isInline(String path) => path.startsWith('data:image');

  /// The raw bytes of an inline data URI.
  static Uint8List decodeInline(String path) =>
      base64Decode(path.substring(path.indexOf(',') + 1));
}

class FirebasePhotoService implements PhotoService {
  final ImagePicker picker;
  final FirebaseStorage storage;

  FirebasePhotoService({ImagePicker? picker, FirebaseStorage? storage})
    : picker = picker ?? ImagePicker(),
      storage = storage ?? FirebaseStorage.instance;

  @override
  Future<List<String>> pick({int limit = 5}) async {
    try {
      final files = await picker.pickMultiImage(
        // Listing photos are shown at most full-width on a phone, so there is
        // no reason to carry a 12-megapixel original through an upload.
        maxWidth: 1600,
        imageQuality: 82,
        limit: limit,
      );
      return files.map((f) => f.path).toList();
    } catch (e) {
      throw ServerException('Could not open your photos: $e');
    }
  }

  @override
  Future<String> upload(String localPath, {required String folder}) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      throw const ServerException('That photo is no longer on the device.');
    }
    try {
      final name = '${DateTime.now().microsecondsSinceEpoch}.jpg';
      final ref = storage.ref().child(folder).child(name);
      await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      // The most common cause by far is Cloud Storage never having been
      // enabled for the project, which surfaces as object-not-found.
      if (e.code == 'object-not-found' || e.code == 'unknown') {
        throw const ServerException(
          'Photo storage is not enabled for this Firebase project yet.',
        );
      }
      throw ServerException(e.message ?? 'Could not upload that photo.');
    }
  }
}

/// Stores photos **inside the Firestore document** as compressed data URIs.
///
/// Cloud Storage requires the Blaze billing plan, which this project is not
/// on. Firestore is available on the free plan, and a document can hold just
/// under 1 MiB — enough for a few aggressively compressed photos. That makes
/// listing photos work on real devices instead of being disabled entirely.
///
/// The trade-off is deliberate and bounded: images are capped at 900px and
/// re-encoded, and [maxBytes] refuses anything that would risk the document
/// limit. This is the right call for a student project on a free tier; a
/// production build would use Cloud Storage and keep only the URL here.
class InlinePhotoService implements PhotoService {
  final ImagePicker picker;

  InlinePhotoService({ImagePicker? picker}) : picker = picker ?? ImagePicker();

  /// Ceiling per photo, before base64 inflates it by roughly a third.
  static const maxBytes = 180 * 1024;

  @override
  Future<List<String>> pick({int limit = 5}) async {
    try {
      final files = await picker.pickMultiImage(
        maxWidth: 900,
        imageQuality: 60,
        limit: limit,
      );
      return files.map((f) => f.path).toList();
    } catch (e) {
      throw ServerException('Could not open your photos: $e');
    }
  }

  @override
  Future<String> upload(String localPath, {required String folder}) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      throw const ServerException('That photo is no longer on the device.');
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) {
      throw const ServerException(
        'That photo is too large. Pick a smaller one, or crop it first.',
      );
    }
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}

/// Demo-mode implementation: picks real photos but keeps them on the device,
/// so the flow works with no backend configured at all.
class LocalPhotoService implements PhotoService {
  final ImagePicker picker;

  LocalPhotoService({ImagePicker? picker}) : picker = picker ?? ImagePicker();

  @override
  Future<List<String>> pick({int limit = 5}) async {
    final files = await picker.pickMultiImage(
      maxWidth: 900,
      imageQuality: 60,
      limit: limit,
    );
    return files.map((f) => f.path).toList();
  }

  @override
  Future<String> upload(String localPath, {required String folder}) async =>
      localPath;
}
