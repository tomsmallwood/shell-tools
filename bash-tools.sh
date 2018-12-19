# go ahead and put some snazzy aliases here
alias foo='echo "snazziness epitomised"'
alias cdev='cd ${devdir}'
alias emptyf='cat /dev/null > '
alias shredq='shred -uz'
alias quick_upgrade='sudo apt update && sudo apt -y full-upgrade && sudo apt autoremove -y && sudo snap refresh'
alias apty='sudo apt install -y'

alias prettyjson='python -m json.tool'
alias cls='printf "\033c"'
alias gitlog='git log --pretty=oneline --abbrev-commit'

# ls aliases
alias la='ls -lAh'
alias sl='ls'
alias ll='ls -lh'
alias l='ls -lah'

bashtoolsfname="bash-tools.sh"
envtooldir="${devdir}/bash-tools/"
bashtoolspath="${envtooldir}${bashtoolsfname}"

LS_COLORS="$LS_COLORS:ow=01;34"
export LS_COLORS

export PIPENV_VENV_IN_PROJECT="true"

update_env_tools() {
  if git -C $envtooldir pull --rebase --stat origin master
  then
    echo "Updated env tools"
  else
    echo "Update failed"
  fi
  source $bashtoolspath
}

bashtoolssetup() {
  if echo $SHELL | grep -q 'zsh'; then
    RCFILE="$HOME/.zshrc"
  elif echo $SHELL | grep -q 'bash'; then
    RCFILE="$HOME/.bashrc"
  fi

  if [ ! -f ~/.env-tools-setup.sh ]; then
    cp ./.env-tools-setup.sh ~/
    echo "copied new .env-tools-setup"
  fi

  source_string="source $HOME/.env-tools-setup.sh"

  if [ -z $(grep "$source_string" "$RCFILE") ]; then
    echo "$source_string" >> "$RCFILE";
    echo "added source string to $RCFILE"
  fi
}

bashtoolssetup

# bash functions below
bashedit() {
  if [ $# -eq 0 ]
    then
      vim $bashtoolspath && source $bashtoolspath
  else
    vim $1 && source $1
  fi
}

mkcd() {
  mkdir $1 && cd $1
}

addtopath() {
  if [[ ":$PATH:" == *":$1:"* ]]; then
    :
  else
    export PATH=$PATH:$1
  fi
}

catjson() {
  cat "$1" | python3 -m json.tool
}

prettifyjson() {
  cleanjson=$(cat $1 | python3 -m json.tool)
  echo "${cleanjson}" > $1
}

gitc() {
  CHANGED=$(git status --porcelain)
  if [ -n "${CHANGED}" ]; then
    echo 'repo has changes - aborting.';
  else
    basebranch=${1:-master}
    git checkout $basebranch
  fi
}

shouldirebase() {
  CHANGED=$(git status --porcelain)
  if [ -n "${CHANGED}" ]; then
    echo 'repo has changes - aborting.';
  else
    basebranch=${1:-master}
    git checkout $basebranch > /dev/null 2>&1 && git pull > /dev/null 2>&1 && git checkout - > /dev/null 2>&1
    brnch=$(git branch | grep \* | cut -d ' ' -f2)
    hash1=$(git show-ref --heads -s ${basebranch})
    hash2=$(git merge-base ${basebranch} ${brnch})
    [ "${hash1}" = "${hash2}" ] && echo "Rebase required: false" || echo "Rebase required: true"
  fi
}

# our handler that returns choices by populating Bash array COMPREPLY
# (filtered by the currently entered word ($2) via compgen builtin)
_gitpull_complete() {
    branches=$(git branch -l | cut -c3-)
    COMPREPLY=($(compgen -W "$branches" -- "$2"))
}

# we now register our handler to provide completion hints for the "gitpull" command
complete -F _gitpull_complete shouldirebase
complete -F _gitpull_complete gitc

# Checkout master and delete the branch you were on previously.
deletebranch () {
  BRANCH=$(git branch | sed -nr 's/\*\s(.*)/\1/p')
  git checkout master
  git branch -D $BRANCH
}
