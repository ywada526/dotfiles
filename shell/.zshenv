# bash subshells: interactive non-login reads .bashrc, but non-interactive
# (scripts, `bash -c '...'`) only honors BASH_ENV. Point it at .bashrc so
# every bash entry point funnels through the same file.
export BASH_ENV="$HOME/.bashrc"

# Wrap package manager calls via Safe Chain when setup has installed its
# shell integration.
. "$HOME/.safe-chain/scripts/init-posix.sh"
