# bash completion for removemacai. Source it from ~/.bash_profile.

_removemacai_features() {
  removemacai features 2>/dev/null | awk '{ print $1 }'
}

_removemacai_tweaks() {
  removemacai tweaks --json 2>/dev/null | sed -n 's/.*"id" : "\(.*\)".*/\1/p'
}

# Only these can go in an exported profile; the rest are per-user settings.
_removemacai_profile_tweaks() {
  removemacai tweaks --json 2>/dev/null |
    awk '/"id" :/ { gsub(/[",]/, "", $3); id = $3 } /"profile" : true/ { print id }'
}

_removemacai() {
  local cur=${COMP_WORDS[COMP_CWORD]} prev=${COMP_WORDS[COMP_CWORD-1]}
  COMPREPLY=()
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "status off on features tweaks apply undo background clean export revert app" -- "$cur"))
    return
  fi
  case $prev in
    --preset)
      COMPREPLY=($(compgen -W "recommended privacy" -- "$cur"))
      return ;;
    --keep)
      # The names are comma-separated, so complete the one after the last comma and leave room for the next.
      local last=${cur##*,}
      COMPREPLY=($(compgen -P "${cur%"$last"}" -W "$(_removemacai_features)" -- "$last"))
      type compopt &>/dev/null && compopt -o nospace
      return ;;
  esac
  local options= names= file
  case ${COMP_WORDS[1]} in
    off) options="--keep --dry-run --yes" ;;
    tweaks) options="--json" ;;
    apply) options="--preset --dry-run --yes" names=$(_removemacai_tweaks) ;;
    undo) options="--dry-run --yes" names=$(_removemacai_tweaks) ;;
    background) options="--yes"; [ "$COMP_CWORD" -eq 2 ] && names="off on" ;;
    clean)
      options="--dry-run --yes"
      names="aerials installers ios-firmware derived-data device-support simulators caches snapshots" ;;
    export)
      options="--preset --keep --no-ai" names=$(_removemacai_profile_tweaks)
      if [[ $cur != -* ]]; then
        while IFS= read -r file; do COMPREPLY+=("$file"); done < <(compgen -f -- "$cur")
      fi ;;
  esac
  if [[ $cur == -* ]]; then
    COMPREPLY=($(compgen -W "$options" -- "$cur"))
  else
    COMPREPLY+=($(compgen -W "$names" -- "$cur"))
  fi
}

complete -o filenames -F _removemacai removemacai
