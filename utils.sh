#!/usr/bin/bash -e

prompt() { echo -ne " \e[92m*\e[39m $*"; }

err() { echo -e " \e[91m*\e[39m $*" && exit 1; }

pr () { echo -e "\e[92m$*\e[39m"; }

# Toml Parser
toml_prep() { __TOML__=$(tr -d '\t\r' <<<"$1" | tr "'" '"' | grep -o '^[^#]*' | grep -v '^$' | sed -r 's/(\".*\")|\s*/\1/g; 1i []'); }

toml_get_table_names() {
    local tn
    tn=$(grep -x '\[.*\]' <<<"$__TOML__" | tr -d '[]') || return 1
    if [ "$(sort <<<"$tn" | uniq -u | wc -l)" != "$(wc -l <<<"$tn")" ]; then
        abort "ERROR: Duplicate tables in TOML"
    fi
    echo "${tn}" | tr '\n' ' '
}

toml_get_table() { sed -n "/\[${1}]/,/^\[.*]$/p" <<<"$__TOML__" | sed '${/^\[/d;}'; }

toml_get() {
    local table_name=$1 key=$2 val
    table="$(toml_get_table "${table_name}")"
    val=$(grep -m 1 "^${key}=" <<<"$table") && sed -e "s/^\"//; s/\"$//" <<<"${val#*=}"
}

# kanged from: linutils
# https://github.com/ChrisTitusTech/linutil/blob/main/core/tabs/system-setup/arch/server-setup.sh#L66C1-L118C2
select_option() {
    set +e
    local options=("$@")
    local num_options=${#options[@]}
    local selected=0
    local last_selected=-1

    while true; do
        # Move cursor up to the start of the menu
        if [ $last_selected -ne -1 ]; then
            echo -ne "\033[${num_options}A"
        fi

        if [ $last_selected -eq -1 ]; then
            echo "Please select an option using the arrow keys and Enter:"
        fi
        for i in "${!options[@]}"; do
            if [ "$i" -eq $selected ]; then
                pr "> ${options[$i]}"
            else
                echo "  ${options[$i]}"
            fi
        done

        last_selected=$selected

        # Read user input
        read -rsn1 key
        case $key in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 key
                case $key in
                    '[A') # Up arrow
                        ((selected--))
                        if [ $selected -lt 0 ]; then
                            selected=$((num_options - 1))
                        fi
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        if [ "$selected" -ge "$num_options" ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '') # Enter key
                break
                ;;
        esac
    done

    return $selected
}

# Tool utils
check-table_names() {
    local -a TABLES="${!1}"
    local -a DEFINED_TABLES="${!2}"

    for TABLE in "${TABLES[@]}"; do
        if ! echo "${DEFINED_TABLES[*]}" | grep -Fxo -q "${TABLE}"; then
            err "${TABLE} is not defined"
        fi
    done
}

copy() {
    local SOURCE="$1"
    local DESTINATION="${2}"

    SOURCE="${SOURCE//\"}"
    DESTINATION="${DESTINATION//\"}"

    [[ "${ESCALATION_TOOL}" == "eval" ]] && err "Copying dots to root. Aborting!"

    mkdir -p "${DESTINATION}"
    cp -f -rv "${SOURCE}" "${DESTINATION}"

    echo "Sync complete!"
}

