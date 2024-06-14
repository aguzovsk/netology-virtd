# source task5_env.txt
mysqldump --no-tablespaces -h db -u dumper -p$1 --result-file=/backup/dump_$(date +%M-%H-%d-%m-%Y).sql $2