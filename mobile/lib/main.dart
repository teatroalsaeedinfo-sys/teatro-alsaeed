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
      TeatroPage(english: english),
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
            icon: const Icon(Icons.groups_2_outlined),
            selectedIcon: const Icon(Icons.groups_2),
            label: english ? 'Teatro' : 'تياترو',
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

class TeatroPage extends StatelessWidget {
  const TeatroPage({super.key, required this.english});
  final bool english;

  @override
  Widget build(BuildContext context) {
    final sections = [
      (Icons.groups_outlined, english ? 'The troupe' : 'الفرقة',
        english ? 'Our artists, productions and creative journey' : 'أخبار الفرقة وفنانيها وإنتاجها المسرحي',
        'https://teatroalsaeed.org/troupe'),
      (Icons.school_outlined, english ? 'The academy' : 'الأكاديمية',
        english ? 'Training programmes and learning opportunities' : 'الورش التدريبية والبرامج التعليمية وفرص التعلم',
        'https://teatroalsaeed.org/academy'),
      (Icons.lightbulb_outline, english ? 'Sahara project' : 'مشروع صحارة',
        english ? 'Reviving the performing arts heritage of Upper Egypt' : 'إحياء تراث الفنون الأدائية في صعيد مصر',
        'https://teatroalsaeed.org/sahara'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      children: [
        Text(english ? 'Teatro AlSaeed' : 'تياترو الصعيد',
          style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(english ? 'News, people and programmes' : 'أخبارنا وفريقنا وبرامجنا',
          style: const TextStyle(color: Colors.white60, fontSize: 14)),
        const SizedBox(height: 20),
        for (final item in sections)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              leading: Icon(item.$1, color: _accent, size: 30),
              title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(item.$3, style: const TextStyle(color: Colors.white60, height: 1.5)),
              ),
              trailing: const Icon(Icons.arrow_outward, color: Colors.white54),
              onTap: () async {
                final uri = Uri.parse(item.$4);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ),
        const SectionHeading(title: ' '),
        Text(english ? 'Latest news' : 'آخر الأخبار',
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: ContentListPage(
            english: english, table: 'news_posts',
            titleAr: 'الأخبار', titleEn: 'News',
            subtitleAr: 'آخر أخبار تياترو الصعيد', subtitleEn: 'Latest Teatro AlSaeed news',
            dateColumn: 'published_at',
          ),
        ),
      ],
    );
  }
}

class WorkshopsShowsPage extends StatefulWidget {
  const WorkshopsShowsPage({super.key, required this.english});
  final bool english;
  @override
  State<WorkshopsShowsPage> createState() => _WorkshopsShowsPageState();
}

class _WorkshopsShowsPageState extends State<WorkshopsShowsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final en = widget.english;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
        child: Align(alignment: AlignmentDirectional.centerStart,
          child: Text(en ? 'Workshops & performances' : 'الورش والعروض',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
      ),
      TabBar(controller: _tabs, labelColor: _accent, tabs: [
        Tab(text: en ? 'Workshops & applications' : 'الورش والتقديم'),
        Tab(text: en ? 'Performances & archive' : 'العروض والحجز'),
      ]),
      Expanded(child: TabBarView(controller: _tabs, children: [
        ActivitiesPage(english: en),
        ContentListPage(
          english: en, table: 'productions',
          titleAr: 'العروض المسرحية', titleEn: 'Theatre productions',
          subtitleAr: 'اكتشف عروض تياترو الصعيد', subtitleEn: 'Discover our theatre productions',
          dateColumn: 'production_year',
        ),
      ])),
    ]);
  }
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

class FestivalPage extends StatefulWidget {
  const FestivalPage({super.key, required this.english});
  final bool english;

  @override
  State<FestivalPage> createState() => _FestivalPageState();
}

