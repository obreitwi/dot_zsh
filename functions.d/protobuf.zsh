#!/usr/bin/env zsh

proto-msg-raw() {
   find $(git-root) -type f -name "*.proto" -print0 | xargs -0 grep -n '^\s*message' | sed -e 's:\s*{}\?\s*$::' | fzf --with-nth 2
}
# find proto message in current git repo
proto-msg() {
   proto-msg-raw | sed 's/:[^:]*$//g'
}

proto-bat() {
   local info
   local file
   local msg
   info=$(proto-msg-raw)
   msg=$(awk '{ print $NF }' <<<"$info")
   file=$(awk -F : '{ print $1 }' <<<"$info")
   sed -n "/^message $msg\s*{/,/}/p" "$file" | bat -l proto
}

proto-nvim() {
   local file
   file=$(proto-msg)
   if [ -n "$file" ]; then
      nvim "$file"
   else
      return 1
   fi
}
