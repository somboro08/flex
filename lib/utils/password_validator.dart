/// Mirrors the backend `validator.IsStrongPassword` rules so the UI can
/// reject weak passwords before calling the API.
String? strongPasswordError(String password) {
  if (password.length < 8) {
    return '8 caractères minimum.';
  }
  if (password.length > 128) {
    return '128 caractères maximum.';
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Ajoutez une majuscule.';
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Ajoutez une minuscule.';
  }
  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return 'Ajoutez un chiffre.';
  }
  if (!RegExp(r'[!@#$%^&*]').hasMatch(password)) {
    return 'Ajoutez un caractère spécial (!@#\$%^&*).';
  }
  return null;
}
