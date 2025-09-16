import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'teacher_call_state.dart';

class TeacherCallCubit extends Cubit<TeacherCallState> {
  TeacherCallCubit() : super(TeacherCallInitial());
}
