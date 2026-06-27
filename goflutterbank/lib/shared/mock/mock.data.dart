import 'package:goflutterbank/shared/models/activity.item.dart';
import 'package:goflutterbank/shared/models/contact.dart';

/// Mock recent-activity feed for the Home screen.
/// The backend does not expose a unified activity endpoint, so this is mocked.
const List<ActivityItem> kMockActivity = [
  ActivityItem(
    type: ActivityType.sent,
    title: 'Transferência enviada',
    subtitle: 'Para Bruno Carvalho · Hoje · 09:12',
    amount: -120.00,
  ),
  ActivityItem(
    type: ActivityType.received,
    title: 'Pix recebido',
    subtitle: 'De Helena Souza · Ontem · 18:40',
    amount: 45.90,
  ),
  ActivityItem(
    type: ActivityType.payment,
    title: 'Pagamento de conta',
    subtitle: 'Energia elétrica · 22 jun · 14:03',
    amount: -134.70,
  ),
];

/// Mock contact shortcuts for the Transfer screen.
/// CPFs are raw 11-digit strings.
const List<Contact> kMockContacts = [
  Contact(initials: 'BC', shortName: 'Bruno C.', cpf: '18255764008'),
  Contact(initials: 'HS', shortName: 'Helena S.', cpf: '30511987244'),
  Contact(initials: 'DM', shortName: 'Diego M.', cpf: '77420315890'),
];

/// Decorative/mock account number mask.
const String kAccountMask = 'Conta corrente · ••••2841';
