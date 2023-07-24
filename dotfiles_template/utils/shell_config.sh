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
        echo ""  # Línea vacía o comentario, devolver cadena vacía
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
    key=$(echo "$key" | awk '{$1=$1};1')  # Eliminar espacios en blanco al inicio y al final
    echo "$key"
}
get_value() {
    local result="$1"
    value="${result#*=}"
    value=$(echo "$value" | awk '{$1=$1};1')  # Eliminar espacios en blanco al inicio y al final
    echo "$value"
}

# Profiel function
generate_profile(){
    echo "# SeedDots" > "$FILE_PROFILE"
    while IFS= read -r line; do
        
        if [[ "$line" == "[path]" ]]; then
            echo -e "\n# Setup Path" >> "$FILE_PROFILE"
            while IFS= read -r path_line && [[ "$path_line" != "["* ]]; do
                toml_line=`parse_toml_line "$path_line"`
                if [ "$toml_line" != "" ]; then
                    # path_value="${toml_line#*=}"
                    path_value="`get_value "$toml_line"`"
                    echo "export PATH=\"$path_value:\$PATH\"" >> "$FILE_PROFILE"
                fi
            done
            line=$path_line
        fi
        if [[ "$line" == "[vars]" ]]; then
            echo -e "\n# Setup Vars" >> "$FILE_PROFILE"
            while IFS= read -r vars_line && [[ "$vars_line" != "["* ]]; do
                toml_line=`parse_toml_line "$vars_line"`
                if [ "$toml_line" != "" ]; then
                    # var_name="${toml_line%=*}"
                    # var_value="${toml_line#*=}"
                    var_name="`get_key "$toml_line"`"
                    var_value="`get_value "$toml_line"`"
                    echo "export $var_name=\"$var_value\"" >> "$FILE_PROFILE"
                fi
            done
            line=$vars_line
        fi
        if [[ "$line" == "[alias]" ]]; then
            echo -e "\n# Setup Alias" >> "$FILE_PROFILE"
            while IFS= read -r alias_line && [[ "$alias_line" != "["* ]]; do
                toml_line=`parse_toml_line "$alias_line"`
                if [ "$toml_line" != "" ]; then
                    # alias_name="${toml_line%=*}"
                    # alias_value="${toml_line#*=}"
                    alias_name="`get_key "$toml_line"`"
                    alias_value="`get_value "$toml_line"`"
                    echo "alias $alias_name=\"$alias_value\"" >> "$FILE_PROFILE"
                fi
            done
            line=$path_line
        fi
    done < "$FILE_TOML"
}

generate_fish_config(){
    echo "# SeedDots" > "$FILE_FISH_CONFIG_FILE"
    while IFS= read -r line; do
        if [[ "$line" == "[path]" ]]; then
            echo -e "\n# Setup Path" >> "$FILE_FISH_CONFIG_FILE"
            while IFS= read -r path_line && [[ "$path_line" != "["* ]]; do
                toml_line=`parse_toml_line "$path_line"`
                if [ "$toml_line" != "" ]; then
                    path_value="`get_value "$toml_line"`"
                    echo "fish_add_path -gm $path_name \"$path_value\"" >> "$FILE_FISH_CONFIG_FILE"
                fi
            done
            line=$path_line
        fi
        if [[ "$line" == "[vars]" ]]; then
            echo -e "\n# Setup Vars" >> "$FILE_FISH_CONFIG_FILE"
            while IFS= read -r vars_line && [[ "$vars_line" != "["* ]]; do
                toml_line=`parse_toml_line "$vars_line"`
                if [ "$toml_line" != "" ]; then
                    var_name="`get_key "$toml_line"`"
                    var_value="`get_value "$toml_line"`"
                    echo "set -x $var_name \"$var_value\"" >> "$FILE_FISH_CONFIG_FILE"
                fi
            done
            line=$vars_line
        fi
        if [[ "$line" == "[alias]" ]]; then
            echo -e "\n# Setup Alias" >> "$FILE_FISH_CONFIG_FILE"
            while IFS= read -r alias_line && [[ "$alias_line" != "["* ]]; do
                toml_line=`parse_toml_line "$alias_line"`
                if [ "$toml_line" != "" ]; then
                    alias_name="`get_key "$toml_line"`"
                    alias_value="`get_value "$toml_line"`"
                    echo "alias $alias_name \"$alias_value\"" >> "$FILE_FISH_CONFIG_FILE"
                fi
            done
            line=$path_line
        fi
    done < "$FILE_TOML"
}


# Verificar que el archivo TOML existe
if [ ! -f $FILE_TOML ]; then
    echo "TOML file '$FILE_TOML' don't exist."
    exit 1
fi

# # Generar los archivos .profile y config.fish
generate_profile
generate_fish_config

echo "$FILE_PROFILE:$FILE_FISH_CONFIG_FILE"
