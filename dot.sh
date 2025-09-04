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

check-table_names TABLES[@] DEFINED_TABLES[@]

options=("Backup" "Restore" "Exit")
select_option "${options[@]}"
EXIT_STATUS="$?"

case $EXIT_STATUS in
    0)
        for TABLE in "${TABLES[@]}"; do
            # defaults
            NO_CONFIGS=false
            NO_LOCALS=false

            IFS=" " read -r TABLE_CONFIG_DIRS <<< "$(toml_get "${TABLE}" config)"
            IFS=" " read -r TABLE_LOCAL_DIRS <<< "$(toml_get "${TABLE}" local)"

            if [[ -z "${TABLE_CONFIG_DIRS}" || "${TABLE_CONFIG_DIRS}" == '""' ]]; then
                export NO_CONFIGS="true"
            fi

            if [[ -z "${TABLE_LOCAL_DIRS}" || "${TABLE_LOCAL_DIRS}" == '""' ]]; then
                export NO_LOCALS="true"
            fi

            if [[ "${NO_CONFIGS}" == "false" ]]; then
                for TABLE_CONFIG_DIR in "${TABLE_CONFIG_DIRS[@]}"; do
                    if [[ "${TABLE}" ==  "${TABLE_CONFIG_DIR}" ]]; then
                        copy "${CONFIG_DIR}/${TABLE_CONFIG_DIR}" "${STORE_DIR}" "${TABLE}"
                    else
                        copy "${CONFIG_DIR}/${TABLE_CONFIG_DIR}" "${STORE_DIR}/${TABLE}" "${TABLE}"
                    fi
                done
            fi

            if [[ "${NO_LOCALS}" == "false" ]]; then
                for TABLE_LOCAL_DIR in "${TABLE_LOCAL_DIRS[@]}"; do
                    if [[ "${TABLE}" ==  "${TABLE_LOCAL_DIR}" ]]; then
                        copy "${LOCAL_DIR}/${TABLE_LOCAL_DIR}" "${STORE_DIR}" "${TABLE}"
                    else
                        copy "${LOCAL_DIR}/${TABLE_LOCAL_DIR}" "${STORE_DIR}/${TABLE}" "${TABLE}"
                    fi
                done
            fi
        done
        ;;
    1)
        echo "restore"
        ;;
    2)
        err "User choose to exit"
        ;;
esac

