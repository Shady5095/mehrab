import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import 'package:mehrab/features/students/presentation/widgets/student_item.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import '../manager/students_cubit/students_cubit.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  final List<UserModel> _students = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _lastSearchQuery;

  @override
  void initState() {
    super.initState();
    _fetchStudents();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchStudents();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    if (_isLoading || !_hasMore) return;

    if (!mounted) return;
    final cubit = StudentsCubit.get(context);
    final currentSearchQuery = cubit.searchQuery;

    // إعادة تعيين pagination عند تغيير البحث
    if (_lastSearchQuery != currentSearchQuery) {
      if (!mounted) return;
      setState(() {
        _students.clear();
        _lastDoc = null;
        _hasMore = true;
        _lastSearchQuery = currentSearchQuery;
      });
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await cubit.getStudentsPage(
        searchQuery: currentSearchQuery.isEmpty ? null : currentSearchQuery,
        lastDoc: _lastDoc,
        limit: _pageSize,
      );

      if (!mounted) return;

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
        final newStudents = snapshot.docs
            .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        setState(() {
          _students.addAll(newStudents);
        });
      } else {
        setState(() => _hasMore = false);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentsCubit, StudentsState>(
      buildWhen: (previous, current) => current is StudentsSearchUpdatedState,
      builder: (context, state) {
        // إعادة تعيين pagination عند تغيير البحث
        final cubit = StudentsCubit.get(context);
        if (_lastSearchQuery != cubit.searchQuery) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _students.clear();
              _lastDoc = null;
              _hasMore = true;
              _lastSearchQuery = cubit.searchQuery;
            });
            _fetchStudents();
          });
        }

        if (_students.isEmpty && !_isLoading) {
          return ListEmptyWidget(
            icon: 'assets/images/students.png',
            title: AppStrings.noStudents,
            description: AppStrings.noStudentDescription,
          );
        }

        return AnimationLimiter(
          child: ListView.separated(
            controller: _scrollController,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: _students.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _students.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final student = _students[index];
              return ListItemAnimation(
                index: index,
                child: StudentItem(userModel: student),
              );
            },
          ),
        );
      },
    );
  }
}