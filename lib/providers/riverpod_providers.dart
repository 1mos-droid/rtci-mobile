import 'package:rtc_mobile/application/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rtc_mobile/providers/members_provider.dart';
import 'package:rtc_mobile/providers/application_provider.dart';
import 'package:rtc_mobile/providers/prayer_provider.dart';
import 'package:rtc_mobile/providers/financial_provider.dart';
import 'package:rtc_mobile/providers/events_provider.dart';
import 'package:rtc_mobile/providers/care_provider.dart';
import 'package:rtc_mobile/providers/insights_provider.dart';
import 'package:rtc_mobile/providers/groups_provider.dart';
import 'package:rtc_mobile/providers/children_provider.dart';
import 'package:rtc_mobile/providers/leadership_provider.dart';
import 'package:rtc_mobile/providers/bible_studies_provider.dart';
import 'package:rtc_mobile/providers/bible_provider.dart';
import 'package:rtc_mobile/providers/gallery_provider.dart';
import 'package:rtc_mobile/providers/attendance_provider.dart';
import 'package:rtc_mobile/providers/broadcast_provider.dart';
import 'package:rtc_mobile/providers/sermon_provider.dart';

export 'package:rtc_mobile/providers/members_provider.dart';
export 'package:rtc_mobile/providers/application_provider.dart';
export 'package:rtc_mobile/providers/prayer_provider.dart';
export 'package:rtc_mobile/providers/financial_provider.dart';
export 'package:rtc_mobile/providers/events_provider.dart';
export 'package:rtc_mobile/providers/care_provider.dart';
export 'package:rtc_mobile/providers/insights_provider.dart';
export 'package:rtc_mobile/providers/groups_provider.dart';
export 'package:rtc_mobile/providers/children_provider.dart';
export 'package:rtc_mobile/providers/leadership_provider.dart';
export 'package:rtc_mobile/providers/bible_studies_provider.dart';
export 'package:rtc_mobile/providers/bible_provider.dart';
export 'package:rtc_mobile/providers/gallery_provider.dart';
export 'package:rtc_mobile/providers/attendance_provider.dart';
export 'package:rtc_mobile/providers/broadcast_provider.dart';
export 'package:rtc_mobile/providers/sermon_provider.dart';
export 'package:rtc_mobile/models/sermon.dart';

// Feature state belongs to a single account and privilege level. Rebuilding
// drops cached personal data instead of carrying it to the next signed-in user.
final accountSessionProvider = Provider((ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  return (user?.id, user?.role);
});

final membersProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return MembersProvider();
});
final applicationProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return ApplicationProvider();
});
final prayerProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return PrayerProvider();
});
final financialProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return FinancialProvider(ref);
});
final eventsProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return EventsProvider();
});
final careProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return CareProvider();
});
final dailyInsightsProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return DailyInsightsProvider();
});
final groupsProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return GroupsProvider();
});
final childrenProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return ChildrenProvider();
});
final leadershipProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return LeadershipProvider();
});
final bibleStudiesProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return BibleStudiesProvider();
});
final bibleProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return BibleProvider();
});
final galleryProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return GalleryProvider();
});
final attendanceProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return AttendanceProvider();
});
final broadcastProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return BroadcastProvider();
});
final sermonProvider = ChangeNotifierProvider((ref) {
  ref.watch(accountSessionProvider);
  return SermonProvider();
});
