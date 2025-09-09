import '../../domain/repositories/notifications_repo.dart';
import '../data_sources/notifications_remote_repo.dart';

class NotificationsRepoImpl implements NotificationsRepo {
  final NotificationsRemoteRepo remoteRepo;

  NotificationsRepoImpl(this.remoteRepo);

  // Implement repository methods here
}
