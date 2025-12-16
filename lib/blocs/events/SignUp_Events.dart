import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';

abstract class SignUpEvents extends Equatable {}

class RegisterButtonPressed extends SignUpEvents {

  final String firstName;
  final String lastName;
  final String password;
  final String phone ;
  final String name ;
  final String national_id ;
  final String vatNumber ;
  final String companyName ;



  RegisterButtonPressed({
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.name,
    required this.national_id,
    required this.vatNumber,
    required this.companyName,

  });

  @override
  List<Object> get props => [lastName, password , phone , firstName , name , vatNumber , companyName];


}