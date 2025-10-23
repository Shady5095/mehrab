import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'dart:io';

import 'package:mehrab/features/authentication/data/user_model.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
class AppConstants {
  static const androidDownloadDirectory = '/storage/emulated/0/Download';

  /// Main Tabs
  static const int homeScreenIndex = 0;
  static const english = 'English';
  static const arabic = 'العربية';
  static const turkish = 'Türkçe';
  static const germany = 'Deutsch';
  static const ar = 'ar';
  static const en = 'en';
  static const tr = 'tr';
  static const de = 'de';
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
  static const String currentLanguage = 'currentLanguage';

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
  static const String uid = 'uid';

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
  static  bool isAdmin = false;
  static  bool isTeacher = false;
  static  bool isStudent = false;

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
  static List<String> nationalities = [
    "afghan",
    "albanian",
    "algerian",
    "american",
    "andorran",
    "angolan",
    "argentine",
    "armenian",
    "australian",
    "austrian",
    "azerbaijani",
    "bahraini",
    "bangladeshi",
    "belarusian",
    "belgian",
    "belizean",
    "beninese",
    "bhutanese",
    "bolivian",
    "bosnian",
    "brazilian",
    "british",
    "bruneian",
    "bulgarian",
    "burkinabe",
    "burmese",
    "burundian",
    "cambodian",
    "cameroonian",
    "canadian",
    "chadian",
    "chilean",
    "chinese",
    "colombian",
    "comoran",
    "congolese",
    "costa_rican",
    "croatian",
    "cuban",
    "cypriot",
    "czech",
    "danish",
    "djiboutian",
    "dominican",
    "dutch",
    "east_timorese",
    "ecuadorian",
    "egyptian",
    "emirati",
    "english",
    "equatorial_guinean",
    "eritrean",
    "estonian",
    "ethiopian",
    "fijian",
    "finnish",
    "french",
    "gabonese",
    "gambian",
    "georgian",
    "german",
    "ghanaian",
    "greek",
    "guatemalan",
    "guinean",
    "haitian",
    "honduran",
    "hungarian",
    "icelandic",
    "indian",
    "indonesian",
    "iranian",
    "iraqi",
    "irish",
    "israeli",
    "italian",
    "ivorian",
    "jamaican",
    "japanese",
    "jordanian",
    "kazakh",
    "kenyan",
    "kuwaiti",
    "kyrgyz",
    "laotian",
    "latvian",
    "lebanese",
    "liberian",
    "libyan",
    "lithuanian",
    "luxembourgish",
    "macedonian",
    "malagasy",
    "malawian",
    "malaysian",
    "maldivian",
    "malian",
    "maltese",
    "mauritanian",
    "mauritian",
    "mexican",
    "moldovan",
    "monacan",
    "mongolian",
    "montenegrin",
    "moroccan",
    "mozambican",
    "namibian",
    "nepalese",
    "dutch_national",
    "new_zealander",
    "nicaraguan",
    "nigerien",
    "nigerian",
    "north_korean",
    "norwegian",
    "omani",
    "pakistani",
    "palestinian",
    "panamanian",
    "paraguayan",
    "peruvian",
    "philippine",
    "polish",
    "portuguese",
    "qatari",
    "romanian",
    "russian",
    "rwandan",
    "saint_lucian",
    "salvadoran",
    "saudi",
    "scottish",
    "senegalese",
    "serbian",
    "singaporean",
    "slovak",
    "slovenian",
    "somali",
    "south_african",
    "south_korean",
    "spanish",
    "sri_lankan",
    "sudanese",
    "swazi",
    "swedish",
    "swiss",
    "syrian",
    "taiwanese",
    "tajik",
    "tanzanian",
    "thai",
    "togolese",
    "tunisian",
    "turkish",
    "turkmen",
    "ugandan",
    "ukrainian",
    "uruguayan",
    "uzbek",
    "venezuelan",
    "vietnamese",
    "welsh",
    "yemeni",
    "zambian",
    "zimbabwean",
  ];

