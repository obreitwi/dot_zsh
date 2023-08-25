#!/usr/bin/env zsh

# find proto message in current git repo
proto-msg() {
   find $(git-root) -type f -name "*.proto" -print0 | xargs -0 grep -n '^\s*message' | sed -e 's:\s*{}\?\s*$::' | fzf --with-nth 2 | sed 's/:[^:]*$//g'
}

nvim-proto() {
   local file
   file=$(proto-msg)
   if [ -n "$file" ]; then
      nvim "$file"
   else
      return 1
   fi
}
