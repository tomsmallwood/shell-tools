# Source me in ~/.bash_profile 
# e.g. source "$HOME/dev/shell-tools/.env-tools-setup-macos.sh"

# Install macOS brew and bash_completion@2
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" && 
brew install git bash-completion@2

# Export custom dev directory
export devdir="$HOME/dev"

source "$devdir/shell-tools/shell-tools.sh"

addtopath "$HOME/apps"