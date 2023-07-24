#!/bin/bash
#
WORK_DIR=$(dirname "$0")
FILE_TOML="$WORK_DIR/../shells/config.toml"
FILE_PROFILE="$WORK_DIR/../shells/.seeddot_profile"
# local FILE_PROFILE="$HOME/.profile"
FILE_FISH_CONFIG_FILE="$WORK_DIR/../shells/.seeddot_fish_config"
# local FILE_FISH_CONFIG_FILE="$HOME/.config/fish/config.fish"

###

parse_toml_line() {
    local line="$1"

    # Eliminar espacios en blanco al inicio y al final de la línea
    line=$(echo "$line" | awk '{$1=$1};1')

    # Verificar si la línea es un comentario (inicia con "#") o está vacía
    if [[ "$line" == "" || "$line" == \#* ]]; then
        echo "" # Línea vacía o comentario, devolver cadena vacía
    else
        # Extraer el nombre (clave) y el valor de la línea
        name=$(echo "$line" | awk -F= '{print $1}' | awk '{$1=$1};1')
        value=$(echo "$line" | awk -F= '{print substr($0, index($0,$2))}' | awk '{$1=$1};1')

        # Eliminar comillas alrededor del valor si es un string
        if [[ "$value" =~ ^\".*\"$ || "$value" =~ ^\'.*\'$ ]]; then
            value=$(echo "$value" | sed 's/^"\|"$//g' | sed "s/^'\|'$/\n/g" | tr -d '\n')
        fi

        # Devolver el resultado como name=value
        echo "$name=$value"
    fi
}
get_key() {
    local result="$1"
    key="${result%%=*}"
    key=$(echo "$key" | awk '{$1=$1};1') # Eliminar espacios en blanco al inicio y al final
    echo "$key"
}
get_value() {
    local result="$1"
    value="${result#*=}"
    value=$(echo "$value" | awk '{$1=$1};1') # Eliminar espacios en blanco al inicio y al final
    echo "$value"
}

################################################################

# Profile
generate_profile() {
    FILE_TO_SOURCE="$1"

    echo "# SeedDots" >"$FILE_TO_SOURCE"
    while IFS= read -r line; do

        if [[ "$line" == "[path]" ]]; then
            echo -e "\n# Setup Path" >>"$FILE_TO_SOURCE"
            while IFS= read -r path_line && [[ "$path_line" != "["* ]]; do
                toml_line=$(parse_toml_line "$path_line")
                if [ "$toml_line" != "" ]; then
                    # path_value="${toml_line#*=}"
                    path_value="$(get_value "$toml_line")"
                    echo "export PATH=\"$path_value:\$PATH\"" >>"$FILE_TO_SOURCE"
                fi
            done
            line=$path_line
        fi
        if [[ "$line" == "[vars]" ]]; then
            echo -e "\n# Setup Vars" >>"$FILE_TO_SOURCE"
            while IFS= read -r vars_line && [[ "$vars_line" != "["* ]]; do
                toml_line=$(parse_toml_line "$vars_line")
                if [ "$toml_line" != "" ]; then
                    # var_name="${toml_line%=*}"
                    # var_value="${toml_line#*=}"
                    var_name="$(get_key "$toml_line")"
                    var_value="$(get_value "$toml_line")"
                    echo "export $var_name=\"$var_value\"" >>"$FILE_TO_SOURCE"
                fi
            done
            line=$vars_line
        fi
        if [[ "$line" == "[alias]" ]]; then
            echo -e "\n# Setup Alias" >>"$FILE_TO_SOURCE"
            while IFS= read -r alias_line && [[ "$alias_line" != "["* ]]; do
                toml_line=$(parse_toml_line "$alias_line")
                if [ "$toml_line" != "" ]; then
                    # alias_name="${toml_line%=*}"
                    # alias_value="${toml_line#*=}"
                    alias_name="$(get_key "$toml_line")"
                    alias_value="$(get_value "$toml_line")"
                    echo "alias $alias_name=\"$alias_value\"" >>"$FILE_TO_SOURCE"
                fi
            done
            line=$path_line
        fi
    done <"$FILE_TOML"
}

# Fish config
generate_fish_config() {
    FILE_TO_SOURCE="$1"

    echo "# SeedDots" >"$FILE_TO_SOURCE"
    while IFS= read -r line; do
        if [[ "$line" == "[path]" ]]; then
            echo -e "\n# Setup Path" >>"$FILE_TO_SOURCE"
            while IFS= read -r path_line && [[ "$path_line" != "["* ]]; do
                toml_line=$(parse_toml_line "$path_line")
                if [ "$toml_line" != "" ]; then
                    path_value="$(get_value "$toml_line")"
                    echo "fish_add_path -gm $path_name \"$path_value\"" >>"$FILE_TO_SOURCE"
                fi
            done
            line=$path_line
        fi
        if [[ "$line" == "[vars]" ]]; then
            echo -e "\n# Setup Vars" >>"$FILE_TO_SOURCE"
            while IFS= read -r vars_line && [[ "$vars_line" != "["* ]]; do
                toml_line=$(parse_toml_line "$vars_line")
                if [ "$toml_line" != "" ]; then
                    var_name="$(get_key "$toml_line")"
                    var_value="$(get_value "$toml_line")"
                    echo "set -x $var_name \"$var_value\"" >>"$FILE_TO_SOURCE"
                fi
            done
            line=$vars_line
        fi
        if [[ "$line" == "[alias]" ]]; then
            echo -e "\n# Setup Alias" >>"$FILE_TO_SOURCE"
            while IFS= read -r alias_line && [[ "$alias_line" != "["* ]]; do
                toml_line=$(parse_toml_line "$alias_line")
                if [ "$toml_line" != "" ]; then
                    alias_name="$(get_key "$toml_line")"
                    alias_value="$(get_value "$toml_line")"
                    echo "alias $alias_name \"$alias_value\"" >>"$FILE_TO_SOURCE"
                fi
            done
            line=$path_line
        fi
    done <"$FILE_TOML"
}

################################################################

## Supported shells
# Shell:config_file:generated_config_file
supported_shells=(
    "bash:~/.bashrc:profile:generate_profile"
    "zsh:~/.zshrc:profile:generate_profile"
    "fish:~/.config/fish/config.fish:config_fish:generate_fish_config"
)
# sourc files
generate_shells_files() {
    for shell_sup in ${shell_sup[@]}; do
        IFS=":" read -r shell_name config_file result_name function_name <<<$shell_sup
        a_action "$shell_name ..."
        if command -v "$shell_name" &>/dev/null; then

            file_to_source="$(realpath "$WORK_DIR/../shells/.seeddot_$result_name")"

            # Generate the source file content
            a_action "Generating content"
            "$function_name" "$file_to_source"
            a_success "Content generated successfully"
            a_decrease

            CONTENT="source $file_to_source"
            # check config file
            if [ ! -f "$config_file" ]; then
                a_warning "File '$config_file' not exit"
                touch $config_file
                a_info "Created"
            fi
            # check content
            if ! grep -qF "$CONTENT" "$config_file" 2>/dev/null; then
                echo $CONTENT >>"$config_file"
                a_success "Source content updated"
            else
                a_success "Source content skipped"
            fi

        else
            a_info "$shell_name skipped"
        fi
        a_decrease
    done
}

# Verificar que el archivo TOML existe
if [ ! -f $FILE_TOML ]; then
    a_warning "TOML file not found"
    a_action "Geneting basic TOML"
    touch $FILE_TOML
    echo '# Toml general config

# Paths to add
[path]
SEEDDOTS_BIN = "~/.userseeddotfiles/bin"

# Vars to add
[vars]
EDITOR = "vi"

# Aliases to add
[alias]
ls = "ls --color=auto"
ll = "ls -alF"
' >$FILE_TOML
    a_info "Created"
else
    a_success "TOML file found"
fi

# # Generar los archivos .profile y config.fish
# generate_profile
# generate_fish_config
generate_shells_files

# echo "$FILE_PROFILE:$FILE_FISH_CONFIG_FILE"
