import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'activities_page.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://cusdjhfdhimoucjvxsmr.supabase.co',
);
const _supabaseKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_3TMqOmzhy8kTr0MMGGhwuA_eqhcTfI-',
);
const _accent = Color(0xFF2BB3B1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configured = _supabaseUrl.isNotEmpty && _supabaseKey.isNotEmpty;
  if (configured) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseKey,
    );
  }
  runApp(TeatroBootstrap(configured: configured));
}

class TeatroBootstrap extends StatefulWidget {
  const TeatroBootstrap({super.key, required this.configured});
  final bool configured;

  @override
  State<TeatroBootstrap> createState() => _TeatroBootstrapState();
}

class _TeatroBootstrapState extends State<TeatroBootstrap> {
  bool _english = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teatro AlSaeed',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF080A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF080A0A),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF121717),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0x222BB3B1)),
          ),
        ),
      ),
      locale: Locale(_english ? 'en' : 'ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: widget.configured
          ? TeatroShell(
              english: _english,
              onLanguageChanged: () => setState(() => _english = !_english),
            )
          : const SetupRequiredPage(),
    );
  }
}

class SetupRequiredPage extends StatelessWidget {
  const SetupRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.theaters_outlined, size: 64, color: _accent),
              SizedBox(height: 18),
              Text(
                'تياترو الصعيد',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'التطبيق جاهز للتهيئة. أضف بيانات اتصال Supabase عند بناء نسخة التشغيل.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'The app needs its Supabase URL and publishable key to load live content.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeatroShell extends StatefulWidget {
  const TeatroShell({super.key, required this.english, required this.onLanguageChanged});
  final bool english;
  final VoidCallback onLanguageChanged;

  @override
  State<TeatroShell> createState() => _TeatroShellState();
}

class _TeatroShellState extends State<TeatroShell> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final english = widget.english;
    final pages = [
      HomePage(english: english),
      ContentListPage(
        english: english,
        table: 'news_posts',
        titleAr: 'الأخبار',
        titleEn: 'News',
        subtitleAr: 'آخر أخبار وأنشطة تياترو الصعيد',
        subtitleEn: 'Latest news and activities',
        dateColumn: 'published_at',
      ),
      WorkshopsShowsPage(english: english),
      FestivalPage(english: english),
      MorePage(english: english),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.theaters, color: _accent),
            const SizedBox(width: 10),
            Text(english ? 'TEATRO ALSAEED' : 'تياترو الصعيد'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: widget.onLanguageChanged,
            child: Text(english ? 'عربي' : 'EN'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: english ? 'Home' : 'الرئيسية',
          ),
          NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: const Icon(Icons.article),
            label: english ? 'News' : 'الأخبار',
          ),
          NavigationDestination(
            icon: const Icon(Icons.theater_comedy_outlined),
            selectedIcon: const Icon(Icons.theater_comedy),
            label: english ? 'Workshops & Shows' : 'الورش والعروض',
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: english ? 'Festival' : 'المهرجان',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            label: english ? 'More' : 'المزيد',
          ),
        ],
      ),
    );
  }
}

