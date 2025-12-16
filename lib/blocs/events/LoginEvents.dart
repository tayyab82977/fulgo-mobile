import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class LoginEvent {}

class LoginButtonPressed extends LoginEvent {
  final String phone;
  final String password;

  LoginButtonPressed({
    required this.phone,
    required this.password,
  });



}
class LoginReset extends LoginEvent {}