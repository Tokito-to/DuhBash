#!/usr/bin/bash -e

source ./utils.sh

# Read and Initialize toml Table
toml_prep "$(cat config.toml)"

export CONFIG_DIR="${HOME}/.config"
export LOCAL_DIR="${HOME}/.local/share"
export STORE_DIR="${PWD}/dotfiles"

command -v pacman >/dev/null 2>&1 || export DISABLE_PACKAGE="true"

IFS=" " read -ra DEFINED_TABLES <<< "$(toml_get_table_names)"
IFS=" " read -ra TABLES <<< "$*"

# check-toml_table_names
for TABLE in "${TABLES[@]}"; do
    if ! echo "${DEFINED_TABLES[*]}" | grep -Fo -q "${TABLE}"; then
        abort "${TABLE} is not defined"
    fi
done

options=("Backup" "Restore" "Exit")
select_option "${options[@]}"
EXIT_STATUS="$?"

case $EXIT_STATUS in
    0)
        # shellcheck disable=2034
        for TABLE in "${TABLES[@]}"; do
            IFS=" " read -r TABLE_CONFIG_DIRS <<< "$(toml_get "${TABLE}" config)"
            IFS=" " read -r TABLE_LOCAL_DIRS <<< "$(toml_get "${TABLE}" local)"

            backup "${TABLE}" "TABLE_CONFIG_DIRS"
            backup "${TABLE}" "TABLE_LOCAL_DIRS"
        done
        ;;
    1)
        echo "restore"
        ;;
    2)
        abort "User choose to exit"
        ;;
esac