class _FestivalPageState extends State<FestivalPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> _future;

  bool get en => widget.english;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _load() async {
    final client = Supabase.instance.client;
    final results = await Future.wait<dynamic>([
      client.from('festival_editions').select()
          .eq('status', 'published').order('year', ascending: false).limit(10),
      client.from('festival_events').select()
          .eq('is_published', true).order('starts_at', ascending: true).limit(100),
      client.from('open_calls').select()
          .inFilter('status', ['published', 'closed'])
          .order('closes_at', ascending: true).limit(50),
      client.from('app_announcements').select()
          .eq('is_published', true)
          .or('publish_at.is.null,publish_at.lte.${DateTime.now().toUtc().toIso8601String()}')
          .order('publish_at', ascending: false).limit(20),
    ]);
    return {
      'editions': List<Map<String, dynamic>>.from(results[0] as List),
      'events': List<Map<String, dynamic>>.from(results[1] as List),
      'calls': List<Map<String, dynamic>>.from(results[2] as List),
      'announcements': List<Map<String, dynamic>>.from(results[3] as List),
    };
  }

  String _date(dynamic value, {bool includeTime = true}) {
    if (value == null) return '';
    final parsed = DateTime.tryParse(value.toString())?.toLocal();
    if (parsed == null) return '';
    final date = MaterialLocalizations.of(context).formatMediumDate(parsed);
    if (!includeTime) return date;
    return '$date · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(parsed))}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LoadingView();
        if (snapshot.hasError) {
          return ErrorView(
            english: en,
            message: snapshot.error.toString(),
            onRetry: () => setState(() => _future = _load()),
          );
        }
        final data = snapshot.data!;
        final editions = data['editions']!;
        final events = data['events']!;
        final calls = data['calls']!;
        final announcements = data['announcements']!;
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _load()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
                    const Icon(Icons.theater_comedy, color: _accent, size: 34),
                    const SizedBox(height: 12),
                    Text(
                      en ? 'Minya International Theatre Festival' : 'مهرجان المنيا المسرحي الدولي',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      en ? 'Festival programme, dates and participation opportunities.'
                          : 'البرنامج ومواعيد الفعاليات وفرص المشاركة والتقديم.',
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
              SectionHeading(title: en ? 'Festival editions' : 'دورات المهرجان'),
              if (editions.isEmpty)
                EmptyView(english: en)
              else
                ...editions.map((edition) {
                  final id = edition['id']?.toString();
                  final editionEvents = events.where((event) =>
                      event['edition_id']?.toString() == id).toList();
                  final editionCalls = calls.where((call) =>
                      call['festival_edition_id']?.toString() == id).toList();
                  final dateRange = [
                    _date(edition['starts_on'], includeTime: false),
                    _date(edition['ends_on'], includeTime: false),
                  ].where((value) => value.isNotEmpty).join(' — ');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContentCard(
                        row: edition,
                        english: en,
                        titleAr: 'title_ar',
                        titleEn: 'title_en',
                        descriptionAr: 'slogan_ar',
                        descriptionEn: 'slogan_en',
                        imageField: 'hero_image_url',
                        trailing: edition['year']?.toString(),
                      ),
                      if (dateRange.isNotEmpty || localized(edition, 'venue_ar', 'venue_en', en).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                          child: Text(
                            [
                              dateRange,
                              localized(edition, 'venue_ar', 'venue_en', en),
                            ].where((value) => value.isNotEmpty).join('  •  '),
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                      if (editionEvents.isNotEmpty) ...[
                        Text(en ? 'Programme & events' : 'البرنامج والفعاليات',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        ...editionEvents.map(_eventCard),
                      ],
                      if (editionCalls.isNotEmpty) ...[
                        Text(en ? 'Participation & applications' : 'التقديم والمشاركة',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        ...editionCalls.map(_callCard),
                      ],
                      const SizedBox(height: 12),
                    ],
                  );
                }),
              SectionHeading(title: en ? 'Festival announcements' : 'إعلانات المهرجان'),
              if (announcements.isEmpty)
                EmptyView(english: en)
              else
                ...announcements.map(_announcementCard),
              if (editions.isNotEmpty && events.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    en ? 'The detailed programme will be announced soon.'
                        : 'سيتم الإعلان عن البرنامج التفصيلي قريبًا.',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _eventCard(Map<String, dynamic> row) {
    final title = localized(row, 'title_ar', 'title_en', en);
    final description = localized(row, 'description_ar', 'description_en', en);
    final venue = localized(row, 'venue_ar', 'venue_en', en);
    final type = (row['event_type'] ?? 'other').toString();
    final date = _date(row['starts_at']);
    final end = _date(row['ends_at']);
    final typeLabels = en
        ? {'performance':'Performance','workshop':'Workshop','opening':'Opening','closing':'Closing','talk':'Talk','screening':'Screening'}
        : {'performance':'عرض مسرحي','workshop':'ورشة','opening':'الافتتاح','closing':'الختام','talk':'ندوة','screening':'عرض فيلم'};
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event, color: _accent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text([
            typeLabels[type] ?? (en ? 'Event' : 'فعالية'),
            date,
            if (end.isNotEmpty && end != date) end,
            venue,
            description,
          ].where((value) => value.isNotEmpty).join(' · '),
            style: const TextStyle(color: Colors.white60, height: 1.5)),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _callCard(Map<String, dynamic> row) {
    final title = localized(row, 'title_ar', 'title_en', en);
    final description = localized(row, 'description_ar', 'description_en', en);
    final closes = _date(row['closes_at'], includeTime: false);
    final url = row['application_url']?.toString();
    final closed = row['status'] == 'closed';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            Text(closed ? (en ? 'Closed' : 'مغلق') : (en ? 'Open' : 'مفتوح'),
              style: TextStyle(color: closed ? Colors.white54 : _accent, fontWeight: FontWeight.bold)),
          ]),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(description, style: const TextStyle(color: Colors.white70, height: 1.5)),
          ],
          if (closes.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(en ? 'Deadline: $closes' : 'آخر موعد للتقديم: $closes',
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
          if (url != null && url.startsWith('http') && !closed) ...[
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                onPressed: () => _openUrl(url),
                icon: const Icon(Icons.assignment_outlined),
                label: Text(en ? 'Apply now' : 'قدّم الآن'),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _announcementCard(Map<String, dynamic> row) {
    final title = localized(row, 'title_ar', 'title_en', en);
    final message = localized(row, 'message_ar', 'message_en', en);
    final url = row['target_url']?.toString();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined, color: _accent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(message, style: const TextStyle(color: Colors.white60, height: 1.5)),
        trailing: url != null && url.startsWith('http')
            ? const Icon(Icons.open_in_new, color: Colors.white54)
            : null,
        onTap: url != null && url.startsWith('http') ? () => _openUrl(url) : null,
      ),
    );
  }

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
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
