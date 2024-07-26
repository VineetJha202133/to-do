enum SharedPreferencesKeyEnum {
  // phoneNumber('phoneNumber'),
  // emailData('email'),
  // languageData('language'),
  id('id'),
  userId('userId'),
  isLoggedIn('isLoggedIn'),
  venue('venue'),
  isManager('isManager'),
  deviceToken('deviceToken');

  const SharedPreferencesKeyEnum(this.value);
  final String value;
}
