#!/bin/bash
## Main
##################################################
# Seed Dots ditectory to use
DOTFILES_FOLDER="$HOME/.seeddots"
# Name of dir where the user dotfiles is stored
USER_SEEDDOTFILES_NAME=".userseeddotfiles"
##
# User dotfiles directory
DIR_USER_SEEDDOTFIELS="$HOME/$USER_SEEDDOTFILES_NAME"
# Temporal directory to move the user dotfiles when migrate is actived
DIR_USER_SEEDDOTFIELS_TMP="${DIR_USER_SEEDDOTFIELS}_TMP"
####################################################
# Script dir
WORK_DIR=$(realpath $(dirname "$0"))
# The folders to inspect when migrate action is actived
USER_DIRS_TO_RESTORE=(
    seeds   # the user modules
    scripts # the user scripts
    docs    # docs
    shells  # shells configs
)
USER_FILES_TO_RESTORE=(
)
# Folder where is stored the template of  user dotfiles
TEMPLATE_SEEDDOFILES="${WORK_DIR}/../dotfiles_template"
##
####################################################
# import utility
source $WORK_DIR/../utils/alert.sh
source $WORK_DIR/../utils/test.sh
####################################################
a_dialog "Installing SeedDots " "·"
##################################################
## TEST
REQUIRED_COMMANDS=(
    "git"
)
verify_result=$(verify_commands "${REQUIRED_COMMANDS[@]}")
if [ "$verify_result" != "" ]; then
    a_error "Command required '$verify_result', not found"
    exit 1
fi

####################################################
# Make template inside of seedDotFiles
##--<
a_action "Installing Seed dotfiles" # init seed
flag_migrate_action=0
if [ -d $DIR_USER_SEEDDOTFIELS ]; then
    a_warning "The userdotfiles '$DIR_USER_SEEDDOTFIELS' already exist"
    ##--<
    a_action "Solving..." # Solving problem
    if a_confirm "Do you want MIGRATE and RESTORING your old dotfiles?" "y"; then
        # migrate_old_files
        flag_migrate_action=1
        mv $DIR_USER_SEEDDOTFIELS $DIR_USER_SEEDDOTFIELS_TMP
    else
        a_warning "Skiping Migrations!!"
        if a_confirm "Backup your files?" "y"; then
            bckp_name="${DIR_USER_SEEDDOTFIELS}.backup.$(date +"%s")"
            a_info "Backup old dotfiles inside"
            a_info_ni "'$bckp_name'"
            mv $DIR_USER_SEEDDOTFIELS $bckp_name
        else
            a_warning "Skiping Backups"
            a_warning "Removing old dotfiles"
            rm -rf $DIR_USER_SEEDDOTFIELS
        fi

    fi
    a_decrease # Solving problem
fi

##--<
a_action "Setup dotfiles template" # setup dotfiles template
## Coping files and make a template
a_info "Creating dotfiles dir"
mkdir $DIR_USER_SEEDDOTFIELS
##
cp -r $TEMPLATE_SEEDDOFILES/* $DIR_USER_SEEDDOTFIELS
## Init the repositories or restore the old repositories
git_dir="$DIR_USER_SEEDDOTFIELS_TMP/.git"
if [ "$flag_migrate_action" == "1" ] && [ -d $git_dir ]; then
    a_info "Restoring repo"
    cp -r $git_dir $DIR_USER_SEEDDOTFIELS
else
    cd $DIR_USER_SEEDDOTFIELS
    a_info "Init repository"
    git init >/dev/null
    git add . >/dev/null
    git commit -m "Init: Start the Seed Dotfiles template to manage the personal dotfiles" >/dev/null
fi
a_decrease # setup dotfiles template
##-->

a_decrease # init seed
##-->

if [ "$flag_migrate_action" -eq "1" ]; then
    ##--<
    a_action "Migrate" ## Migrate
    for dir_to_restore in "${USER_DIRS_TO_RESTORE[@]}"; do
        tmp_dir_to_restore="$DIR_USER_SEEDDOTFIELS_TMP/$dir_to_restore"
        if [ -d $tmp_dir_to_restore ]; then
            a_info "Restoring '$dir_to_restore'"
            dir_template="$DIR_USER_SEEDDOTFIELS/${dir_to_restore}"
            dir_template_tmp="$DIR_USER_SEEDDOTFIELS/${dir_to_restore}_tmp"

            mv $dir_template $dir_template_tmp
            cp -r $tmp_dir_to_restore $dir_template
            cp -rf $dir_template_tmp/{*,.*} $dir_template 2>/dev/null
            rm -rf $dir_template_tmp
        else
            a_info "Skipp '$dir_to_restore', dir no exist"
        fi
    done
    a_info "Removing tmp folder"
    rm -rf $DIR_USER_SEEDDOTFIELS_TMP
    a_decrease ## migrate
    ##-->
fi


a_action "Symbolic links the utils scripts"
ultils_folder="$DIR_USER_SEEDDOTFIELS/utils"
if [ ! -d "$ultils_folder" ]; then
    mkdir -p "$ultils_folder"
    a_info "Create the util folder '$ultils_folder'"
fi

work_dir_util_script="$WORK_DIR/../utils"
# work_dir_util_script="$WORK_DIR/../k"

if [ -d "$work_dir_util_script" ]; then
    if [ -n "$(find "$work_dir_util_script" -maxdepth 1 -type f)" ]; then
        for util_script in "$work_dir_util_script"/*; do
            if [ -f "$util_script" ]; then
                # filename=$(basename "$util_script")
                realfile=$(realpath $util_script)
                # a_info "Symbolic link '$realfile' to '$ultils_folder/$filename"
                ln -s "$realfile" "$ultils_folder/$filename"
                a_success "link $(basename "$util_script")"
            fi
        done
    else
        a_info "No util scripts to link"
    fi
else
    a_error "No util scripts folder found"
fi

a_decrease

##-->

a_action "Make executables" # executabless
executables=(
    "$DIR_USER_SEEDDOTFIELS/bin/sdm"
)
for script_te in ${executables[@]}; do
    if [ -f "$script_te" ]; then
        chmod +x "$script_te"
        a_success "Make executable: $(basename "$script_te")"
    else
        a_warning "File not found: $script_te"
    fi
done
a_decrease # executables

a_reset
a_action "Trigger 'sdm' install"
echo

bash "$DIR_USER_SEEDDOTFIELS/bin/sdm" install
a_decrease

a_dialog "Insallation finished" " "
