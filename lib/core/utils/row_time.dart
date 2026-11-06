// Postgres returns timestamps as ISO 8601 strings in UTC.
DateTime readTime(Object? value) => DateTime.parse(value! as String).toLocal();

DateTime? readOptionalTime(Object? value) =>
    value == null ? null : readTime(value);
