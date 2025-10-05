import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utilities/functions/dependency_injection.dart';
import '../../data/repositories/prayer_times_repo_impl.dart';
import '../../domain/use_cases/get_loaction_info_use_case.dart';
import '../../domain/use_cases/get_prayer_time_use_case.dart';
import '../manager/prayer_time_cubit.dart';
import '../widgets/prayer_times_screen_body.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create:
          (context) => PrayerTimeCubit(
            getLocationInfoUseCase: GetLocationInfoUseCase(
              getIt<PrayerTimesRepoImpl>(),
            ),
            getPrayerTimeUseCase: GetPrayerTimeUseCase(
              getIt<PrayerTimesRepoImpl>(),
            ),
          )..getPrayerTime(),
      child: const Scaffold(body: PrayerTimesScreenBody()),
    );
  }
}
