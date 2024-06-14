#!/bin/bash

VAR_FILE=task4_env.txt

# Read data necessary for COMPOSE_PATH (defined below)
# check if file with necessary data exists and is not empty
if [ -f $VAR_FILE ]; then
  if [ ! -z $(tr -d "[:space:]" < $VAR_FILE) ]; then
    export $(cat $VAR_FILE)
  else
    echo "File $VAR_FILE is empty"
  fi
else
  echo "File $VAR_FILE was not found"
fi

# Clean up cmd arguments to the script, if any, so they do not disturb further script execution
while [ $# -gt 0 ]; do
  if [ -v $1 ]; then
    echo "\$1=\"$1\""
  fi
  shift
done

# make an array (queue) of vars that should have been read from $VAR_FILE
# if were not specified, ask for them
set -- GITHUB_ACCOUNT REPOSITORY BRANCH SUB_PATH YC_REGISTRY
while [ $# -gt 0 ]; do
  if [ -z ${!1} ]; then
    read -p "$1 var is not specified: " $1
  else
    echo $1 " = " ${!1}
  fi
  shift
done

COMPOSE_PATH=$GITHUB_ACCOUNT/$REPOSITORY/$BRANCH/$SUB_PATH

sudo mkdir -p /opt/04-docker-in-practice/shvirtd-example-python
sudo chown -R yc-user:yc-user /opt/04-docker-in-practice/
cd /opt/04-docker-in-practice/shvirtd-example-python

# Download only necessary files for Docker execution
# Since repository was not forked, but git module feature was used, these files could only be found in the origin repository
wget -nv https://raw.githubusercontent.com/netology-code/shvirtd-example-python/main/{.env,main.py,proxy.yaml,requirements.txt}
# Bracket expansion within bracket expansion cannot be used in sh, but can be used in bash
wget -nv -x -nH --cut-dirs 3 https://raw.githubusercontent.com/netology-code/shvirtd-example-python/main/{haproxy/reverse/haproxy.cfg,nginx/ingress/{default,nginx}.conf}

# Cannot recursively download directories form githubusercontent
# wget -nv -nH -np -r --cut-dirs 3 \
# https://raw.githubusercontent.com/netology-code/shvirtd-example-python/main/{haproxy,nginx}/

# go back to 04-docker-in-practice
cd ..
# Download compose.yaml
wget -nv https://raw.githubusercontent.com/$COMPOSE_PATH/compose.yaml
# Download scripts for 5th task
wget -nv -x -nH --cut-dirs 3 https://raw.githubusercontent.com/$COMPOSE_PATH/task5/{script.sh,task5.sh}

YC_REGISTRY=$YC_REGISTRY \
DB_PASSWORD=$(sed -ne 's/MYSQL_PASSWORD="\(.*\)"/\1/p' shvirtd-example-python/.env) \
DB_USER=$(sed -ne 's/MYSQL_USER="\(.*\)"/\1/p' shvirtd-example-python/.env) \
DB_NAME=$(sed -ne 's/MYSQL_DATABASE="\(.*\)"/\1/p' shvirtd-example-python/.env) \
docker compose up -d
