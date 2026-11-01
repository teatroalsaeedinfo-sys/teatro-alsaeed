import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _activityAccent = Color(0xFF2BB3B1);

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key, required this.english});
  final bool english;

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  late Future<List<List<Map<String, dynamic>>>> _future;

  bool get en => widget.english;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<List<List<Map<String, dynamic>>>> _load() async {
    final client = Supabase.instance.client;
    final results = await Future.wait<dynamic>([
      client.from('workshops').select().eq('status', 'published')
          .order('starts_at', ascending: true).limit(50),
      client.from('festival_events').select().eq('is_published', true)
          .order('starts_at', ascending: true).limit(80),
      client.from('open_calls').select().inFilter('status', ['published', 'closed'])
          .order('closes_at', ascending: true).limit(50),
      client.from('app_announcements').select()
          .eq('is_published', true)
          .or('publish_at.is.null,publish_at.lte.${DateTime.now().toUtc().toIso8601String()}')
          .order('publish_at', ascending: false).limit(30),
    ]);
    return results.map((rows) => List<Map<String, dynamic>>.from(rows as List)).toList();
  }

  String _value(Map<String, dynamic> row, String ar, String en) {
    final first = row[widget.english ? en : ar];
    final second = row[widget.english ? ar : en];
    return (first ?? second ?? '').toString();
  }

  String _date(dynamic value) {
    if (value == null) return '';
    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return '';
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final labels = en
        ? ['Workshops', 'Festival events', 'Open calls', 'Announcements']
        : ['الورش', 'فعاليات المهرجان', 'دعوات المشاركة', 'إعلانات التطبيق'];
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _error(snapshot.error.toString());
        }
        final groups = snapshot.data ?? List.generate(4, (_) => <Map<String, dynamic>>[]);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(en ? 'Activities & updates' : 'الأنشطة والتحديثات',
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              ),
            ),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: _activityAccent,
              tabs: [for (final label in labels) Tab(text: label)],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  for (var i = 0; i < 4; i++) _list(groups[i], i),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _error(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off, size: 42, color: Colors.white54),
        const SizedBox(height: 12),
        Text(en ? 'Could not load content' : 'تعذر تحميل المحتوى'),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        TextButton.icon(
          onPressed: () => setState(() => _future = _load()),
          icon: const Icon(Icons.refresh),
          label: Text(en ? 'Try again' : 'إعادة المحاولة'),
        ),
      ]),
    ),
  );

  Widget _list(List<Map<String, dynamic>> rows, int type) {
    if (rows.isEmpty) {
      return Center(child: Text(en ? 'No published content yet' : 'لا يوجد محتوى منشور حاليًا',
          style: const TextStyle(color: Colors.white60)));
    }
    return RefreshIndicator(
      onRefresh: () async => setState(() => _future = _load()),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _card(rows[index], type),
      ),
    );
  }

  Widget _card(Map<String, dynamic> row, int type) {
    final title = switch (type) {
      0 || 1 => _value(row, 'title_ar', 'title_en'),
      2 => _value(row, 'title_ar', 'title_en'),
      _ => _value(row, 'title_ar', 'title_en'),
    };
    final description = switch (type) {
      0 => _value(row, 'description_ar', 'description_en'),
      1 => _value(row, 'description_ar', 'description_en'),
      2 => _value(row, 'description_ar', 'description_en'),
      _ => _value(row, 'message_ar', 'message_en'),
    };
    final date = switch (type) {
      0 => _date(row['starts_at']),
      1 => _date(row['starts_at']),
      2 => _date(row['closes_at']),
      _ => _date(row['publish_at']),
    };
    final image = type == 0 ? row['cover_image_url'] : type == 1 ? row['cover_image_url'] : null;
    final actionUrl = type == 0 ? row['registration_url'] : type == 2 ? row['application_url'] : type == 3 ? row['target_url'] : null;
    final actionLabel = type == 0
        ? (en ? 'Register' : 'التسجيل')
        : type == 2
            ? (en ? 'Apply' : 'قدّم الآن')
            : (en ? 'Open link' : 'افتح الرابط');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _details(title, description, date, image?.toString(), actionUrl?.toString(), actionLabel),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (image != null && image.toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(image.toString(), width: 86, height: 86, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder()),
              )
            else
              _placeholder(),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              if (date.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: _activityAccent, fontSize: 12)),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(description, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, height: 1.5)),
              ],
              if (actionUrl != null && actionUrl.toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(actionLabel, style: const TextStyle(color: _activityAccent, fontWeight: FontWeight.bold)),
              ],
            ])),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ]),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 86, height: 86,
    decoration: BoxDecoration(color: const Color(0xFF1C2929), borderRadius: BorderRadius.circular(10)),
    child: const Icon(Icons.theaters_outlined, color: _activityAccent, size: 30),
  );

  void _details(String title, String description, String date, String? image,
      String? url, String actionLabel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111818),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (image != null && image.isNotEmpty)
                ClipRRect(borderRadius: BorderRadius.circular(14),
                  child: Image.network(image, width: double.infinity, height: 190, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink())),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              if (date.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(date, style: const TextStyle(color: _activityAccent)),
              ],
              const SizedBox(height: 12),
              SelectableText(description, style: const TextStyle(height: 1.7, color: Colors.white80)),
              if (url != null && url.isNotEmpty) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(url);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(actionLabel),
                ),
              ],
            ],
          )),
        ),
      ),
    );
  }
}
