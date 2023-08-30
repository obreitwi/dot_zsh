#!/usr/bin/env zsh

proto-msg-raw() {
   args=($@)
   shift $#
   find $(git-root) -type f -name "*.proto" -print0 | xargs -0 grep -n '^\s*\(message\|enum\)' | sed -e 's:\s*{}\?\s*$::' | {
      if (( ${#args} > 0 )); then
         grep "${args[@]}"
      else
         fzf --with-nth 2
      fi
   }
}
# find proto message in current git repo
proto-msg() {
   proto-msg-raw | sed 's/:[^:]*$//g'
}

proto-bat() {
   local -a info_all
   local file
   local line_no
   local line
   local msg
   local num_matches
   local file_info

   info_all=("${(f)$(proto-msg-raw "$@")}")
   num_matches=${#info_all[@]}

   for info in "${info_all[@]}"; do
      msg=$(awk '{ print $NF }' <<<"$info")
      file=$(awk -F : '{ print $1 }' <<<"$info")
      line_no=$(awk -F : '{ print $2 }' <<<"$info")
      line=$(tail -n "+$line_no" < "$file" | head -n 1)

      file_info="$file (${num_matches} matches total)"

      if grep -qF '{}' <<<"$line"; then
         bat --color=always --file-name "$file_info" -l proto <<<"$line"
      else
         sed -n "/^\(message\|enum\) $msg\s*{/,/}/p" "$file" | bat --color=always --file-name "$file_info" -l proto
      fi
   done
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