String localized(Map<String, dynamic> row, String ar, String en, bool english) {
  final preferred = row[english ? en : ar];
  final fallback = row[english ? ar : en];
  return (preferred ?? fallback ?? '').toString();
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.english});
  final bool english;

  Future<Map<String, List<Map<String, dynamic>>>> _load() async {
    final client = Supabase.instance.client;
    final results = await Future.wait<dynamic>([
      client
          .from('news_posts')
          .select('id,title_ar,title_en,excerpt_ar,excerpt_en,cover_image_url,published_at')
          .eq('status', 'published')
          .order('published_at', ascending: false)
          .limit(3),
      client
          .from('productions')
          .select('id,title_ar,title_en,synopsis_ar,synopsis_en,poster_url,production_year')
          .eq('status', 'published')
          .order('sort_order')
          .limit(3),
      client
          .from('festival_editions')
          .select('id,title_ar,title_en,year,slogan_ar,slogan_en,hero_image_url')
          .eq('status', 'published')
          .order('year', ascending: false)
          .limit(1),
    ]);
    return {
      'news': List<Map<String, dynamic>>.from(results[0] as List),
      'productions': List<Map<String, dynamic>>.from(results[1] as List),
      'festival': List<Map<String, dynamic>>.from(results[2] as List),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        if (snapshot.hasError) {
          return ErrorView(english: english, message: snapshot.error.toString());
        }
        final data = snapshot.data!;
        final festival = data['festival']!.isEmpty ? null : data['festival']!.first;
        return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF173B3A), Color(0xFF101414)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  border: Border.all(color: _accent.withValues(alpha: .35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.theaters, color: _accent, size: 34),
                    const SizedBox(height: 14),
                    Text(
                      english ? 'Reviving & Developing the Arts' : 'إحياء وتطوير الفنون',
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      english
                          ? 'Discover our productions, workshops and festival.'
                          : 'اكتشف عروضنا وورش العمل وفعاليات المهرجان.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (festival != null) ...[
                SectionHeading(title: english ? 'Festival' : 'المهرجان'),
                ContentCard(
                  row: festival,
                  english: english,
                  titleAr: 'title_ar',
                  titleEn: 'title_en',
                  descriptionAr: 'slogan_ar',
                  descriptionEn: 'slogan_en',
                  imageField: 'hero_image_url',
                  trailing: festival['year']?.toString(),
                ),
              ],
              SectionHeading(title: english ? 'Latest news' : 'آخر الأخبار'),
              if (data['news']!.isEmpty)
                EmptyView(english: english)
              else
                ...data['news']!.map((row) => ContentCard(
                      row: row,
                      english: english,
                      titleAr: 'title_ar',
                      titleEn: 'title_en',
                      descriptionAr: 'excerpt_ar',
                      descriptionEn: 'excerpt_en',
                      imageField: 'cover_image_url',
                    )),
              SectionHeading(title: english ? 'Our productions' : 'من عروضنا'),
              if (data['productions']!.isEmpty)
                EmptyView(english: english)
              else
                ...data['productions']!.map((row) => ContentCard(
                      row: row,
                      english: english,
                      titleAr: 'title_ar',
                      titleEn: 'title_en',
                      descriptionAr: 'synopsis_ar',
                      descriptionEn: 'synopsis_en',
                      imageField: 'poster_url',
                      trailing: row['production_year']?.toString(),
                    )),
            ],
        );
      },
    );
  }
}

class ContentListPage extends StatelessWidget {
  const ContentListPage({
    super.key,
    required this.english,
    required this.table,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.dateColumn,
  });

  final bool english;
  final String table;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String dateColumn;

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await Supabase.instance.client
        .from(table)
        .select()
        .eq('status', 'published')
        .order(dateColumn, ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
        if (snapshot.hasError) return ErrorView(english: english, message: snapshot.error.toString());
        final rows = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(english ? titleEn : titleAr,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(english ? subtitleEn : subtitleAr,
                style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 18),
            if (rows.isEmpty)
              EmptyView(english: english)
            else
              ...rows.map((row) => ContentCard(
                    row: row,
                    english: english,
                    titleAr: 'title_ar',
                    titleEn: 'title_en',
                    descriptionAr: table == 'news_posts' ? 'excerpt_ar' : 'synopsis_ar',
                    descriptionEn: table == 'news_posts' ? 'excerpt_en' : 'synopsis_en',
                    imageField: table == 'news_posts' ? 'cover_image_url' : 'poster_url',
                  )),
          ],
        );
      },
    );
  }
}

class WorkshopsShowsPage extends StatelessWidget {
  const WorkshopsShowsPage({super.key, required this.english});
  final bool english;

