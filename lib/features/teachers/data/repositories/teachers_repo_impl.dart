import '../../domain/repositories/teachers_repo.dart';
import '../data_sources/teachers_remote_repo.dart';

class TeachersRepoImpl implements TeachersRepo {
  final TeachersRemoteRepo remoteRepo;

  TeachersRepoImpl(this.remoteRepo);

  // Implement repository methods here
}
