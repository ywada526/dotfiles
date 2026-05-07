# zoxide wrapper: run interactive zi when called with no args, otherwise forward to z.
c() { if [ $# -eq 0 ]; then zi; else z "$@"; fi }