  Future<List<List<Map<String, dynamic>>>> _load() async {
    final client = Supabase.instance.client;
    final results = await Future.wait<dynamic>([
      client.from('workshops').select().eq('status', 'published').order('starts_at').limit(40),
      client.from('productions').select().eq('status', 'published').order('sort_order').limit(40),
    ]);
    return results.map((rows) => List<Map<String, dynamic>>.from(rows as List)).toList();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<List<Map<String, dynamic>>>>(
    future: _load(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
      if (snapshot.hasError) return ErrorView(english: english, message: snapshot.error.toString());
      final groups = snapshot.data ?? [[], []];
      return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 30), children: [
        Text(english ? 'Workshops & Shows' : 'الورش والعروض',
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(english ? 'Learn, participate and book your theatre experience.'
            : 'اتعلم، شارك، واحجز مكانك في تجربتك المسرحية.',
            style: const TextStyle(color: Colors.white60)),
        SectionHeading(title: english ? 'Workshops' : 'الورش التدريبية'),
        if (groups[0].isEmpty) EmptyView(english: english)
        else ...groups[0].map((row) => ContentCard(
          row: row, english: english, titleAr: 'title_ar', titleEn: 'title_en',
          descriptionAr: 'description_ar', descriptionEn: 'description_en',
          imageField: 'cover_image_url',
          trailing: row['starts_at'] == null ? null : DateTime.tryParse(row['starts_at'].toString())?.toLocal().toString().substring(0, 16),
        )),
        SectionHeading(title: english ? 'Our productions' : 'العروض المسرحية'),
        if (groups[1].isEmpty) EmptyView(english: english)
        else ...groups[1].map((row) => ContentCard(
          row: row, english: english, titleAr: 'title_ar', titleEn: 'title_en',
          descriptionAr: 'synopsis_ar', descriptionEn: 'synopsis_en',
          imageField: 'poster_url', trailing: row['production_year']?.toString(),
        )),
      ]);
    },
  );
}

class FestivalPage extends StatelessWidget {
  const FestivalPage({super.key, required this.english});
  final bool english;

