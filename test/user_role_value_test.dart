import 'package:flutter_test/flutter_test.dart';
import 'package:rtc_mobile/domain/auth/user_model.dart';

void main() {
  test('stored role values round-trip and match firestore.rules', () {
    const ruleValues = ['member', 'department_head', 'admin', 'developer'];
    final assignable = UserRole.values.where((r) => r != UserRole.guest);
    expect(assignable.map((r) => r.value), ruleValues);
    for (final role in assignable) {
      expect(UserRole.fromString(role.value), role);
    }
  });
}
