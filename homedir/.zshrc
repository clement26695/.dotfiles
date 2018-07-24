# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.dotfiles/oh-my-zsh
# if you want to use this, change your non-ascii font to Droid Sans Mono for Awesome
POWERLEVEL9K_MODE='nerdfont-complete'
export ZSH_THEME="powerlevel9k/powerlevel9k"

prompt_zsh_battery_level() {
  local percentage1=`pmset -g ps  |  sed -n 's/.*[[:blank:]]+*\(.*%\).*/\1/p'`
  local percentage=`echo "${percentage1//\%}"`
  local color='%F{red}'
  local symbol="\uf00d"
  pmset -g ps | grep "discharging" > /dev/null
  if [ $? -eq 0 ]; then
    local charging="false";
  else
    local charging="true";
  fi
  if [ $percentage -le 20 ]
  then symbol='\uf579' ; color='%F{red}' ;
    #10%
  elif [ $percentage -gt 19 ] && [ $percentage -le 30 ]
  then symbol="\uf57a" ; color='%F{red}' ;
    #20%
  elif [ $percentage -gt 29 ] && [ $percentage -le 40 ]
  then symbol="\uf57b" ; color='%F{yellow}' ;
    #35%
  elif [ $percentage -gt 39 ] && [ $percentage -le 50 ]
  then symbol="\uf57c" ; color='%F{yellow}' ;
    #45%
  elif [ $percentage -gt 49 ] && [ $percentage -le 60 ]
  then symbol="\uf57d" ; color='%F{blue}' ;
    #55%
  elif [ $percentage -gt 59 ] && [ $percentage -le 70 ]
  then symbol="\uf57e" ; color='%F{blue}' ;
    #65%
  elif [ $percentage -gt 69 ] && [ $percentage -le 80 ]
  then symbol="\uf57f" ; color='%F{blue}' ;
    #75%
  elif [ $percentage -gt 79 ] && [ $percentage -le 90 ]
  then symbol="\uf580" ; color='%F{blue}' ;
    #85%
  elif [ $percentage -gt 89 ] && [ $percentage -le 99 ]
  then symbol="\uf581" ; color='%F{blue}' ;
    #85%
  elif [ $percentage -gt 98 ]
  then symbol="\uf578" ; color='%F{green}' ;
    #100%
  fi
  if [ $charging = "true" ];
  then color='%F{green}'; if [ $percentage -gt 98 ]; then symbol='\uf584'; fi
  fi
  echo -n "%{$color%}$symbol" ;
}

zsh_internet_signal(){
  local color
  local symbol="\uf7ba"
  if ifconfig en0 | grep inactive &> /dev/null; then
  color="%F{red}"
  else
  color="%F{blue}"
  fi
  echo -n "%{$color%}$symbol "
}

POWERLEVEL9K_CUSTOM_BATTERY_STATUS="prompt_zsh_battery_level"
POWERLEVEL9K_CUSTOM_INTERNET_SIGNAL="zsh_internet_signal"

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2

POWERLEVEL9K_SHOW_CHANGESET=false

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''

POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0

POWERLEVEL9K_TIME_BACKGROUND="233"
POWERLEVEL9K_TIME_FOREGROUND="249"
POWERLEVEL9K_TIME_FORMAT="\UF43A %D{%H:%M}"

POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND='233'
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='blue'

POWERLEVEL9K_CUSTOM_INTERNET_SIGNAL_BACKGROUND='252'
POWERLEVEL9K_CUSTOM_BATTERY_STATUS_BACKGROUND='252'
POWERLEVEL9K_TODO_BACKGROUND='252'

DEFAULT_USER='clementdessoude'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context todo  custom_battery_status_joined ssh root_indicator dir dir_writable vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(background_jobs command_execution_time status time)

#export ZSH_THEME="random"

# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# disable colors in ls
# export DISABLE_LS_COLORS="true"

# disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load? (plugins can be found in ~/.dotfiles/oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(
  git npm osx extract z node python sublime yarn
  colored-man-pages
  zsh-syntax-highlighting
  zsh-autosuggestions
  docker docker-compose
)

source ${HOME}/.profile
source $ZSH/oh-my-zsh.sh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# run fortune on new terminal :)
fortune
