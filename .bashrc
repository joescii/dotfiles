eval "$(thefuck --alias)"

PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:/Users/joescii/.conscript/bin:$PATH"

# Supposedly this stops MacOS from clobbering history files 
# https://superuser.com/questions/950403/bash-history-not-preserved-between-terminal-sessions-on-mac 
export SHELL_SESSION_HISTORY=0

set -o vi

function init {
  dotfiles=(
    .bashrc
    .gitconfig
    .profile
    .vimrc
  )
  dotclients=(
    .bintray
    .sbt
  )
  lnLoop .dotfiles "${dotfiles[@]}" 
  lnLoop .clients "${dotclients[@]}" 

  md $code
  md $clients
  md $oss
  md $lift

  md ~/.m2/
#  ln -s ~/.clients/.m2/settings.xml ~/.m2/settings.xml
}

function lnLoop {
  dir=$1
  shift
  arr=("$@")
  for f in "${arr[@]}"; do
    echo "linking ~/$dir/$f..."
    rm -fr ~/$f
    ln -s ~/$dir/$f ~/$f
  done
}

function sbtBw {
  sbt -Dsbt.log.format=false "$@"
}

function sbt-dependencyClasspath {
  sbtBw "show $1dependencyClasspath" | tr ',' '\n'
}

function sbt-fullClasspath {
  sbtBw "show $1fullClasspath" | tr ',' '\n'
}

export sbt_home=`which sbt`
export sbt_jar=`tail -1 $sbt_home | awk -F\" '{print $2 "-launch.jar"}'`

function snapshot-report {
  find ~/.ivy2/cache/ | grep SNAPSHOT 
}

function snapshot-purge {
  snapshot-report | xargs rm -fr 
}

function public-ip {
  curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//' | tr -d '\n'
}

function cert-fetch {
  if [ $# -eq 0 ]; then
    echo "USAGE: cert-fetch <domain>"
    return -1
  fi
  
  echo | openssl s_client -showcerts -servername $1 -connect $1:443 2>/dev/null | openssl x509 -inform pem -noout -text
}

function jdk7 {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
  export SBT_OPTS="-Xms512M -Xmx2G -Xss256m -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=512M -Dsun.io.serialization.extendedDebugInfo=true"
  export MAVEN_OPTS=$SBT_OPTS
}

function jdk8 {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_151.jdk/Contents/Home
  export SBT_OPTS="-Xms512M -Xmx2G -Xss256m -XX:+CMSClassUnloadingEnabled -Dsun.io.serialization.extendedDebugInfo=true"
}

# Call jdk8 to set our options (by default this is already the JAVA_HOME)
jdk8

function md {
  [[ -d $1 ]] || mkdir -p $1
}

function git-pull {
  if [ $# -eq 0 ]; then
    echo "git-pull [remote] <branch>"
    return -1
  elif [ $# -eq 1 ]; then
    remote=origin
    branch=$1
  else
    remote=$1
    branch=$2
  fi
 
  echo "Fetching remote branches..."

  git fetch $remote
  git checkout -b $branch $remote/$branch
}

alias gs='git status --short'

function sl {
  ln -s $2 $1
}

function kill-9-all {
  if [ $# -eq 0 ]; then
    echo "kill-9-all <process_name>"
    return -1
  fi

  ps -ef | grep $1 | grep -v grep | awk '{print $2}' | xargs kill -9
}

function hoisted {
  if [ $# -gt 0 ]; then
    dir=$1
  else
    dir=$PWD
  fi

  java -jar ~/tools/hoisted.jar -server $dir
}

function docker-cleanup {
  docker ps | awk '{print $1}' | grep -v CONTAINER | xargs docker kill
  docker rm $(docker ps -q -f status=exited)
  docker volume rm $(docker volume ls -qf dangling=true)
  docker rmi $(docker images | grep '<none>' | awk '{print $3}')
}

alias mysql-start='mysql.server start'
alias mysql-stop='mysql.server stop'
alias mysql-clean-jetty='mysql -uroot -e "drop table lift_sessions.JettySessions; drop table lift_sessions.JettySessionIds;"'

export code=~/Documents/code/
export oss=$code/oss/
export clients=$code/clients/
export lift=$oss/lift-framework

if [ -d ~/.clients ]; then
  for f in ~/.clients/*; do
    source $f
  done 
fi

