/// A car problem/service type fetched from /api/problem-categories/.
class ProblemCategory {
  const ProblemCategory({
    required this.slug,
    required this.nameUz,
    required this.nameRu,
    required this.icon,
    required this.group,
    required this.isPopular,
  });

  factory ProblemCategory.fromJson(Map<String, dynamic> j) => ProblemCategory(
        slug: j['slug'] as String? ?? '',
        nameUz: j['name_uz'] as String? ?? '',
        nameRu: j['name_ru'] as String? ?? '',
        icon: j['icon'] as String? ?? 'other',
        group: j['group'] as String? ?? 'qoshimcha',
        isPopular: j['is_popular'] as bool? ?? false,
      );

  final String slug;
  final String nameUz;
  final String nameRu;
  final String icon;
  final String group;
  final bool isPopular;

  /// Localized name; backend has uz/ru, English falls back to uz.
  String name(String locale) => locale == 'ru' ? nameRu : nameUz;
}

/// A display group ("Dvigatel va yonilg'i", "Elektr tizimi", ...).
class ProblemGroup {
  const ProblemGroup({required this.slug, required this.nameUz, required this.nameRu});

  factory ProblemGroup.fromJson(Map<String, dynamic> j) => ProblemGroup(
        slug: j['slug'] as String? ?? '',
        nameUz: j['name_uz'] as String? ?? '',
        nameRu: j['name_ru'] as String? ?? '',
      );

  final String slug;
  final String nameUz;
  final String nameRu;

  String name(String locale) => locale == 'ru' ? nameRu : nameUz;
}

/// Full catalogue response: all categories + group labels.
class ProblemCatalogue {
  const ProblemCatalogue({required this.categories, required this.groups});
  final List<ProblemCategory> categories;
  final List<ProblemGroup> groups;

  List<ProblemCategory> get popular => categories.where((c) => c.isPopular).toList();
}
