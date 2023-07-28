################################################################

# TODO: seeder This file can:
# -> Create empty seed    (Create a blank seed module )
# -> Create seed from a dofile (Create a seed and put existing config file or folder, from a dorfile)
# -> List seed status (Show all seeds and the status )
# -> Export seeds (Install the seesd with the config, making the backups if is needed )
# -> Export specific seed
# -> Git : add changes of a seed witha  commit
# -> Git : push chenges

################################################################

SEEDER_WORK_DIR=$(realpath $(dirname $0))
USER_SEED_DIR=$(realpath $SEEDER_WORK_DIR/../seeds)

################################################################

# source "$SEEDER_WORK_DIR/alert.sh"
f_exist() {
    local function_name="$1"
    type -t "$function_name" >/dev/null
}
if ! f_exist "a_info"; then
    source "$SEEDER_WORK_DIR/alert.sh"
fi

################################################################

# Fucntion to get the value of a toml
# Usage: get_toml_value <file.toml> <key>
function get_toml_value() {
    local toml_file="$1"
    local key="$2"
    local value=""
    if [ ! -f "$toml_file" ]; then
        echo "}
        778File '$toml_file' not found"
        return 1
    fi
    value=$(grep -E "^$key\s*=" "$toml_file" | awk -F '=' '{ gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2 }')
    echo "$value"
}

################################################################

SEEDER_COMMAND_LIST=(
    "-h,--help:show_help_message:Show this help message"
    "create:create_seed:Create a seed, if a path is send the seed is trying to create with this path"
    "export:export_seed:Export the actual seed, if the dotfile exist is moved to backup. If the symlink exist is skipped"
    "save:git_add_c:Add the changes of a specific seed and commit with a message",
    "push:git_push:Push the cahnges",
    "list:status_seed:Show the seed status (used and git)"
)

################################################################

# Fucntion to show a message
# Función para mostrar el mensaje de ayuda
function show_help_message() {
    a_action "Usage: $(basename $0) [Acton]"
    a_action "Acton:"
    for command in "${SEEDER_COMMAND_LIST[@]}"; do
        # Extracción del comando y descripción de cada elemento
        option=$(echo "$command" | cut -d':' -f1)
        description=$(echo "$command" | cut -d':' -f3)
        a_info "$(printf "  %-20s %s\n" "$option" "$description")"
    done
    a_decrease
    a_decrease
}


################################################################
if [[ -z "$1"  || "$1" == "-h" || "$1" == "--help" ]]; then
    show_help_message
    exit 0
fi

################################################################
# Load  optios

seed_runner (){
    local action="$1"
    local args="$2"
    local action_found=false
    for commnd in "${SEEDER_COMMAND_LIST[@]}"; do
        local option=$(echo "$commnd" | cut -d':' -f1)
        local function=$(echo "$commnd" | cut -d':' -f2)
        if [[ "$option" == "$action" ]]; then
            action_found=true
            $function "$args"
            break
        fi
    done
    if ! $action_found; then
        a_error "Action '$action' not found"
    fi
}

seed_runner "$@"