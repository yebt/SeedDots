###########################
# Test the a commnds array if exist, return "" if all is ok
verify_commands (){
    local command_array=("$@")
    for tmp_cmd in "${command_array[@]}";do
        if ! command -v "$tmp_cmd" &> /dev/null; then
            echo "$tmp_cmd"
        fi
    done
}