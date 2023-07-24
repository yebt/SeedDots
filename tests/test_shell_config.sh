source "./dotfiles_template/utils/shell_config.sh"
cat ./dotfiles_template/shells/config.toml
echo "------------------------------------------------------------------"
new_path "~/.local/bin" "./dotfiles_template/shells/config.toml"
echo "------------------------------------------------------------------"
cat ./dotfiles_template/shells/config.toml