# fish completion for removemacai. Put it in ~/.config/fish/completions.

# --keep takes comma-separated names, so each one keeps the names typed before it.
function __removemacai_features
    set -l before (string replace -ra -- '^--keep=|[^,]*$' '' (commandline -ct))
    printf '%s\n' $before(removemacai features 2>/dev/null | string replace -r -- '\s+' \t)
end

function __removemacai_tweaks
    removemacai tweaks --json 2>/dev/null | string replace -rf '.*"id" : "(.*)".*' '$1'
end

# Only these can go in an exported profile; the rest are per-user settings.
function __removemacai_profile_tweaks
    removemacai tweaks --json 2>/dev/null |
        awk '/"id" :/ { gsub(/[",]/, "", $3); id = $3 } /"profile" : true/ { print id }'
end

# Checks the subcommand itself, so `background off` doesn't count as `off`.
function __removemacai_using
    set -l words (commandline -opc)
    contains -- "$words[2]" $argv
end

set -l commands status off on features tweaks apply undo background clean export revert app
set -l top "not __fish_seen_subcommand_from $commands"

complete -c removemacai -f
complete -c removemacai -n $top -a status -d 'Show what is on and how much space the models take'
complete -c removemacai -n $top -a off -d 'Turn Apple Intelligence off'
complete -c removemacai -n $top -a on -d 'Turn Apple Intelligence back on, keep the other tweaks'
complete -c removemacai -n $top -a features -d 'List the feature names'
complete -c removemacai -n $top -a tweaks -d 'List every tweak and whether it is applied'
complete -c removemacai -n $top -a apply -d 'Apply tweaks'
complete -c removemacai -n $top -a undo -d 'Undo tweaks'
complete -c removemacai -n $top -a background -d "Other apps' background items"
complete -c removemacai -n $top -a clean -d 'Show space to get back, move some to the Trash'
complete -c removemacai -n $top -a export -d 'Write the profile for an MDM'
complete -c removemacai -n $top -a revert -d 'Undo everything RemoveMacAI changed'
complete -c removemacai -n $top -a app -d 'Open the RemoveMacAI app'

complete -c removemacai -n '__removemacai_using off export' -l keep -x \
    -a '(__removemacai_features)' -d 'Leave these features on'
complete -c removemacai -n '__removemacai_using apply export' -l preset -x \
    -a 'recommended privacy' -d 'Apply a preset, Apple Intelligence off included'
complete -c removemacai -n '__removemacai_using off apply undo clean' -l dry-run \
    -d 'Show what would change, change nothing'
complete -c removemacai -n '__removemacai_using off apply undo background clean' -l yes -d 'Do not ask'
complete -c removemacai -n '__removemacai_using tweaks' -l json -d 'Print JSON for scripts'
complete -c removemacai -n '__removemacai_using export' -l no-ai -d 'Leave Apple Intelligence out'
complete -c removemacai -n '__removemacai_using apply undo' -a '(__removemacai_tweaks)'
complete -c removemacai -n '__removemacai_using export' -a '(__removemacai_profile_tweaks)'
complete -c removemacai -n '__removemacai_using export' -F
complete -c removemacai -n '__removemacai_using clean' \
    -a 'aerials installers ios-firmware derived-data device-support simulators caches snapshots'
complete -c removemacai -n '__removemacai_using background; and test (count (commandline -opc)) -eq 2' -a 'off on'
