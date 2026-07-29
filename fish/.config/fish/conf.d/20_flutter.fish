set -gx PUB_HOSTED_URL "https://pub.flutter-io.cn"
set -gx FLUTTER_STORAGE_BASE_URL "https://storage.flutter-io.cn"

if test -d "$HOME/fvm/bin"
    fish_add_path --global --prepend "$HOME/fvm/bin"
end
