
import '../../domain/repositories/home_repo.dart';
import '../data_sources/remote/home_remote_repo.dart';

class HomeRepoImpl extends HomeRepo {
  final HomeRemoteRepo homeRemoteRepo;

  HomeRepoImpl(this.homeRemoteRepo,);


}
