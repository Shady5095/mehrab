import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

class QuranSurahDialog extends StatefulWidget {
  final Function(String surahName, int versesCount) onSurahSelected;
  final String? fromSurah;

  const QuranSurahDialog({
    super.key,
    required this.onSurahSelected,
    this.fromSurah,
  });

  @override
  State<QuranSurahDialog> createState() => _QuranSurahDialogState();
}

class _QuranSurahDialogState extends State<QuranSurahDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 🕋 قائمة السور
  final List<Map<String, dynamic>> surahs = const [
    {"name": "الفاتحة", "verses": 7},
    {"name": "البقرة", "verses": 286},
    {"name": "آل عمران", "verses": 200},
    {"name": "النساء", "verses": 176},
    {"name": "المائدة", "verses": 120},
    {"name": "الأنعام", "verses": 165},
    {"name": "الأعراف", "verses": 206},
    {"name": "الأنفال", "verses": 75},
    {"name": "التوبة", "verses": 129},
    {"name": "يونس", "verses": 109},
    {"name": "هود", "verses": 123},
    {"name": "يوسف", "verses": 111},
    {"name": "الرعد", "verses": 43},
    {"name": "إبراهيم", "verses": 52},
    {"name": "الحجر", "verses": 99},
    {"name": "النحل", "verses": 128},
    {"name": "الإسراء", "verses": 111},
    {"name": "الكهف", "verses": 110},
    {"name": "مريم", "verses": 98},
    {"name": "طه", "verses": 135},
    {"name": "الأنبياء", "verses": 112},
    {"name": "الحج", "verses": 78},
    {"name": "المؤمنون", "verses": 118},
    {"name": "النور", "verses": 64},
    {"name": "الفرقان", "verses": 77},
    {"name": "الشعراء", "verses": 227},
    {"name": "النمل", "verses": 93},
    {"name": "القصص", "verses": 88},
    {"name": "العنكبوت", "verses": 69},
    {"name": "الروم", "verses": 60},
    {"name": "لقمان", "verses": 34},
    {"name": "السجدة", "verses": 30},
    {"name": "الأحزاب", "verses": 73},
    {"name": "سبأ", "verses": 54},
    {"name": "فاطر", "verses": 45},
    {"name": "يس", "verses": 83},
    {"name": "الصافات", "verses": 182},
    {"name": "ص", "verses": 88},
    {"name": "الزمر", "verses": 75},
    {"name": "غافر", "verses": 85},
    {"name": "فصلت", "verses": 54},
    {"name": "الشورى", "verses": 53},
    {"name": "الزخرف", "verses": 89},
    {"name": "الدخان", "verses": 59},
    {"name": "الجاثية", "verses": 37},
    {"name": "الأحقاف", "verses": 35},
    {"name": "محمد", "verses": 38},
    {"name": "الفتح", "verses": 29},
    {"name": "الحجرات", "verses": 18},
    {"name": "ق", "verses": 45},
    {"name": "الذاريات", "verses": 60},
    {"name": "الطور", "verses": 49},
    {"name": "النجم", "verses": 62},
    {"name": "القمر", "verses": 55},
    {"name": "الرحمن", "verses": 78},
    {"name": "الواقعة", "verses": 96},
    {"name": "الحديد", "verses": 29},
    {"name": "المجادلة", "verses": 22},
    {"name": "الحشر", "verses": 24},
    {"name": "الممتحنة", "verses": 13},
    {"name": "الصف", "verses": 14},
    {"name": "الجمعة", "verses": 11},
    {"name": "المنافقون", "verses": 11},
    {"name": "التغابن", "verses": 18},
    {"name": "الطلاق", "verses": 12},
    {"name": "التحريم", "verses": 12},
    {"name": "الملك", "verses": 30},
    {"name": "القلم", "verses": 52},
    {"name": "الحاقة", "verses": 52},
    {"name": "المعارج", "verses": 44},
    {"name": "نوح", "verses": 28},
    {"name": "الجن", "verses": 28},
    {"name": "المزمل", "verses": 20},
    {"name": "المدثر", "verses": 56},
    {"name": "القيامة", "verses": 40},
    {"name": "الإنسان", "verses": 31},
    {"name": "المرسلات", "verses": 50},
    {"name": "النبأ", "verses": 40},
    {"name": "النازعات", "verses": 46},
    {"name": "عبس", "verses": 42},
    {"name": "التكوير", "verses": 29},
    {"name": "الإنفطار", "verses": 19},
    {"name": "المطففين", "verses": 36},
    {"name": "الإنشقاق", "verses": 25},
    {"name": "البروج", "verses": 22},
    {"name": "الطارق", "verses": 17},
    {"name": "الأعلى", "verses": 19},
    {"name": "الغاشية", "verses": 26},
    {"name": "الفجر", "verses": 30},
    {"name": "البلد", "verses": 20},
    {"name": "الشمس", "verses": 15},
    {"name": "الليل", "verses": 21},
    {"name": "الضحى", "verses": 11},
    {"name": "الشرح", "verses": 8},
    {"name": "التين", "verses": 8},
    {"name": "العلق", "verses": 19},
    {"name": "القدر", "verses": 5},
    {"name": "البينة", "verses": 8},
    {"name": "الزلزلة", "verses": 8},
    {"name": "العاديات", "verses": 11},
    {"name": "القارعة", "verses": 11},
    {"name": "التكاثر", "verses": 8},
    {"name": "العصر", "verses": 3},
    {"name": "الهمزة", "verses": 9},
    {"name": "الفيل", "verses": 5},
    {"name": "قريش", "verses": 4},
    {"name": "الماعون", "verses": 7},
    {"name": "الكوثر", "verses": 3},
    {"name": "الكافرون", "verses": 6},
    {"name": "النصر", "verses": 3},
    {"name": "المسد", "verses": 5},
    {"name": "الإخلاص", "verses": 4},
    {"name": "الفلق", "verses": 5},
    {"name": "الناس", "verses": 6},
  ];

  // دالة تطبيع الحروف العربية للبحث الذكي
  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و')
    // إزالة التشكيل
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '')
    // إزالة المسافات
        .replaceAll(' ', '');
  }

  // التحقق إذا كانت السورة متاحة للاختيار
  bool _isSurahEnabled(int index) {
    if (widget.fromSurah == null) return true;

    final fromIndex = surahs.indexWhere(
          (s) => s["name"] == widget.fromSurah,
    );

    if (fromIndex == -1) return true;

    return index >= fromIndex;
  }

  // فلترة السور بناءً على البحث
  List<Map<String, dynamic>> get _filteredSurahs {
    if (_searchQuery.isEmpty) return surahs;

    final normalizedQuery = _normalizeArabic(_searchQuery.toLowerCase());

    return surahs.where((surah) {
      final normalizedName = _normalizeArabic(surah["name"].toLowerCase());
      return normalizedName.contains(normalizedQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/quranBackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.2),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اختر سورة",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 45,
                child: SearchBar(
                  surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                  controller: _searchController,
                  hintStyle: WidgetStateProperty.all(
                    TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                      fontFamily: "Cairo",
                    ),
                  ),
                  textStyle: WidgetStateProperty.all(
                    TextStyle(
                      color: Colors.green[700],
                      fontSize: 14.sp,
                      fontFamily: "Cairo",
                    ),
                  ),
                  trailing: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.green[600],
                    ),
                  ],
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  hintText: "ابحث عن سورة...",
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  leading: Icon(
                    Icons.search_outlined,
                    size: 20.sp,
                    color: Colors.green[600],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: SizedBox(
                  width: double.maxFinite,
                  child: _filteredSurahs.isEmpty
                      ? Center(
                    child: Text(
                      "لا توجد نتائج",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.green[600],
                        fontFamily: "Amiri",
                      ),
                    ),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredSurahs.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.green[200],
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final surah = _filteredSurahs[index];
                      final originalIndex = surahs.indexOf(surah);
                      final isEnabled = _isSurahEnabled(originalIndex);

                      return ListTile(
                        enabled: isEnabled,
                        title: Text(
                          "${index+1}. ${surah["name"]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isEnabled
                                ? Colors.green[700]
                                : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                            fontFamily: "Amiri",
                          ),
                        ),
                        onTap: isEnabled
                            ? () {
                          Navigator.pop(context);
                          widget.onSurahSelected(
                            surah["name"],
                            surah["verses"],
                          );
                        }
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}