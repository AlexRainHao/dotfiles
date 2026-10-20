"""Keep zoxide's live database in runtime memory; persist atomic snapshots."""

import fcntl
import hashlib
import os
from pathlib import Path
import shutil
import sys
import tempfile


def initialize(persistent, runtime_root):
    identity = hashlib.sha256(os.fsencode(persistent)).hexdigest()[:16]
    # Keep the plugin integration separate from the earlier standalone cache.
    # Its first session must restore the current disk history after migration.
    runtime = runtime_root / "fish-zoxide" / ("plugin-" + identity)
    runtime.mkdir(mode=0o700, parents=True, exist_ok=True)
    destination = runtime / "db.zo"
    # Existing sessions may be fsyncing a disk snapshot. A new shell must not
    # wait for that writer when its live database is already available.
    if not destination.exists():
        with (runtime / "persist.lock").open("a+b") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            source = persistent / "db.zo"
            if not destination.exists() and source.exists():
                # Other shells see either the complete copy or no file at all.
                temporary = runtime / "restore.tmp"
                try:
                    shutil.copyfile(source, temporary)
                    os.replace(temporary, destination)
                finally:
                    temporary.unlink(missing_ok=True)
    print(persistent)
    print(runtime)


def persist(persistent, runtime):
    with (runtime / "persist.lock").open("a+b") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        source = runtime / "db.zo"
        if not source.exists():
            return
        # Zoxide atomically replaces db.zo, so this reads a complete generation
        # even if another shell is updating the live database.
        snapshot = source.read_bytes()
        destination = persistent / "db.zo"
        try:
            if destination.read_bytes() == snapshot:
                return
        except FileNotFoundError:
            pass
        persistent.mkdir(mode=0o700, parents=True, exist_ok=True)
        descriptor, temporary = tempfile.mkstemp(prefix=".db.zo-", dir=persistent)
        try:
            with os.fdopen(descriptor, "wb") as stream:
                stream.write(snapshot)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, destination)
        finally:
            Path(temporary).unlink(missing_ok=True)


if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[1] not in {"init", "persist"}:
        raise SystemExit("Usage: __dotfiles_zoxide_runtime.py init|persist DISK_DIR RUNTIME_DIR")
    mode, disk_directory, runtime_directory = sys.argv[1:]
    disk_directory = Path(disk_directory).expanduser().resolve()
    runtime_directory = Path(runtime_directory).resolve()
    if mode == "init":
        initialize(disk_directory, runtime_directory)
    else:
        persist(disk_directory, runtime_directory)
