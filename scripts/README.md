
## Fabric first network

Download script:

```bash
wget https://github.com/4ever9/kooka/raw/master/scripts/ffn.sh
```

```bash
./ffn.sh up // 启动fabric网络
./ffn.sh down // 清理fabric网络
./ffn.sh restart // 重启fabric网络
```

`./ffn.sh up`执行完，会在当前目录生成一个`crypto-config`，该文件夹提供给后续调用chaincode所用

## Chaincode

Download script:

```bash
wget https://github.com/4ever9/kooka/raw/master/scripts/chaincode.sh
```

```bash
./chaincode.sh install <fabric_ip> // 安装相应chaincode
./chaincode.sh upgrade <fabric_ip> // <chaincode_version> // 升级相应chaincode
./chaincode.sh init <fabric_ip> // 初始化broker合约
./chaincode.sh get_balance <fabric_ip> // 获取Alice的余额
./chaincode.sh get_data <fabric_ip> // 获取path健的值
./chaincode.sh interchain_transfer <fabric_ip> <target_appchain_id> // 跨链转账
./chaincode.sh interchain_gt <fabric_ip> <target_appchain_id> // 跨链获取path的值
```

## Fabric pier
Download script:

```bash
wget https://github.com/4ever9/kooka/raw/master/scripts/fabric_pir.sh
```

```bash
./fabric_pier.sh start  <bitxhub_addr> <fabric_ip> <pprof_port> // 启动pier
./fabric_pier.sh rstart  <bitxhub_addr> <fabric_ip> <pprof_port> // 重启pier
./fabric_pier.sh id // 获取该pier的id
```

