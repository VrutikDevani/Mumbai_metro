import 'package:flutter/material.dart';
import '../models/login_model.dart';

class LoginViewModel with ChangeNotifier {
  final LoginModel _model;

  String _mobileNumber = '';
  String _errorMessage = '';
  bool _isLoading = false;

  LoginViewModel() : _model = LoginModel(mobileNumber: '');

  String get mobileNumber => _mobileNumber;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  /// Set mobile number
  void setMobileNumber(String value) {
    _mobileNumber = value;
    _model.mobileNumber = value;
    notifyListeners();
  }

  /// Manually set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Request OTP from API (dummy inside model for now)
  Future<void> requestOTP() async {
    if (_mobileNumber.isEmpty || _mobileNumber.length != 10) {
      _errorMessage = 'Please enter a valid 10-digit mobile number';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      bool success = await _model.requestOTP();
      if (success) {
        _errorMessage = 'OTP sent successfully!';
      } else {
        _errorMessage = 'Failed to send OTP. Try again.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Make a phone call
  Future<void> makeCall(String phoneNumber) async {
    try {
      await _model.makeCall(phoneNumber);
    } catch (e) {
      _errorMessage = 'Failed to make call. Please try again.';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Reset mobile number
  void clearMobileNumber() {
    _mobileNumber = '';
    _model.mobileNumber = '';
    notifyListeners();
  }
}