  Future<List<List<Map<String, dynamic>>>> _load() async {
    final client = Supabase.instance.client;
    final editions = await client.from('festival_editions').select().eq('status', 'published').order('year', ascending: false).limit(5);
    final events = await client.from('festival_events').select().eq('is_published', true).order('starts_at').limit(80);
    final calls = await client.from('open_calls').select().inFilter('status', ['published', 'closed']).order('closes_at').limit(30);
    return [
      List<Map<String, dynamic>>.from(editions),
      List<Map<String, dynamic>>.from(events),
      List<Map<String, dynamic>>.from(calls),
    ];
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<List<Map<String, dynamic>>>>(
    future: _load(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
      if (snapshot.hasError) return ErrorView(english: english, message: snapshot.error.toString());
      final groups = snapshot.data ?? [[], [], []];
      return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 30), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFF17413F), Color(0xFF101717)],
              begin: Alignment.topRight, end: Alignment.bottomLeft),
            border: Border.all(color: _accent.withValues(alpha: .4)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.theater_comedy, color: _accent, size: 34),
            const SizedBox(height: 12),
            Text(english ? 'Minya International Theatre Festival' : 'مهرجان المنيا المسرحي الدولي',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(english ? 'Festival editions, programme, open calls and news.'
              : 'دورات المهرجان وبرنامجه وفعالياته ودعوات المشاركة.',
              style: const TextStyle(color: Colors.white70, height: 1.5)),
          ]),
        ),
        SectionHeading(title: english ? 'Festival editions' : 'دورات المهرجان'),
        if (groups[0].isEmpty) EmptyView(english: english)
        else ...groups[0].map((row) => ContentCard(row: row, english: english,
          titleAr: 'title_ar', titleEn: 'title_en', descriptionAr: 'description_ar',
          descriptionEn: 'description_en', imageField: 'hero_image_url', trailing: row['year']?.toString())),
        SectionHeading(title: english ? 'Events & programme' : 'الفعاليات والبرنامج'),
        if (groups[1].isEmpty) EmptyView(english: english)
        else ...groups[1].map((row) => ContentCard(row: row, english: english,
          titleAr: 'title_ar', titleEn: 'title_en', descriptionAr: 'description_ar',
          descriptionEn: 'description_en', imageField: 'cover_image_url',
          trailing: row['starts_at'] == null ? null : DateTime.tryParse(row['starts_at'].toString())?.toLocal().toString().substring(0, 16))),
        SectionHeading(title: english ? 'Open calls' : 'دعوات المشاركة'),
        if (groups[2].isEmpty) EmptyView(english: english)
        else ...groups[2].map((row) => ContentCard(row: row, english: english,
          titleAr: 'title_ar', titleEn: 'title_en', descriptionAr: 'description_ar',
          descriptionEn: 'description_en', imageField: 'cover_image_url',
          trailing: row['closes_at'] == null ? null : (english ? 'Deadline: ' : 'آخر موعد: ') + DateTime.tryParse(row['closes_at'].toString())!.toLocal().toString().substring(0, 16))),
      ]);
    },
  );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.english});
  final bool english;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.school_outlined, english ? 'Academy' : 'الأكاديمية', 'https://teatroalsaeed.org/academy'),
      (Icons.groups_outlined, english ? 'Our troupe' : 'الفرقة', 'https://teatroalsaeed.org/troupe'),
      (Icons.lightbulb_outline, english ? 'Sahara project' : 'مشروع صحارة', 'https://teatroalsaeed.org/sahara'),
      (Icons.language, english ? 'Official website' : 'الموقع الرسمي', 'https://teatroalsaeed.org'),
      (Icons.mail_outline, english ? 'Contact us' : 'تواصل معنا', 'https://teatroalsaeed.org/contact'),
    ];
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(english ? 'Explore Teatro AlSaeed' : 'اكتشف تياترو الصعيد',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_available, color: _accent),
            title: Text(english ? 'Activities & updates' : 'الأنشطة والتحديثات'),
            subtitle: Text(english
                ? 'Workshops, festival events, open calls and app announcements'
                : 'الورش وفعاليات المهرجان ودعوات المشاركة وإعلانات التطبيق'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ActivitiesPage(english: english),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Card(
              child: ListTile(
                leading: Icon(item.$1, color: _accent),
                title: Text(item.$2),
                subtitle: Text(item.$3, style: const TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  final uri = Uri.parse(item.$3);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
            )),
        const SizedBox(height: 18),
        Text(
          english ? 'Version 1.0.0 · Teatro AlSaeed' : 'الإصدار 1.0.0 · تياترو الصعيد',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38),
        ),
      ],
    );
  }
}

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.row,
    required this.english,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imageField,
    this.trailing,
  });

  final Map<String, dynamic> row;
  final bool english;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imageField;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final title = localized(row, titleAr, titleEn, english);
    final description = localized(row, descriptionAr, descriptionEn, english);
    final imageUrl = row[imageField]?.toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    if (trailing != null) ...[
                      const SizedBox(height: 6),
                      Text(trailing!, style: const TextStyle(color: _accent)),
                    ],
                    const SizedBox(height: 12),
                    Text(description.isEmpty
                        ? (english ? 'More details will be available soon.' : 'سيتم إضافة التفاصيل قريبًا.')
                        : description),
                  ],
                ),
              ),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.startsWith('http'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    imageUrl,
                    width: 94,
                    height: 112,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder(),
                  ),
                )
              else
                _imagePlaceholder(),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    if (trailing != null) ...[
                      const SizedBox(height: 3),
                      Text(trailing!, style: const TextStyle(color: _accent, fontSize: 12)),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white60, height: 1.5)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        width: 94,
        height: 112,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2727),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Icon(Icons.theaters_outlined, color: _accent, size: 30),
      );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: _accent),
      );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.english});
  final bool english;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(22),
        child: Text(
          english ? 'No published content yet.' : 'لا يوجد محتوى منشور حاليًا.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54),
        ),
      );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.english, required this.message, this.onRetry});
  final bool english;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: _accent, size: 42),
              const SizedBox(height: 12),
              Text(english ? 'Could not load content' : 'تعذر تحميل المحتوى'),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(onPressed: onRetry, child: Text(english ? 'Retry' : 'إعادة المحاولة')),
              ],
            ],
          ),
        ),
      );
}
