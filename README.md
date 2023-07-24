# SeedDots

<!--LOGO-->
![Logo](./assets/logo.png)

This is a simple framework to manage the [dotfiles](https://dotfiles.github.io/).

## Concepts

### Seed

It is the module that contains the information about a group of dotfails that work together where it is stored

- version
- dotfiles (could be folders or simple files)
- toml configuration file, which contains information on how the module should be treated

## Installation

```sh
git clone https://github.com/yebt/SeedDots
cd SeedDots
bash ./bin/install.sh
```

## Usage

This framework work with the folder `~/.userseeddotfiles`, this folder contains the following file structure:

```sh
bin/            # Executables and bin with clis to manage the dotfiles
docs/           # Documents of modules etc
scripts/        # Scripts of the user 
seeds/          # All user modules
setup_scripts/  # Scripts to run when setup, this are agroup by OS
shells/         # Configs to generated setups
utils/          # Scripts to use inside the enviroment
```

when you install the framework you can use the command `sdm` (Seed Dotfiels Manager).