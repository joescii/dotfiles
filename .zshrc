
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

export DOCKERHOST=`bash ~/.dotfiles/.get_my_ip.sh`

export COG_BASE_DIR=/Users/joedaniel/code/cognitops/
serv-pull(){
  local services=($@) 
  if [ -z $services ]; then
    services=(kafka postgres redis)
  fi
  for service in "${services[@]}"; do
    docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" pull &;
  done
  wait
}
serv-down(){
  local services=($@) 
  if [ -z $services ]; then
    services=(kafka postgres redis)
  fi
  for service in "${services[@]}"; do
    docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" down &;
  done
  wait
}
serv-up(){
  local services=($@) 
  if [ -z $services ]; then
    services=(kafka postgres redis)
  fi
  for service in "${services[@]}"; do
    docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" pull && \
      docker-compose -f "$COG_BASE_DIR/tools/$service/docker-compose.yml" up -d &;
  done
  wait
}

bindkey -v

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/joedaniel/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/joedaniel/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/joedaniel/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/joedaniel/google-cloud-sdk/completion.zsh.inc'; fi

export GOOGLE_APPLICATION_CREDENTIALS=/Users/joedaniel/gcp/build-240615-f65c1944eb32.json

bindkey '^r' history-incremental-search-backward

