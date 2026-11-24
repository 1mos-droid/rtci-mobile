import 'package:flutter_test/flutter_test.dart';
import 'package:rtc_mobile/utils/csv.dart';

void main() {
  test('CSV preserves commas, quotes, newlines and empty cells', () {
    expect(
      encodeCsv([
        ['Name', 'Note'],
        ['Grace, Mensah', 'Said "hello"\nNext line'],
        [null, ''],
      ]),
      '"Name","Note"\r\n"Grace, Mensah","Said ""hello""\nNext line"\r\n"",""',
    );
  });
  test('Untrusted spreadsheet formulas are neutralized', () {
    expect(
      encodeCsv([
        ['=1+1', '  +SUM(A1)', '@SUM(A1)', '-1', 'Ordinary text'],
      ]),
      '"\'=1+1","\'  +SUM(A1)","\'@SUM(A1)","\'-1","Ordinary text"',
    );
  });
}
