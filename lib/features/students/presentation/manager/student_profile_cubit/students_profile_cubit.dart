import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/students/presentation/manager/student_profile_cubit/students_profile_state.dart';


class StudentsProfileCubit extends Cubit<StudentsProfileState> {
  StudentsProfileCubit() : super(StudentsInitial());

  static StudentsProfileCubit get(context) => BlocProvider.of(context);
}
