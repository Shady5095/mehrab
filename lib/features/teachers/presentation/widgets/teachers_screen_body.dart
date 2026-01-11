import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/teachers/presentation/manager/teachers_cubit/teachers_cubit.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teachers_list.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teachers_search_bar.dart';

class TeachersScreenBody extends StatefulWidget {
  const TeachersScreenBody({super.key});

  @override
  State<TeachersScreenBody> createState() => _TeachersScreenBodyState();
}

class _TeachersScreenBodyState extends State<TeachersScreenBody> with SingleTickerProviderStateMixin {
  static const String _lastSelectedTabIndexKey = 'lastSelectedTeachersTabIndex';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final savedTabIndex = CacheService.getData(key: _lastSelectedTabIndexKey) as int? ?? 0;
    final initialIndex = savedTabIndex >= 0 && savedTabIndex < 2 ? savedTabIndex : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
      CacheService.setData(key: _lastSelectedTabIndexKey, value: _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    final bool isFav = args.isNotEmpty ? args[0] as bool : false;
    final bool isFromTeacherAcc = args.isNotEmpty ? args[1] as bool : false;
    final bool isFromHome = args.isNotEmpty ? (args.elementAtOrNull(2)??false) : false;
    
    // Show TabBar when isFromHome == true OR when all three are false
    final bool showTabBar = isFromHome || (!isFav && !isFromTeacherAcc && !isFromHome);
    
    return BlocProvider(
      create: (context) => TeachersCubit(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: MyAppBar(
                  title: showTabBar 
                    ? AppStrings.teachers 
                    : (isFav ? AppStrings.favoriteTeachers : AppStrings.teachers), 
                  isShowBackButton: isFav || isFromTeacherAcc || isFromHome,
                ),
              ),
              const SizedBox(height: 10,),
              if (showTabBar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TabBar(
                    indicatorColor: AppColors.myAppColor,
                    controller: _tabController,
                    unselectedLabelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: "Cairo",
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.w700,
                      color: AppColors.myAppColor
                    ),
                    tabs: [
                      Tab(text: AppStrings.allTeachers.tr(context)),
                      Tab(text: AppStrings.favoriteTeachers.tr(context)),
                    ],
                  ),
                ),
              if (showTabBar)
                const SizedBox(height: 10,),
              if (showTabBar && _tabController.index == 0)
                const TeacherSearchBar(),
              if (showTabBar && _tabController.index == 0)
                const SizedBox(height: 10,),
              if (!showTabBar && !isFav)
                const TeacherSearchBar(),
              if (!showTabBar && !isFav)
                const SizedBox(height: 10,),
              Expanded(
                child: showTabBar
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          TeachersList(isFavOverride: false),
                          TeachersList(isFavOverride: true),
                        ],
                      )
                    : TeachersList(isFavOverride: null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
