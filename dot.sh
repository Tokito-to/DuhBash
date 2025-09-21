#!/usr/bin/bash -e

source ./utils.sh

# Read and Initialize toml Table
toml_prep "$(cat config.toml)"

export CONFIG_DIR="${HOME}/.config"
export LOCAL_DIR="${HOME}/.local/share"
export STORE_DIR="${PWD}/dotfiles"

command -v pacman >/dev/null 2>&1 || export DISABLE_PACKAGE="true"

# Check CLI Arguments
if [[ $# -eq 0 ]]; then
    abort "No Table Specified"
fi

IFS=" " read -ra DEFINED_TABLES <<< "$(toml_get_table_names)"
IFS=" " read -ra TABLES <<< "$*"

# check-toml_table_names
for TABLE in "${TABLES[@]}"; do
    if ! echo "${DEFINED_TABLES[*]}" | grep -Fow -q "${TABLE}"; then
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

            backup "${TABLE}" "TABLE_CONFIG_DIRS" "CONFIG_DIR"
            backup "${TABLE}" "TABLE_LOCAL_DIRS" "LOCAL_DIR"
        done
        ;;
    1)
        options=("Restore (Dots)" "Restore (Packages)" "Exit")
        select_option "${options[@]}"
        EXIT_STATUS="$?"

        case $EXIT_STATUS in
            0)
                # shellcheck disable=2034
                for TABLE in "${TABLES[@]}"; do
                    IFS=" " read -r TABLE_CONFIG_DIRS <<< "$(toml_get "${TABLE}" config)"
                    IFS=" " read -r TABLE_LOCAL_DIRS <<< "$(toml_get "${TABLE}" local)"

                    restore "${TABLE}" "TABLE_CONFIG_DIRS" "CONFIG_DIR"
                    restore "${TABLE}" "TABLE_LOCAL_DIRS" "LOCAL_DIR"
                done
                ;;
            1)
                echo "Package Install..."
                ;;
            2)
                abort "User Choose To Exit"
                ;;
        esac
        ;;
        2)
        abort "User choose to exit"
        ;;
esac

