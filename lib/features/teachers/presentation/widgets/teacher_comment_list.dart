import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/features/teachers/data/models/teacher_comment_model.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/manager/teacher_profile_cubit/teacher_profile_cubit.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_comment_item.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_comment_shimmer_item.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import 'add_comment_dialog.dart';

class TeacherCommentList extends StatefulWidget {
  final TeacherModel model;

  const TeacherCommentList({super.key, required this.model});

  @override
  State<TeacherCommentList> createState() => _TeacherCommentListState();
}

class _TeacherCommentListState extends State<TeacherCommentList> {
  final List<TeacherCommentsModel> _comments = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoading = true;
  TeacherCommentsModel? _myComment;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _comments.clear();
      _lastDocument = null;
      _hasMore = true;
      _myComment = null;
    });

    try {
      final query = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.model.uid)
          .collection('comments')
          .orderBy("timestamp", descending: true)
          .limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final allComments = snapshot.docs
            .map((doc) =>
            TeacherCommentsModel.fromJson(doc.data()))
            .toList();

        // Separate my comment from others
        for (var comment in allComments) {
          if (comment.userUid == currentUserModel?.uid) {
            _myComment = comment;
          } else {
            _comments.add(comment);
          }
        }

        _hasMore = snapshot.docs.length == _pageSize;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.model.uid)
          .collection('comments')
          .orderBy("timestamp", descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final newComments = snapshot.docs
            .map((doc) =>
            TeacherCommentsModel.fromJson(doc.data()))
            .toList();

        // Add only other users' comments (not mine)
        for (var comment in newComments) {
          if (comment.userUid != currentUserModel?.uid) {
            _comments.add(comment);
          }
        }

        _hasMore = snapshot.docs.length == _pageSize;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error loading more data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherProfileCubit, TeacherProfileState>(
      listenWhen: (oldState, newState) => newState is RateTeacherSuccessState,
      listener: (context, state) {
        _loadInitialData();
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalComments = (_myComment != null ? 1 : 0) + _comments.length;

    if (totalComments == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListEmptyWidget(
            icon: AppAssets.teacherComments,
            title: AppStrings.noComments,
            description: AppStrings.noCommentsDescription,
          ),
          _buildAddCommentButton(),
        ],
      );
    }

    // Reorder so my comment is first if it exists
    final orderedComments = [
      if (_myComment != null) _myComment!,
      ..._comments,
    ];

    return Column(
      children: [
        _buildAddCommentButton(),
        Expanded(
          child: AnimationLimiter(
            child: ListView.separated(
              controller: _scrollController,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: const Divider(),
              ),
              itemCount: orderedComments.length + (_hasMore && _isLoadingMore ? 3 : 0),
              itemBuilder: (context, index) {
                if (index >= orderedComments.length) {
                  return const TeacherCommentShimmerItem();
                }

                final comment = orderedComments[index];
                return ListItemAnimation(
                  index: index,
                  child: TeacherCommentItem(
                    model: comment,
                    onCommentUpdated: () {
                      // تحديث قائمة التعليقات بعد التعديل
                      _loadInitialData();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCommentButton() {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (newContext) => AddCommentDialog(
            teacherUid: widget.model.uid,
            oldComment: _myComment?.comment,
            oldRating: _myComment?.rating.toDouble(),
            onCommentAdded: () {
              // Refresh the comments list
              _loadInitialData();
            },
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_comment_outlined,
            color: AppColors.myAppColor,
            size: 20.sp,
          ),
          SizedBox(width: 5),
          Text(
            AppStrings.addComment.tr(context),
            style: TextStyle(
              color: AppColors.myAppColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}