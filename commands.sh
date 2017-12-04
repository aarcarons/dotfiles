#!/bin/sh

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOT_FILES_PATH=$SCRIPT_PATH/dotfiles
BREW_PATH=$SCRIPT_PATH/brew
SETTINGS_PATH=$SCRIPT_PATH/settings

DOT_FILE_NAMES=()
for file in $DOT_FILES_PATH/.*
do
    filename=`basename $file`

    if [ $filename != "." ] && [ $filename != ".." ] && [ $filename != ".DS_Store" ]; then
        DOT_FILE_NAMES+=($filename)
    fi
done

link_dotfiles() {
    echo "Creating symlinks..."

    for filename in ${DOT_FILE_NAMES[@]}
    do
        ln -s -v $DOT_FILES_PATH/$filename $HOME/$filename
    done
}

unlink_dotfiles() {
    echo "Removing symlinks..."

    for filename in ${DOT_FILE_NAMES[@]}
    do
        dotfile=$HOME/$filename

        if [ -e $dotfile ] && [ -h $dotfile ]; then
            rm -v $dotfile
        fi
    done
}

install_dev_tools() {
    echo "Installing Xcode CLI tools..."
    xcode-select --install
}

update_dotfiles() {
    unlink_dotfiles
    link_dotfiles
}

brew_install() {
    echo "Install homebrew..."
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew_update
    brew_update_cask
}
 
zsh_install() {
    # Install oh-my-zsh
    # !!! oh-my-zsh makes zsh default shell automatically. !!!
    echo "Install zsh..."
    curl -L http://install.ohmyz.sh | sh
}

update_brew() {
    echo "Updating homebrew.."
    brew bundle -v --file=$BREW_PATH/Brewfile
}

apply_defaults() {
    echo "Applying defaults..."

    $SETTINGS_PATH/defaults
}

link_preferences() {
    preference_path=$HOME/Library/Preferences
    iterm_plist_name="com.googlecode.iterm2.plist"

    source=$SETTINGS_PATH/$iterm_plist_name
    symlink=$preference_path/$iterm_plist_name
    if [ -e $symlink ]; then
        rm -v $symlink
    fi
    ln -s -v $source $symlink
}

CMDNAME=`basename $0`
USAGE="Usage: $CMDNAME [install | brew | cask | link | settings]"
help() {
    echo $USAGE
    echo ""
    echo "Commands are:"
    echo "  install    Setup all configurations"
    echo "  brew       Install Homebrew packages"
    echo "  dotfile    Create symlinks for dotfiles"
    echo "  settings   Apply defaults settings"
}

if [ $# -eq 0 ]; then
    echo "$USAGE" 1>&2
    exit 1
fi

while [ $# -gt 0 ]
do
    case $1 in
        install)
            install_dev_tools
            update_dotfiles
            brew_update
            zsh_install
            apply_settings
            ;;
        brew)
            update_brew
            ;;
        dotfile)
            update_dotfiles
            ;;
        settings)
            apply_defaults
            link_preferences
            ;;
        -h)
            help
            exit 0
            ;;
        *)
            echo "$USAGE" 1>&2
            exit 1
    esac
    shift
done
