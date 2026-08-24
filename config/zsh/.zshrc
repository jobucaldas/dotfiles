# NixOS supplies Oh My Zsh framework, stock plugins, and stock theme.
export ZSH=/run/current-system/sw/share/oh-my-zsh
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"

plugins=(git kitty kubectl opentofu ssh)
ZSH_THEME=nanotech

source "$ZSH/oh-my-zsh.sh"

# History options should be set after Oh My Zsh sourcing.
HISTSIZE="10000"
SAVEHIST="10000"
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

set_opts=(
  HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
  NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
  NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
)
for opt in "${set_opts[@]}"; do
  setopt "$opt"
done
unset opt set_opts

if [ -r /run/current-system/sw/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /run/current-system/sw/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history)
fi

if [ -r /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
fi

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

pfetch
