part of 'students_cubit.dart';

@immutable
sealed class StudentsState {}

class StudentsInitial extends StudentsState {}

class StudentsSearchUpdatedState extends StudentsState {}