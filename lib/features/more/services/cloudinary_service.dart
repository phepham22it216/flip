import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_database_service.dart';
import 'auth_service.dart';

class CloudinaryService {
  final String cloudName = "durunggg4"; // fixed here
  final String uploadPreset = "flip_flutter"; // fixed here

  // Upload cho Android/iOS
  Future<String?> uploadFile(File file) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"); // fixed here
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      return data['secure_url']; // fixed here
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }

  // Upload cho Web
  Future<String?> uploadBytes(Uint8List bytes, String filename) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"); // fixed here
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      return data['secure_url']; // fixed here
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }
}

class AvatarService {
  final AuthService _authService; // fixed here
  final CloudinaryService _cloudinary = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  AvatarService(this._authService);

  Future<void> pickAndUploadAvatar() async {
    try {
      XFile? pickedFile;
      if (kIsWeb) {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile == null) return;

        Uint8List bytes = await pickedFile.readAsBytes();
        final url = await _cloudinary.uploadBytes(bytes, pickedFile.name);
        if (url != null) {
          await _authService.updateAvatar(url); // fixed here
        }
      } else {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile == null) return;

        File file = File(pickedFile.path);
        final url = await _cloudinary.uploadFile(file);
        if (url != null) {
          await _authService.updateAvatar(url); // fixed here
        }
      }
    } catch (e) {
      print("❌ Avatar upload error: $e");
    }
  }
}
