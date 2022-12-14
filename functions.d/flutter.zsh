
flutter-pub-get() {
    (cd "$1"; flutter pub get)
}

flutter-test() {
    (cd "$1"; make test | tr '' '\n') | tee make_test_${1//\//_}.log
}
