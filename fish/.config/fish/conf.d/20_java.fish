if set -q JAVA_HOME; and test -x "$JAVA_HOME/bin/java"
    fish_add_path --global --prepend "$JAVA_HOME/bin"
end
