import '../../domain/repositories/my_profile_repo.dart';
import '../data_sources/my_profile_remote_repo.dart';

class MyProfileRepoImpl implements MyProfileRepo {
  final MyProfileRemoteRepo remoteRepo;

  MyProfileRepoImpl(this.remoteRepo);

  // Implement repository methods here
}
