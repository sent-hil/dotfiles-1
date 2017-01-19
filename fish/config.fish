set -x TERM xterm-256color
set -x EDITOR /usr/local/bin/vim

function fish_prompt --description 'Write out the prompt'
  # Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_hostname
    # set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
  end

  if not set -q __fish_prompt_normal
    set -g __fish_prompt_normal (set_color normal)
  end

  if not set -q __git_cb
    set __git_cb ":"(set_color brown)(git branch ^/dev/null | grep \* | sed 's/* //')(set_color normal)""
  end

  switch $USER
    case root

    if not set -q __fish_prompt_cwd
      if set -q fish_color_cwd_root
          set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
      else
          set -g __fish_prompt_cwd (set_color $fish_color_cwd)
      end
    end

    printf '%s%s%s%s# ' $__fish_prompt_hostname "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" $__git_cb

    case '*'

    if not set -q __fish_prompt_cwd
      set -g __fish_prompt_cwd (set_color $fish_color_cwd)
    end

    printf '%s%s%s%s$ ' $__fish_prompt_hostname "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" $__git_cb
  end
end

function clear
  command "clear"
  printf '\e[3J'
end

# .envrc file
eval (direnv hook fish)

# go package manager
function gvm
  bass source ~/.gvm/scripts/gvm ';' gvm $argv
end
gvm use go1.6.2

set PATH /usr/local/sbin $PATH ~/.gobin

alias ag="ag --pager 'more -R' $argv"

set PATH $GEM_HOME/bin $PATH
rvm > /dev/null

alias ga="oldgit add . -p"
alias gs="oldgit status"

alias gcd="oldgit checkout develop"
alias gcm="oldgit checkout master"
alias gcn="oldgit checkout -b $argv"

alias gc="oldgit commit -m $argv"
alias gca="oldgit commit --amend"

alias gd="oldgit d"
alias gdh="oldgit dh"

alias gp="oldgit push"
alias ghf="oldgit hf update"
alias gpd="oldgit pull --rebase origin develop"
alias gpm="oldgit pull --rebase origin master"

alias gst="oldgit add .; and oldgit stash"
alias gsp="oldgit stash pop"

alias gl="oldgit log"
alias glp="oldgit log -p"

alias gco="oldgit checkout $argv"

alias oldgit="/usr/local/bin/git"

function git
  for i in status "add . -p" status "checkout develop" "checkout master" "commit -m" "commit --amend" "hf update" "pull --rebase origin develop" "pull -- rebase origin master" "log -p" "pull --rebase origin develop" "pull --origin master" "stash pop" "add . -p"
    if contains $i $argv
      echo "Use shortcut"
      return
    end
  end

  oldgit $argv
end

function agq
  ag -Q $argv
end

alias agr="ag --ruby"
alias agh="ag --haml"
alias agj="ag --js"

# goatee_rebuild_dbs drops current dbs and rebuilds them.
function goatee_rebuild_dbs
  docker-compose down; and docker-compose up -d --build
  rake db:drop
  rake db:create
  rake db:schema:load
  rake db:seed
  rake db:test:prepare
end

# goatee_test_branch_migrations restores db to state they're in 'develop' and
# then runs migration from current branch.
function goatee_test_branch_migrations
  # store current branch to switch to later
  set feature_branch (git rev-parse --abbrev-ref HEAD)

  # restore to db state in develop
  git checkout develop
  goatee_rebuild_dbs

  # run branch migrations
  git checkout $feature_branch
  rake db:migrate
end

# goatee_restore_dump restores 'prod' or 'staging' pg dumps. It assumes the
# dumps are in path "~/work/dumps" and have either the name 'prod' or 'staging'.
#
# Accepts:
#   String - "staging" or "prod"
function goatee_restore_dump
  if contains "prod" $argv
    rake db:restore['~/work/dumps/prod.dump']
  else
    rake db:restore['~/work/dumps/staging.dump']
  end
end

# goatee_switch_and_update_develop checkouts to develop and updates from origin.
function goatee_switch_and_update_develop
  git stash
  git checkout develop
  git hf update
end

# goatee_run_foreman cp Procfile.dev from ~/work/Procfile to current dir and
# runs foreman with that file.
#
# This is required since the Procfile.dev in goatee repo uses different settings
# than local (mainly running rails s manually vs powder.)
function goatee_run_foreman
  cp ~/work/Procfile.dev .
  foreman start -f Procfile.dev &
  sleep 2
  git checkout Procfile.dev
  fg
end
