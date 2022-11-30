
flutter-pub-get() {
    (cd "$1"; flutter pub get; git checkout pubspec.lock)
}
