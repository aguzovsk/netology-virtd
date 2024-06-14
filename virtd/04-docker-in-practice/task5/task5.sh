source task5_env.txt
# docker secret create may be used, but is unnecessary

# Clean up cmd arguments to the script, if any, so they do not disturb further script execution
while [ $# -gt 0 ]; do
  if [ -v $1 ]; then
    echo "\$1=\"$1\""
  fi
  shift
done

# make an array (queue) of arguments that should have been read from task5_env.txt
# if were not specified, ask for them
set -- DUMPER_PASSWORD MYSQL_ROOT_PASSWORD TABLE_NAME
while [ $# -gt 0 ]; do
  if [ -z ${!1} ]; then
    read -p "$1 is not specified: " $1
  fi
  shift
done

# If need TABLE SPACES, i.e. to omit --no-tablespaces flag in mysqldump, add the following:
# GRANT PROCESS ON *.* TO 'dumper';
echo "CREATE USER IF NOT EXISTS 'dumper' IDENTIFIED WITH mysql_native_password BY '${DUMPER_PASSWORD}';
  REVOKE ALL PRIVILEGES ON *.* FROM 'dumper'; GRANT SELECT, LOCK TABLES ON ${TABLE_NAME}.* TO 'dumper';" |
docker exec -i db mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" mysql

chmod +x script.sh
docker run -d --rm \
  --name schnitzler \
  --network 04-docker-in-practice_backend \
  -v /opt/backup:/backup \
  -v $(pwd)/script.sh:/usr/local/cron-job.sh \
  schnitzler/mysqldump

# NOTE: password will be seen with `crontab -l` command
echo "* * * * * /usr/local/cron-job.sh ${DUMPER_PASSWORD} ${TABLE_NAME}" |
docker exec -i schnitzler crontab -
