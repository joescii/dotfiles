
export PATH="/usr/local/opt/node@14/bin:$HOME/tools:$HOME/.jenv/bin:/Users/joedaniel/Library/Application Support/Coursier/bin:$PATH"
eval "$(jenv init -)"

export DOCKERHOST=`bash ~/.dotfiles/.get_my_ip.sh`

export COG_BASE_DIR=/Users/joedaniel/code/cognitops/
serv-pull(){
  local services=($@) 
  if [ -z $services ]; then
    services=(postgres redis)
  fi
  for service in "${services[@]}"; do
    docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" pull &;
  done
  docker-compose -f "$COG_BASE_DIR/tools/kafka/local-docker/docker-compose.yml" pull &;
  wait
}
serv-down(){
  local services=($@) 
  if [ -z $services ]; then
    services=(postgres redis)
  fi
  for service in "${services[@]}"; do
    docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" down &;
  done
  docker-compose -f "$COG_BASE_DIR/tools/kafka/local-docker/docker-compose.yml" down &;
  wait
}
serv-up(){
  local services=($@) 
  if [ -z $services ]; then
    services=(postgres redis)
  fi
  for service in "${services[@]}"; do
    docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" pull && \
      docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" up -d &;
  done
  docker-compose -f "$COG_BASE_DIR/tools/kafka/local-docker/docker-compose.yml" pull && \
    docker-compose -f "$COG_BASE_DIR/tools/kafka/local-docker/docker-compose.yml" up -d &;
  wait
}

bindkey -v

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/joedaniel/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/joedaniel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/joedaniel/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/joedaniel/google-cloud-sdk/completion.zsh.inc'; fi

gcloud-account(){
  if [ "$1" = "build" ]; then
    export GOOGLE_APPLICATION_CREDENTIALS=/Users/joedaniel/gcp/build-240615-f65c1944eb32.json
    gcloud config set project build-240615
  elif [ "$1" = "beta" ]; then
    unset GOOGLE_APPLICATION_CREDENTIALS
    gcloud config set project beta-243321
    gcloud container clusters get-credentials cognitops-align-beta --zone us-central1 --project beta-243321
  elif [ "$1" = "prod" ]; then
    unset GOOGLE_APPLICATION_CREDENTIALS
    gcloud config set project prod-238418
    gcloud container clusters get-credentials cognitops-align-prod --zone us-central1 --project prod-238418
  else
    echo "Unknown account: $1"
  fi
}

alias postgres-proxy-uk='/Users/joedaniel/tools/cloud_sql_proxy -instances=prod-238418:europe-west2:align-europe-west2=tcp:5432'
alias postgres-proxy-prod='/Users/joedaniel/tools/cloud_sql_proxy -instances=prod-238418:us-central1:postgres-prod-1=tcp:5432'

bindkey '^r' history-incremental-search-backward

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt

# Echoes information about Git repository status when inside a Git repository
git_info() {

  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  # Git branch/tag, or name-rev if on detached head
  local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

  local AHEAD="%{$fg[red]%}⇡NUM%{$reset_color%}"
  local BEHIND="%{$fg[cyan]%}⇣NUM%{$reset_color%}"
  local MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
  local UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
  local MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
  local STAGED="%{$fg[green]%}●%{$reset_color%}"

  local -a DIVERGENCES
  local -a FLAGS

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    FLAGS+=( "$MERGING" )
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=( "$UNTRACKED" )
  fi

  if ! git diff --quiet 2> /dev/null; then
    FLAGS+=( "$MODIFIED" )
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=( "$STAGED" )
  fi

  local -a GIT_INFO
  GIT_INFO+=( "±" )
  [ -n "$GIT_STATUS" ] && GIT_INFO+=( "$GIT_STATUS" )
  [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
  [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
  GIT_INFO+=( "$GIT_LOCATION%{$reset_color%}" )
  echo "${(j: :)GIT_INFO}"

}

# Use ❯ as the non-root prompt character; # for root
# Change the prompt character color if the last command had a nonzero exit code
PS1='%{$fg[black]%}%~%u $(git_info) %(?.%{$fg[blue]%}.%{$fg[red]%})%(?.%F{green}❯.%F{red}%?!)%{$reset_color%} '

