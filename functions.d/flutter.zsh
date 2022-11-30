
flutter-pub-get() {
    (cd "$1"; flutter pub get; git checkout pubspec.lock)
}

flutter-test() {
    (cd "$1"; make test; git checkout pubspec.lock) | tee make_test_${1/\//_}.log
}
