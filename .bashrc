eval "$(thefuck --alias)"

PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:/Users/joescii/.conscript/bin:$PATH"

function sbt-dependencyClasspath {
  sbt -Dsbt.log.format=false "show $1dependencyClasspath" | tr ',' '\n'
}

export sbt_home=`which sbt`
export sbt_jar=`tail -1 $sbt_home | awk -F\" '{print $2 "-launch.jar"}'`

function public-ip {
  curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//' | tr -d '\n'
}

function jdk7 {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
  export SBT_OPTS="-Xms512M -Xmx2G -Xss256m -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=512M"
  export MAVEN_OPTS=$SBT_OPTS
}

function jdk8 {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home
  export SBT_OPTS="-Xms512M -Xmx2G -Xss256m -XX:+CMSClassUnloadingEnabled -XX:MaxMetaspaceSize=512M"
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

  git checkout -b $branch $remote/$branch
}

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

export code=~/Documents/code/
export oss=$code/oss/
export clients=$code/clients/
export lift=$oss/lift-framework

if [ -d ~/.clients ]; then
  for f in ~/.clients/*; do
    source $f
  done 
fi

