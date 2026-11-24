/// Escapes separators and neutralizes spreadsheet formulas in untrusted cells.
String encodeCsv(Iterable<Iterable<Object?>> rows) => rows
    .map(
      (row) => row
          .map((cell) {
            var value = cell?.toString() ?? '';
            if (RegExp(r'^\s*[=+@\-\t\r]').hasMatch(value)) value = "'$value";
            return '"${value.replaceAll('"', '""')}"';
          })
          .join(','),
    )
    .join('\r\n');
