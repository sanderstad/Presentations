
$command = "/home/sander/docker/sqlserver/restart-sql1-dbaclone.sh"

plink -batch -i "C:\Users\sstad\Downloads\ssh\docker.ppk" sander@docker $command
