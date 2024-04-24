
extension IntDigits on int {
  void _checkValueLimits() {
    if (abs() > 999) {
      throw UnsupportedError("Only integers < 1000 are supported");
    }
  }

  int hundreds() {
    _checkValueLimits();

    return this ~/ 100;
  }

  int tens() {
    return (this - hundreds() * 100) ~/ 10;
  }

  int ones() {
    return (this - hundreds() * 100 - tens() * 10);
  }
}
