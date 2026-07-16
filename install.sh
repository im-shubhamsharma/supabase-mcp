#!/usr/bin/env bash
# Convenience installer for a direct clone of this repo.
# Puts supa-mcp on your PATH (~/.local/bin by default) and checks dependencies.
#
#   ./install.sh                 # install to ~/.local/bin
#   ./install.sh /usr/local/bin  # install elsewhere
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
exec "$here/bin/supa-mcp" install "$@"
