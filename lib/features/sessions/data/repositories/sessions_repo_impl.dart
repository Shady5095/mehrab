import '../../domain/repositories/sessions_repo.dart';
import '../data_sources/sessions_remote_repo.dart';

class SessionsRepoImpl implements SessionsRepo {
  final SessionsRemoteRepo remoteRepo;

  SessionsRepoImpl(this.remoteRepo);

  // Implement repository methods here
}
