# Fish Preinstall Dispatcher Design

## Goal

Provide one Fish autoloaded entry point for machine bootstrap tasks. The first
supported task installs the tmux plugin manager (TPM).

## Interface

The file `~/.config/fish/functions/preinstall.fish` defines the public
`preinstall` function:

```fish
preinstall tpm
```

Fish autoloads the function because its name matches the file name. Additional
bootstrap tasks can later be added as subcommands without sourcing another
file from `config.fish`.

## TPM Installation

The `tpm` subcommand targets:

```text
$HOME/.tmux/plugins/tpm
```

Its behavior is:

1. If `$HOME/.tmux/plugins/tpm/.git` exists, print a skip message and return
   success.
2. If `$HOME/.tmux/plugins/tpm` exists but is not a Git repository, print an
   error, leave the directory untouched, and return failure.
3. Otherwise, create `$HOME/.tmux/plugins`, then run:

   ```sh
   git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
   ```

The clone command's exit status is returned to the caller.

## Dispatcher Errors

Calling `preinstall` without a subcommand or with an unsupported subcommand
prints usage containing the currently supported `tpm` command and returns
failure.

## Verification

- Run `fish -n` against `preinstall.fish`.
- Verify the existing-repository path skips without invoking Git.
- Verify a non-repository destination fails without modifying it.
- Verify an absent destination creates its parent and invokes Git with the
  expected clone URL and destination, using a local fake Git executable so the
  test does not access the network.
