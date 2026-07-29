if set -q ANDROID_HOME; and test -d "$ANDROID_HOME"
    fish_add_path --global --prepend \
        "$ANDROID_HOME/cmdline-tools/latest/bin" \
        "$ANDROID_HOME/platform-tools" \
        "$ANDROID_HOME/emulator"
end
