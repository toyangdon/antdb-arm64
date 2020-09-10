# antdb-arm64 容器镜像构建,用于测试
亚信AntDB容器镜像构建，arm64环境,版本5.0
# Build
`git clone https://github.com/toyangdon/antdb-arm64.git`  
`cd antdb-arm64`  
`docker build -t antdb_alone:5.0 -f antdb.dockerfile .`
# Deploy
## Docker
`docker run -d --name xxxx -p 5432:5432 -e ADB_PASSWORD=$passwd -v /xxxx:/home/adb/data/antdb40  dockerhub.ccyunchina.com/toyangdon/antdb_alone:5.0`  
*数据目录为/home/adb/data/antdb40*  
*默认用户为adb，密码由环境变量ADB_PASSWOrD指定*  
### modfiy password
`docker exec xxxx psql -d postgres -U adb -c "alter user adb with password '${new_passwd}';"`  
## Kubernetes
`kubectl apply -f ./deploy/*.yaml`  
## Test
使用postgresql方式连接测试
