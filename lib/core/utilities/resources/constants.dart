import 'package:flutter/material.dart';
import 'dart:io';
class AppConstants {
  static const androidDownloadDirectory = '/storage/emulated/0/Download';

  /// Main Tabs
  static const int homeScreenIndex = 0;
  static const english = 'English';
  static const arabic = 'العربية';
  static const ar = 'ar';
  static const en = 'en';
  static const appVersion = 'appVersion';
  static const double paginationValue = 0.7;
  static const unauthenticated = 401;
  static final paginationNumber =  Platform.isAndroid? 10:15;
  static const int coursesScreenIndex = 1;
  static const int gradeScreenIndex = 2;
  static const homeFadeDuration = Duration(seconds: 2);
  static const listFadeDuration = Duration(milliseconds: 1500);
  static const int moreScreenIndex = 3;
  static const domainName = 'learnovia.com';
  static const currentVersionNum = '4.6.0';
  static const maxFileSize = 204800;
  static const letter = 'Value';
  static const addFile = 'addFile';

  static const allowFileExtension = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'zip',
    'rar',
  ];
  static const allowMediaExtension = [
    'mp3', 'wav', 'm4a', // Audio formats
    'mp4', 'mkv', 'mov', 'mpg', 'mpeg', // Video formats
    'jpg', 'jpeg', 'png', 'gif', 'heic', // Image formats including HEIC
  ];
  static const courseShapeWidth = 60;
  static const appShapeWidth = 50;

  /// app rules
  static const interactive = 'h5p_content';
  static const parentRole = 7;
  static const studentRole = 3;
  static const teacherRole = 4;
  static const superAdmin = 1;
  static const systemAdmin = 2;
  static const supervisorRole = 6;
  static const all = 'All';
  static const String submitted = 'Submitted';
  static const String notSubmitted = 'Not submitted';
  static const String englishFont = 'Poppins';
  static const String arabicFont = 'Cairo';
  static const String baseUrl = 'baseUrl';
  static const String token = 'token';
  static const String userRole = 'userRole';
  static const String schoolImage = 'schoolImage';
  static const String isParentSelectChild = 'isParentSelectChild';
  static const String selectedChild = 'selectedChild';
  static const String isEnglish = 'isEnglish';
  static const String themeMode = 'themeMode';
  static const String userId = 'userId';
  static const String userName = 'userName';
  static const String userPhoto = 'userPhoto';
  static const String canUserCreateRoom = 'canUserCreateRoom';
  static const String canUserDeleteMessage = 'canUserDeleteMessage';
  static const String isShowGrades = 'isShowGrades';
  static const String isUserRateApp = 'isUserRateApp';

  /// download
  static const announcement = 'Announcement';
  static const assignment = 'Assignment';
  static const materials = 'Materials';

  /// home
  static const noPermissions = 403;

  /// assignment
  static const allowFileOrText = 2;
  static const onlyAllowFile = 1;
  static const onlyAllowText = 0;

  /// materials
  static const page = 'page';
  static const file = 'file';
  static const media = 'media';
  static const image = 'image';
  static const video = 'video';
  static const audio = 'audio';
  static const link = 'Link';
  static const mediaLink = 'media link';

  /// hive
  static const cacheCourseList = 'CacheCourseList';
  static const cacheCalendarList = 'CacheCalendarList';
  static const cacheMaterialsList = 'CacheMaterialsList';
  static const cacheUserInfo = 'CacheUserInfo';
  static const cacheAssignmentList = 'CacheAssignmentList';
  static const cacheQuizzesList = 'CacheQuizzesList';
  static const cacheInteractiveList = 'cacheInteractiveList';
  static const cacheVirtualList = 'CacheVirtualList';
  static const cacheChildrenList = 'cacheChildrenList';
  static const cacheAppFilePass = 'CacheAppFilePass';
  static const cacheMaterialsDownloadFiles = 'CacheMaterialsDownloadFiles';
  static const cacheSingleAssignmentItem = 'cacheSingleAssignmentItem';
  static const cacheSingleGradedAssignmentItem =
      'cacheSingleGradedAssignmentItem';
  static const cacheCourseLessons = 'cacheCourseLessons';
  static const cacheCourseClasses = 'cacheCourseClasses';
  static const cacheCourseMaterials = 'cacheCourseMaterials';
  static const cacheCourseAssignments = 'cacheCourseAssignment';
  static const cacheCourseQuizzes = 'cacheCourseQuizzes';
  static const cacheCourseInteractive = 'cacheCourseInteractive';
  static const cacheCourseVirtual= 'cacheCourseVirtual';
  static const cacheMaxSize = 50;

  /// question Bank
  static const mcq = 'MCQ';
  static const tAndF = 'True/False';
  static const match = 'Match';
  static const essay = 'Essay';
  static const paragraph = 'Paragraph';
  static List<Color> questionColors = const [
    Color(0x335E5E5E),
    Color(0xFFb2e5fd),
    Color(0xFFffcdba),
    Color(0xFFf2aec7),
    Color(0xFFdaddfe),
    Color(0xFFcaf2e0),
  ];
  static const chartBorderValue = 3.0;
  static const chartOpacityValue = 0.5;
  static const matchColors = [
    Color(0xFF36a2eb),
    Color(0xFFff6384),
    Color(0xFF4bc0c0),
    Color(0xFFff9f40),
    Color(0xFF9966ff),
    Color(0xFFffcd56),
    Color(0xFFc9cbcf),
    Color(0xFF0066cb),
    Color(0xFFea4335),
    Color(0xFF34a853),
    Color(0xFFE8DA8B),
    Color(0xFFFF5733),
    Color(0xFFFCB9FF),
    Color(0xFF3D7D78),
    Color(0xFF7D6E3D),
    Color(0xFFA03434),
    Color(0xFFFFE100),
    Color(0xFF7703FC),
    Color(0xFFF565FB),
    Color(0xFF3D7D79),
    Color(0xFF616161),
    Color(0xFFFF9800),
    Color(0xFFFFF9D0),
    Color(0xFF824D74),
    Color(0xFFA8CD9F),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
  ];

  /// Courses Filters

  // assignment
  static const String assignment_id = 'assignment_id';
  static const String lesson_id = 'lesson_id';

  // static final htmlImageStyle = {
  //   'img': Style(
  //     width: Width(
  //       100.wR,
  //       Unit.auto,
  //     ),
  //   ),
  // };
  /// attendance
  static List<IconData> attendanceInfoIcons = [
    Icons.check_circle,
    Icons.watch_later,
    Icons.pan_tool_outlined,
    Icons.cancel,
  ];
  static const downloadIcon = Icons.file_download_outlined;

  ///quiz
  static const String cachedQuizAnswer = 'cachedQuizAnswer';
}
