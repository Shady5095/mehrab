import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/prayer_times_entity.dart';
import '../manager/prayer_time_cubit.dart';
import 'build_now_prayer_next_prayer.dart';
import 'build_prayer_table_time.dart';
import 'build_sunrise_widget.dart';
import 'build_upper_date_selection.dart';

class PrayerTimesScreenBody extends StatefulWidget {
  const PrayerTimesScreenBody({super.key});

  @override
  State<PrayerTimesScreenBody> createState() => _PrayerTimesScreenBodyState();
}

class _PrayerTimesScreenBodyState extends State<PrayerTimesScreenBody> {
  @override
  void initState() {
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(seconds: 1));
      final bool? isShow = await CacheService.getData(
        key: 'ramadanWelcomeDialog',
      );
      if (isShow != true) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => const RamadanWelcomeDialog(),
          );
          CacheService.setData(key: 'ramadanWelcomeDialog', value: true);
        }
      }
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocBuilder<PrayerTimeCubit, PrayerTimeState>(
          builder: (context, state) {
            final cubit = PrayerTimeCubit.instance(context);
            final PrayerTimesEntity? prayerTimesEntity =
                cubit.prayerTimesEntity;
            return SingleChildScrollView(
              child: Column(
                children: [
                  BuildUpperDateSelection(
                    onDateSelected: (date) {
                      cubit.getPrayerTime(day: date);
                    },
                  ),
                  const SizedBox(height: 10),
                  BuildNowPrayerNextPrayer(
                    currentPrayerName: prayerTimesEntity?.currentPrayerName,
                    currentPrayerTime: prayerTimesEntity?.currentPrayerTime,
                    nextPrayerName: prayerTimesEntity?.nextPrayerName,
                    nextPrayerTime: prayerTimesEntity?.nextPrayerTime,
                  ),
                  const SizedBox(height: 10),
                  /*SuhoorIftarWidget(
                    suhoorTime: prayerTimesEntity?.fajrTime,
                    iftarTime: prayerTimesEntity?.maghribTime,
                  ),*/
                  /*const SizedBox(height: 10),*/
                  PrayerTimesWidget(
                    locationName: prayerTimesEntity?.locationName ?? '',
                    prayerTimes: [
                      prayerTimesEntity?.fajrTime, // Fajr
                      prayerTimesEntity?.duhurTime, // Duhur
                      prayerTimesEntity?.asrTime, // Asr
                      prayerTimesEntity?.maghribTime, // Maghrib
                      prayerTimesEntity?.ishaTime, // Isha
                    ],
                    currentPrayer: prayerTimesEntity?.currentPrayerName ?? '',
                  ),
                  const SizedBox(height: 10),
                  SunTimesWidget(
                    sunriseTime: prayerTimesEntity?.sunriseTime,
                    midDayTime: prayerTimesEntity?.midNightTime,
                    sunsetTime: prayerTimesEntity?.sunsetTime,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
