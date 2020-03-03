
<#
Contents of the 'restart-sql1-dbaclone.sh' file

------------------------------------------------------------
docker stop sql1
docker rm sql1

docker run -e 'ACCEPT_EULA=Y' \
        -e 'SA_PASSWORD=Password123!@#' \
        -p 14331:1433 --name sql1 \
        -v /data/sql1:/databases \
        -v /data/dbaclone:/var/opt/mssql/data/dbaclone \
        -d mcr.microsoft.com/mssql/server:2017-latest
------------------------------------------------------------
#>

param(
        [string]$DockerFilePath,
        [string]$SshPrivateFilePath,
        [string]$User
)

$command = "/home/sander/docker/sqlserver/restart-sql1-dbaclone.sh"

plink -batch -i "C:\Users\sstad\Downloads\ssh\docker.ppk" sander@docker $command
