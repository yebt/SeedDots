#!/bin/bash
##################################################
# ANSI Colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
GRAY='\033[0;37m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# Reset
RESET='\033[0m' # Restaurar el color original

# ANSI Styles
BOLD='\033[1m'
ITALIC='\033[3m'
##################################################
## Herarchy 
GLOBAL_HIERARCHY=0
HIERARCHY_ICON="  "
LAST_PREFIX="" # last calculated indent 
LAST_HIERARCHY=0
##################################################
trim() {
    local var="$1"
    local trimmed=$(echo "$var" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    echo "$trimmed"
}
##################################################
# General printer
print_message(){
    # vars
    local message=$1
    local herarchy_motion=$2
    local local_herarchy=$3
    # Generate indentation
    ((GLOBAL_HIERARCHY += herarchy_motion))
    local indent=""
    if [ "$GLOBAL_HIERARCHY" -ne "$LAST_HIERARCHY" ]; then
        for ((i = 0; i < GLOBAL_HIERARCHY; i++)); do
            indent+=$HIERARCHY_ICON
        done
        LAST_PREFIX=$indent
        LAST_HIERARCHY=$GLOBAL_HIERARCHY
    else
        indent=$LAST_PREFIX
    fi
    # local indentation
    local localindent=""
    for ((i = 0; i < local_herarchy; i++)); do
        localindent+=$HIERARCHY_ICON
    done
    # Pint
    echo -ne "$indent$localindent$1"
}
##################################################
# Specific alerts
a_dialog(){
    local message=$1
    local wrap_icon=${2:-"#"}
    local len_msg=${#message}
    (( len_msg+=2 ))
    local len_wi=${#wrap_icon}
    local wrap_repetition=0
    (( wrap_repetition=(len_msg+len_wi-1)/len_wi ))
    
    local trwap=""
    for ((i = 0; i < wrap_repetition+2; i++)); do
        trwap+=$wrap_icon
    done
    ((reserved_msg_len=( ${#trwap} - (${#wrap_icon}*2 +2) )))
    message=`printf "%-${reserved_msg_len}s" "$message"`
    message=" $trwap
 $wrap_icon $message $wrap_icon
 $trwap
 "
    a_title "$message" $PURPLE
}
a_title(){
    local msg_color=${2:-$GREEN}
    local local_indent=0
    local left="${msg_color}${BOLD}"
    local icon=""
    local right="${RESET}"
    local message="${left}${icon}${1^^}${right}"
    print_message  "$message\n" 0 "$local_indent"
}
a_error (){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${RED}"
    local icon="[x]"
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
a_error_ni(){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${RED}"
    local icon="  "
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
###
a_warning (){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${YELLOW}"
    local icon="[!]"
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
a_warning_ni (){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${YELLOW}"
    local icon="   "
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
a_info (){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${BLUE}"
    local icon="[i]"
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
a_info_ni (){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${BLUE}"
    local icon="   "
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
##
a_question() {
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${CYAN}"
    local icon="[?]"
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message" "$indent_motion" "$local_indent"
}
##
a_success(){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${GREEN}"
    local icon="[✓]"
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
a_success_ni(){
    local indent_motion=${2:-0}
    local local_indent=1
    local left="${GREEN}"
    local icon="   "
    local right="${RESET}"
    local message="${left}${icon} ${ITALIC}$1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
a_action (){
    local indent_motion=${2:-"1"}
    local local_indent=0
    local left="${BOLD}"
    local icon=">>"
    local right="${RESET}"
    local message="${left}${icon} $1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
a_print(){
    local indent_motion=${2:-0}
    local local_indent=1
    local left=""
    local icon=""
    local right="${RESET}"
    local message="${left}${icon} $1 ${right}"
    print_message  "$message\n" "$indent_motion" "$local_indent"
}
##
a_increase(){
 (( GLOBAL_HIERARCHY +=1 ))
}
a_decrease(){
    if [ $GLOBAL_HIERARCHY -gt 0 ]; then
        (( GLOBAL_HIERARCHY -=1 ))
    fi
}
a_reset(){
    GLOBAL_HIERARCHY=0
}
##
##################################################
a_confirm (){
    local message="$1"
    local default_sel="$2"
    local response=""
    if [ "$default_sel" != ""  ] ;then
        message+=" [$default_sel]"
    fi
    while [ "$response" == ""  ];
    do
        a_question "$message"
        read -p "(y/n): " -n 1 response
        response=`trim $response`
        if [ "$response" == "" ]; then
            response=$default_sel
        fi
        case "$response" in
            [Yy]*)
                return 0
                ;;
            [Nn]*)
                return 1
                ;;
            *)
                a_error "Invalid option. Please select Y or N"
                response=""
                ;;
        esac
    done
}
##################################################
#a_title "title" "$BLUE"
#a_decrease
#a_error "error 1" 1
#a_warning "war"
#a_info "inf " 
#a_decrease
#a_success "OK"
#a_reset
#a_info "uwu"
#a_action "filterall"
#a_confirm "why?"
#a_action "uwu"