  static List<String> arabicNationalities = [
    "afghan", // أفغاني (ا)
    "american", // أمريكي (ا)
    "andorran", // أندوري (ا)
    "angolan", // أنغولي (ا)
    "argentine", // أرجنتيني (ا)
    "armenian", // أرميني (ا)
    "australian", // أسترالي (ا)
    "azerbaijani", // أذربيجاني (ا)
    "albanian", // ألباني (ا)
    "jordanian", // أردني (ا)
    "german", // ألماني (ا)
    "icelandic", // آيسلندي (ا)
    "bahraini", // بحريني (ب)
    "bangladeshi", // بنغلاديشي (ب)
    "belarusian", // بيلاروسي (ب)
    "belgian", // بلجيكي (ب)
    "belizean", // بليزي (ب)
    "beninese", // بنيني (ب)
    "bhutanese", // بوتاني (ب)
    "bolivian", // بوليفي (ب)
    "bosnian", // بوسني (ب)
    "brazilian", // برازيلي (ب)
    "british", // بريطاني (ب)
    "bruneian", // بروني (ب)
    "bulgarian", // بلغاري (ب)
    "burkinabe", // بوركيني (ب)
    "burmese", // بورمي (ب)
    "burundian", // بوروندي (ب)
    "pakistani", // باكستاني (ب)
    "panamanian", // بنمي (ب)
    "paraguayan", // باراغواي (ب)
    "peruvian", // بيروفي (ب)
    "polish", // بولندي (ب)
    "portuguese", // برتغالي (ب)
    "thai", // تايلندي (ت)
    "taiwanese", // تايواني (ت)
    "tanzanian", // تنزاني (ت)
    "togolese", // توغولي (ت)
    "tunisian", // تونسي (ت)
    "turkish", // تركي (ت)
    "turkmen", // تركماني (ت)
    "chadian", // تشادي (ت)
    "chilean", // تشيليني (ت)
    "czech", // تشيكي (ت)
    "algerian", // جزائري (ج)
    "comoran", // جزر القمر (ج)
    "jamaican", // جامايكي (ج)
    "japanese", // ياباني (ج)
    "georgian", // جورجي (ج)
    "djiboutian", // جيبوتي (ج)
    "south_african", // جنوب أفريقي (ج)
    "south_korean", // كوري جنوبي (ج)
    "haitian", // هايتي (هـ)
    "honduran", // هندوراسي (هـ)
    "dutch", // هولندي (هـ)
    "dutch_national", // هولندي (هـ)
    "danish", // دنماركي (د)
    "dominican", // دومينيكاني (د)
    "russian", // روسي (ر)
    "rwandan", // رواندي (ر)
    "romanian", // روماني (ر)
    "zambian", // زامبي (ز)
    "zimbabwean", // زيمبابوي (ز)
    "saint_lucian", // سانت لوسي (س)
    "salvadoran", // سلفادوري (س)
    "saudi", // سعودي (س)
    "senegalese", // سنغالي (س)
    "singaporean", // سنغافوري (س)
    "slovak", // سلوفاكي (س)
    "slovenian", // سلوفيني (س)
    "sri_lankan", // سريلانكي (س)
    "sudanese", // سوداني (س)
    "swazi", // سوازي (س)
    "swedish", // سويدي (س)
    "swiss", // سويسري (س)
    "syrian", // سوري (س)
    "scottish", // اسكتلندي (س)
    "spanish", // إسباني (س)
    "chinese", // صيني (ص)
    "serbian", // صربي (ص)
    "somali", // صومالي (ص)
    "tajik", // طاجيكي (ط)
    "iraqi", // عراقي (ع)
    "omani", // عماني (ع)
    "ugandan", // أوغندي (ع)
    "uzbek", // أوزبكي (ع)
    "ukrainian", // أوكراني (ع)
    "uruguayan", // أورغواياني (ع)
    "gambian", // غامبي (غ)
    "ghanaian", // غاني (غ)
    "guatemalan", // غواتيمالي (غ)
    "guinean", // غيني (غ)
    "equatorial_guinean", // غيني استوائي (غ)
    "gabonese", // غابوني (غ)
    "fijian", // فيجي (ف)
    "philippine", // فلبيني (ف)
    "venezuelan", // فنزويلي (ف)
    "vietnamese", // فيتنامي (ف)
    "palestinian", // فلسطيني (ف)
    "finnish", // فنلندي (إ)
    "french", // فرنسي (ف)
    "qatari", // قطري (ق)
    "cypriot", // قبرصي (ق)
    "kyrgyz", // قرغيزي (ق)
    "kazakh", // كازاخستاني (ك)
    "kenyan", // كيني (ك)
    "kuwaiti", // كويتي (ك)
    "cambodian", // كمبودي (ك)
    "cameroonian", // كاميروني (ك)
    "canadian", // كندي (ك)
    "colombian", // كولومبي (ك)
    "congolese", // كونغولي (ك)
    "costa_rican", // كوستاريكي (ك)
    "croatian", // كرواتي (ك)
    "cuban", // كوبي (ك)
    "north_korean", // كوري شمالي (ك)
    "laotian", // لاوسي (ل)
    "latvian", // لاتفي (ل)
    "lebanese", // لبناني (ل)
    "liberian", // ليبيري (ل)
    "libyan", // ليبي (ل)
    "lithuanian", // ليتواني (ل)
    "luxembourgish", // لوكسمبورغي (ل)
    "egyptian", // مصري (م)
    "hungarian", // مجري (م)
    "malagasy", // مدغشقري (م)
    "malawian", // مالاوي (م)
    "malaysian", // ماليزي (م)
    "maldivian", // مالديفي (م)
    "malian", // مالي (م)
    "maltese", // مالطي (م)
    "mauritanian", // موريتاني (م)
    "mauritian", // موريشي (م)
    "mexican", // مكسيكي (م)
    "moldovan", // مولدوفي (م)
    "monacan", // موناكي (م)
    "mongolian", // منغولي (م)
    "montenegrin", // مونتينيغري (م)
    "moroccan", // مغربي (م)
    "mozambican", // موزمبيقي (م)
    "namibian", // ناميبي (ن)
    "nepalese", // نيبالي (ن)
    "new_zealander", // نيوزيلندي (ن)
    "nicaraguan", // نيكاراغوي (ن)
    "nigerien", // نيجري (ن)
    "nigerian", // نيجيري (ن)
    "norwegian", // نرويجي (ن)
    "austrian", // نمساوي (ن)
    "indian", // هندي (ه)
    "welsh", // ويلزي (و)
    "yemeni", // يمني (ي)
    "greek", // يوناني (ي)
    "ecuadorian", // إكوادوري (إ)
    "emirati", // إماراتي (إ)
    "english", // إنجليزي (إ)
    "eritrean", // إريتري (إ)
    "estonian", // إستوني (إ)
    "ethiopian", // إثيوبي (إ)
    "iranian", // إيراني (إ)
    "irish", // إيرلندي (إ)
    "israeli", // إسرائيلي (إ)
    "italian", // إيطالي (إ)
    "ivorian", // إيفواري (إ)

    "indonesian", // إندونيسي (إ)
  ];
  static final List<String> educationLevelKeys = [
    "primary",
    "intermediate",
    "secondary",
    "continued",
    "university",
    "masters",
    "phd",
  ];


