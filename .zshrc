# Ctrl+Dでログアウトしてしまうことを防ぐ
setopt IGNOREEOF

# 日本語を使用
export LANG=ja_JP.UTF-8

# rbenvでrubyを管理する
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

# 色を使用
autoload -Uz colors
colors
function left-prompt {
  name_t='255m%}'      # user name text color
  name_b='000m%}'    # user name background color
  path_t='255m%}'     # path text color
  path_b='031m%}'   # path background color
  arrow='087m%}'   # arrow color
  text_color='%{\e[38;5;'    # set text color
  back_color='%{\e[30;48;5;' # set background color
  reset='%{\e[0m%}'   # reset

  user="${back_color}${name_b}${text_color}${name_t}"
  dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${user}%n%#@%m${back_color}${path_b}${text_color}${name_b}$ ${dir}%~${reset}${text_color}${path_b}${reset}\n${text_color}${arrow}> ${reset}"
}

PROMPT=`left-prompt`

# 補完
autoload -Uz compinit
compinit

# cdの後にlsを実行
chpwd() {
    if [[ $(pwd) != $HOME ]]; then;
        ls
    fi
}

# 他のターミナルとヒストリーを共有
setopt share_history

# 履歴をインクリメンタルに追加
setopt inc_append_history 

# ヒストリーに重複を表示しない
setopt histignorealldups

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# cd コマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# コマンドミスを修正
setopt correct

# peco 関連
# 過去のコマンド検索
peco-select-history() {
    BUFFER=$(history 1 | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
    CURSOR=${#BUFFER}
    zle reset-prompt
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# peco + cdr
# cdr コマンドの有効化
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':completion:*' recent-dirs-insert both
  zstyle ':chpwd:*' recent-dirs-default true
  zstyle ':chpwd:*' recent-dirs-max 1000
  zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi
function peco-cdr () {
  local selected_dir="$(cdr -l | sed 's/^[0-9]* *//' | peco --prompt "❯" --query "$LBUFFER")"
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
}
zle -N peco-cdr
bindkey '^E' peco-cdr

# Xcode のプロジェクトファイルを開く
function peco-cdr-and-open-xcode () {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | peco)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir} && xed ."
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-cdr-and-open-xcode

bindkey "^x^o" peco-cdr-and-open-xcode