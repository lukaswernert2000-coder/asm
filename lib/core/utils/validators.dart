final _usernamePattern = RegExp(r'^[a-zA-Z0-9_]{3,24}$');
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _digitPattern = RegExp('[0-9]');
final _letterPattern = RegExp('[a-zA-Z]');

String? validateUsername(String? value) {
  if (value == null || !_usernamePattern.hasMatch(value)) {
    return 'Nutzername muss 3–24 Zeichen lang sein und darf nur Buchstaben, '
        'Zahlen und _ enthalten';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || !_emailPattern.hasMatch(value)) {
    return 'Bitte gib eine gültige E-Mail-Adresse ein';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null ||
      value.length < 8 ||
      !_digitPattern.hasMatch(value) ||
      !_letterPattern.hasMatch(value)) {
    return 'Mindestens 8 Zeichen mit Zahl und Buchstabe';
  }
  return null;
}

String? validateBirthDate(DateTime? value, {DateTime? now}) {
  if (value == null || _age(value, now ?? DateTime.now()) < 14) {
    return 'Die Nutzung ist erst ab 14 Jahren erlaubt';
  }
  return null;
}

int _age(DateTime birthDate, DateTime now) {
  var age = now.year - birthDate.year;
  final hadBirthdayThisYear =
      now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  if (!hadBirthdayThisYear) age--;
  return age;
}

String? validateConsent({required bool agb, required bool datenschutz}) {
  if (!agb || !datenschutz) {
    return 'Bitte bestätige AGB und Datenschutz';
  }
  return null;
}
