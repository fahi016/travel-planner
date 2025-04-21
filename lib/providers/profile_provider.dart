import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class ProfileProvider extends ChangeNotifier {
  static const String _profileBoxName = 'profile';
  late Box<String> _profileBox;
  
  String? _name;
  String? _email;
  File? _profileImage;

  String? get name => _name;
  String? get email => _email;
  File? get profileImage => _profileImage;

  ProfileProvider() {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _profileBox = await Hive.openBox<String>(_profileBoxName);
    _loadProfile();
  }

  void _loadProfile() {
    _name = _profileBox.get('name');
    _email = _profileBox.get('email');
    final imagePath = _profileBox.get('imagePath');
    if (imagePath != null) {
      _profileImage = File(imagePath);
    }
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (name != null) {
      _name = name;
      await _profileBox.put('name', name);
    }
    if (email != null) {
      _email = email;
      await _profileBox.put('email', email);
    }
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      await _profileBox.put('imagePath', pickedFile.path);
      notifyListeners();
    }
  }
} 