  static final List<Country> arabCountries = [
    Country(
      name: "Algeria",
      nameTranslations: {"en": "Algeria", "ar": "الجزائر"},
      flag: "🇩🇿",
      code: "DZ",
      dialCode: "213",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Bahrain",
      nameTranslations: {"en": "Bahrain", "ar": "البحرين"},
      flag: "🇧🇭",
      code: "BH",
      dialCode: "973",
      minLength: 8,
      maxLength: 8,
    ),
    Country(
      name: "Comoros",
      nameTranslations: {"en": "Comoros", "ar": "جزر القمر"},
      flag: "🇰🇲",
      code: "KM",
      dialCode: "269",
      minLength: 7,
      maxLength: 7,
    ),
    Country(
      name: "Djibouti",
      nameTranslations: {"en": "Djibouti", "ar": "جيبوتي"},
      flag: "🇩🇯",
      code: "DJ",
      dialCode: "253",
      minLength: 6,
      maxLength: 8,
    ),
    Country(
      name: "Egypt",
      nameTranslations: {"en": "Egypt", "ar": "مصر"},
      flag: "🇪🇬",
      code: "EG",
      dialCode: "20",
      minLength: 9,
      maxLength: 10,
    ),
    Country(
      name: "Iraq",
      nameTranslations: {"en": "Iraq", "ar": "العراق"},
      flag: "🇮🇶",
      code: "IQ",
      dialCode: "964",
      minLength: 10,
      maxLength: 10,
    ),
    Country(
      name: "Jordan",
      nameTranslations: {"en": "Jordan", "ar": "الأردن"},
      flag: "🇯🇴",
      code: "JO",
      dialCode: "962",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Kuwait",
      nameTranslations: {"en": "Kuwait", "ar": "الكويت"},
      flag: "🇰🇼",
      code: "KW",
      dialCode: "965",
      minLength: 8,
      maxLength: 8,
    ),
    Country(
      name: "Lebanon",
      nameTranslations: {"en": "Lebanon", "ar": "لبنان"},
      flag: "🇱🇧",
      code: "LB",
      dialCode: "961",
      minLength: 7,
      maxLength: 8,
    ),
    Country(
      name: "Libya",
      nameTranslations: {"en": "Libya", "ar": "ليبيا"},
      flag: "🇱🇾",
      code: "LY",
      dialCode: "218",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Mauritania",
      nameTranslations: {"en": "Mauritania", "ar": "موريتانيا"},
      flag: "🇲🇷",
      code: "MR",
      dialCode: "222",
      minLength: 8,
      maxLength: 8,
    ),
    Country(
      name: "Morocco",
      nameTranslations: {"en": "Morocco", "ar": "المغرب"},
      flag: "🇲🇦",
      code: "MA",
      dialCode: "212",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Oman",
      nameTranslations: {"en": "Oman", "ar": "عمان"},
      flag: "🇴🇲",
      code: "OM",
      dialCode: "968",
      minLength: 8,
      maxLength: 8,
    ),
    Country(
      name: "Palestine",
      nameTranslations: {"en": "Palestine", "ar": "فلسطين"},
      flag: "🇵🇸",
      code: "PS",
      dialCode: "970",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Qatar",
      nameTranslations: {"en": "Qatar", "ar": "قطر"},
      flag: "🇶🇦",
      code: "QA",
      dialCode: "974",
      minLength: 8,
      maxLength: 8,
    ),
    Country(
      name: "Saudi Arabia",
      nameTranslations: {"en": "Saudi Arabia", "ar": "السعودية"},
      flag: "🇸🇦",
      code: "SA",
      dialCode: "966",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Somalia",
      nameTranslations: {"en": "Somalia", "ar": "الصومال"},
      flag: "🇸🇴",
      code: "SO",
      dialCode: "252",
      minLength: 7,
      maxLength: 8,
    ),
    Country(
      name: "Sudan",
      nameTranslations: {"en": "Sudan", "ar": "السودان"},
      flag: "🇸🇩",
      code: "SD",
      dialCode: "249",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Syria",
      nameTranslations: {"en": "Syria", "ar": "سوريا"},
      flag: "🇸🇾",
      code: "SY",
      dialCode: "963",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Tunisia",
      nameTranslations: {"en": "Tunisia", "ar": "تونس"},
      flag: "🇹🇳",
      code: "TN",
      dialCode: "216",
      minLength: 8,
      maxLength: 8,
    ),
    Country(
      name: "United Arab Emirates",
      nameTranslations: {"en": "United Arab Emirates", "ar": "الإمارات"},
      flag: "🇦🇪",
      code: "AE",
      dialCode: "971",
      minLength: 9,
      maxLength: 9,
    ),
    Country(
      name: "Yemen",
      nameTranslations: {"en": "Yemen", "ar": "اليمن"},
      flag: "🇾🇪",
      code: "YE",
      dialCode: "967",
      minLength: 9,
      maxLength: 9,
    ),
  ];
  static Map<String, String> countryCodeToNationality = {
    // Africa (only exact matches from your list)
    'DZ': 'algerian',
    'AO': 'angolan',
    'BJ': 'beninese',
    'BF': 'burkinabe',
    'BI': 'burundian',
    'CM': 'cameroonian',
    'TD': 'chadian',
    'KM': 'comoran',
    'CD': 'congolese',
    'CG': 'congolese',
    'CI': 'ivorian',
    'DJ': 'djiboutian',
    'EG': 'egyptian',
    'GQ': 'equatorial_guinean',
    'ER': 'eritrean',
    'ET': 'ethiopian',
    'GA': 'gabonese',
    'GM': 'gambian',
    'GH': 'ghanaian',
    'GN': 'guinean',
    'LR': 'liberian',
    'LY': 'libyan',
    'MG': 'malagasy',
    'MW': 'malawian',
    'ML': 'malian',
    'MR': 'mauritanian',
    'MU': 'mauritian',
    'MA': 'moroccan',
    'MZ': 'mozambican',
    'NA': 'namibian',
    'NE': 'nigerien',
    'NG': 'nigerian',
    'RW': 'rwandan',
    'SN': 'senegalese',
    'SO': 'somali',
    'ZA': 'south_african',
    'SD': 'sudanese',
    'TZ': 'tanzanian',
    'TG': 'togolese',
    'TN': 'tunisian',
    'UG': 'ugandan',
    'ZM': 'zambian',
    'ZW': 'zimbabwean',

    // Americas (only exact matches from your list)
    'AR': 'argentine',
    'BZ': 'belizean',
    'BO': 'bolivian',
    'BR': 'brazilian',
    'CA': 'canadian',
    'CL': 'chilean',
    'CO': 'colombian',
    'CR': 'costa_rican',
    'CU': 'cuban',
    'DO': 'dominican',
    'EC': 'ecuadorian',
    'SV': 'salvadoran',
    'GT': 'guatemalan',
    'HT': 'haitian',
    'HN': 'honduran',
    'JM': 'jamaican',
    'MX': 'mexican',
    'NI': 'nicaraguan',
    'PA': 'panamanian',
    'PY': 'paraguayan',
    'PE': 'peruvian',
    'UY': 'uruguayan',
    'VE': 'venezuelan',

    // Asia (only exact matches from your list)
    'AF': 'afghan',
    'AM': 'armenian',
    'AZ': 'azerbaijani',
    'BH': 'bahraini',
    'BD': 'bangladeshi',
    'BT': 'bhutanese',
    'BN': 'bruneian',
    'CN': 'chinese',
    'GE': 'georgian',
    'IN': 'indian',
    'ID': 'indonesian',
    'IR': 'iranian',
    'IQ': 'iraqi',
    'IL': 'israeli',
    'JP': 'japanese',
    'JO': 'jordanian',
    'KZ': 'kazakh',
    'KW': 'kuwaiti',
    'KG': 'kyrgyz',
    'LA': 'laotian',
    'LB': 'lebanese',
    'MV': 'maldivian',
    'MM': 'burmese',
    'NP': 'nepalese',
    'KP': 'north_korean',
    'OM': 'omani',
    'PK': 'pakistani',
    'PS': 'palestinian',
    'PH': 'philippine',
    'QA': 'qatari',
    'SA': 'saudi',
    'SG': 'singaporean',
    'KR': 'south_korean',
    'LK': 'sri_lankan',
    'SY': 'syrian',
    'TW': 'taiwanese',
    'TJ': 'tajik',
    'TH': 'thai',
    'TL': 'east_timorese',
    'TR': 'turkish',
    'TM': 'turkmen',
    'AE': 'emirati',
    'UZ': 'uzbek',
    'VN': 'vietnamese',
    'YE': 'yemeni',

    // Europe (only exact matches from your list)
    'AL': 'albanian',
    'AD': 'andorran',
    'AT': 'austrian',
    'BY': 'belarusian',
    'BE': 'belgian',
    'BA': 'bosnian',
    'BG': 'bulgarian',
    'HR': 'croatian',
    'CY': 'cypriot',
    'CZ': 'czech',
    'DK': 'danish',
    'EE': 'estonian',
    'FI': 'finnish',
    'FR': 'french',
    'DE': 'german',
    'GR': 'greek',
    'HU': 'hungarian',
    'IS': 'icelandic',
    'IE': 'irish',
    'IT': 'italian',
    'LV': 'latvian',
    'LT': 'lithuanian',
    'LU': 'luxembourgish',
    'MT': 'maltese',
    'MD': 'moldovan',
    'MC': 'monacan',
    'ME': 'montenegrin',
    'NL': 'dutch',
    'MK': 'macedonian',
    'NO': 'norwegian',
    'PL': 'polish',
    'PT': 'portuguese',
    'RO': 'romanian',
    'RU': 'russian',
    'RS': 'serbian',
    'SK': 'slovak',
    'SI': 'slovenian',
    'ES': 'spanish',
    'SE': 'swedish',
    'CH': 'swiss',
    'UA': 'ukrainian',
    'GB': 'british', // Covers english, scottish, welsh as UK fallback
    'english': 'english',
    'scottish': 'scottish',
    'welsh': 'welsh',

    // Oceania (only exact matches from your list)
    'AU': 'australian',
    'FJ': 'fijian',
    'NZ': 'new_zealander',
  };
}
String myUid = '';
UserModel? currentUserModel;
TeacherModel? currentTeacherModel;