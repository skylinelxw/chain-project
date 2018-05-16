Hyperledger fabric  多机部署实战;

 官方fabric的更新速度还是相对较快的，v1.0跟v1.1还是有一些差异的，由于当前要上生产的时候发现v1.1“更好”一点，所以升级到了v1.1，所以做了相应的改动。

 本工程v2版本更新内容如下：
	1、增加了couchdb、ca节点；
	2、增加数据持久化配置；
	3、升级适配fabric1.1
	需要先升级fabric环境，重新拉取fabric，拉取相应的docker镜像

一、环境准备
本文实战的前置条件：
	1.安装部署了 fabric ；
	2.成功运行fabric e2e_cli单机模式；（直接运行example脚本即可）
	3.单机部署，可参考文章：https://www.jianshu.com/p/4ae6d070ddbb
单机部署比较简单，基本就是docker、go安装和镜像拉取、案例拉取，运行脚本即可。

这里简单再讲下安装环境：
	1、安装docker、docker-compose、go、gcc、git，这个可参考以上链接
	2、创建一个目录：/opt/gopath/src/github.com/hyperledger ,拉取最新的fabric: git clone https://github.com/hyperledger/fabric.git
	3、进入fabric，运行scripts/bootstrap.sh 拉取镜像
	4、拉取完成后，make release
	5、进入examples/e2e_cli  运行./network_setup.sh up 最终看到all good 即可，记得下次运行前，先./network_setup.sh down 
	6、大功告成

升级：
	尝试过只拉取镜像，fabric不拉取最新的，结果发现有些配置会不一样导致程序报错，所以建议重新拉取一下fabric 然后再拉去下镜像


操作系统：centos7.0；

二、目标
本案例旨在部署包含3个orderer节点、4个peer节点（两个组织）的farbic基础网络架构
排序服务使用多进程的kafka共识：其中包括4个kafka节点和3个zookeeper节点；
peer节点状态数据库用的是couchdb，所以包括了4个couchdb节点；
使用ca服务器，每个组织一个ca服务器，所以包括了2个ca节点；
基础网络稳定后，就不可以全心投入智能合约研发和顶层业务定制，后者才是重点。

部署情况：

10.0.200.111机器：
	|-orderer1.lychee.com
	|-ca0.org1.lychee.com

10.0.200.113机器：
	|-orderer2.lychee.com
	|-peer0.org1.lychee.com
	|-z1   (zookeeper)
	|-k1   (kafka)
	|-couchdb0.org1.lychee.com

10.0.200.114机器：
	|-orderer3.lychee.com
	|-peer1.org1.lychee.com
	|-z2
	|-k2
	|-couchdb1.org1.lychee.com

10.0.200.115机器：
	|-peer0.org2.lychee.com
	|-z3
	|-k3
	|-couchdb0.org2.lychee.com

10.0.200.116机器：
	|-peer1.org2.lychee.com
	|-k4
	|-ca0.org2.lychee.com
	|-couchdb1.org2.lychee.com

三、文件说明
部署最终要的是要理解，不然每次遇到问题就会没有头绪。
文件主要分三类：证书相关、docker容器相关和帮助类脚本；
1、证书相关文件
	区块链中一个比较重要的特性就是安全、防篡改，所以证书就必不可少；比较常见的证书创建工具是openssl，fabric有自己的一个证书生成工具：cryptogen；每个通道的创世区块是需要预先生成的，fabric提供的工具是configtxgen；
	cryptogen 可以指定配置文件：crypto-config-3o4p.yaml，这个文件定义了有多少个orderer和组织，每个组织有多少个peer；
	configtxgen 默认使用：configtx.yaml，这个文件描述了通道有多少个组织加入，以及排序服务属性、区块大小等等；
	我们把这个配置放在了CentOs-111服务器上了，所以要去centos-111/e2e_cli文件夹中查看

2、docker容器相关文件
	docker启动可以使用docker-compose，指定配置文件；配置文件中则包含了容器名称、环境变量、端口映射、文件夹映射、容器启动后的立即运行的命令等等；可参考：https://www.jianshu.com/p/00c5939a64af 查看每个字段的含义；要注意文件映射和cli服务的环境变量！
	docker配置文件又可层层包含，将可共用的部分单独制定一个文件，名称可自定义，但要注意别写错，比如base中的文件；
	文件包括：
		docker-compose-orderer.yaml  orderer容器配置文件
			|-base/docker-compose-base.yaml
				|-base/orderer-base.yaml
				|-base/peer-base.yaml

		docker-compose-peer.yaml  peer容器配置文件
			|-base/docker-compose-base.yaml
				|-base/orderer-base.yaml
				|-base/peer-base.yaml

		docker-zk.yaml   zookeeper容器配置文件
			|-base/kafka-base.yaml

		docker-kafka.yaml kafka容器配置文件
			|-base/kafka-base.yaml

		docker-compose-ca.yaml ca配置文件
			主要配置了ca的根证书（记得修改为实际的，否则ca会挂），ca服务器的管理员账户和密码也就是所谓的admin／adminpw，生产的时候改成自己知道的就好

		base/docker-compose-base.yaml  基础配置文件
		base/orderer-base.yaml  基础配置文件
		base/peer-base.yaml  基础配置文件

3、帮助脚本类文件
	此类文件就是IBM写的一些帮助脚本，脚本中包含了证书生成命令、创世区块生成命令、通道创建命令、peer加入通道命令、链码安装、实例化、调用等等脚本；这些命令都是可以单独拆分运行的，所以非常建议细读这些脚本命令！！
	download-dockerimages.sh 这个脚本是拉取docker fabric相关镜像的用的，只是在最初部署的时候会用，这里没有用到；
	generateArtifacts-3o4p.sh 这脚本是创建证书和通道创始区块用的，可携带一个通道名称参数：
	./generateArtifacts-3o4p.sh yourchannel 其中yourchannel是通道名称；
		|- cryptogen  generate --config=./crypto-config-3o4p.yaml 创建证书命令
		|- configtxgen -profile TwoOrgsOrdererGenesis2 -outputBlock ./channel-artifacts/genesis.block 创建创世区块
		|- configtxgen -profile TwoOrgsChannel2 -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID yourchannel 创建创世区块
		|- configtxgen -profile TwoOrgsChannel2 -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP 创建创世区块
		|- configtxgen -profile TwoOrgsChannel2 -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP 创建创世区块
	
	脚本运行后会生成根证书、msp证书、orderer证书、peer证书、tls证书等等和区块相关文件，即：channel-artifacts和crypto-config文件夹内容，可放在任何一个节点运行，生成后按照需要分发到不同的节点；

	/centos-113/e2e_cli/scripts/script.sh  通道创建命令、peer加入通道命令、链码安装、实例化、调用等等脚本，这个就是具体实践了；基本算是命令的集合，每个命令执行前都要先设置环境变量；看下函数：
		|- createChannel 创建通道
		|- joinChannel 加入通道
		|- updateAnchorPeers 0 更新锚点
		|- installChaincode 2 安装链码
		|- instantiateChaincode 2 实例化链码
		|- chaincodeQuery 0 100 链码查询
		|- chaincodeInvoke 0 链码操作

	每个函数建议都去细看下，理解为主；


四、部署运行
1、先clone到本地，然后修改实际IP地址
	git clone https://github.com/skylinelxw/chain-project.git
   主要修改docker配置文件中的IP地址信息，其他暂且可以不变。

2、根据自己的需要重新生成证书（可选）
   案例中创建的通道名称是 sunshine，如果重新生成，则需要将生成的证书替换现有的证书；

3、分发文件
   将各个机器的配置文件分发到各个机器上，机器也需要安装一样的环境；

4、按顺序启动 (主要节点部署情况)
   a. zookeeper是一个集群插件，所以可以单独先启动；
	docker-compose -f docker-zk.yaml up -d  其中-d是后台运行的意思，如果要看日志可以加--verbose 参数
	检查：docker ps 每台机器可查看到一个docker的容器：z1
	实在不放心可进入容器看zk状态：
		docker exec -it z1 bash
		./bin/zkServer.sh status
			ZooKeeper JMX enabled by default
			Using config: /conf/zoo.cfg
			Mode: follower
		
   b. kafka 启动依赖于zk集群;
	docker-compose -f docker-kafka.yaml up -d
	分别在每台机器上启动

   c. orderer 排序服务启动
	docker-compose -f docker-compose-orderer.yaml up -d
	分别在每台机器上启动，可以使用：
	docker logs orderer1.lychee.com 查看日志 

   d. peer 组织节点启动
	docker-compose -f docker-compose-peer.yaml up -d
	分别在每台机器上启动

   e. ca服务器节点启动
	docker-compose -f docker-compose-ca.yaml up -d
	分别在需要的机器上启动

5、运行测试脚本
   测试脚本的修改目前只修改了org1的peer0节点的脚步，即centos-113上的scripts中的文件；
   进入centos-113节点：
	docker exec -it lycheecli bash 进入lycheecli客户端容器
	./scripts/script.sh sunshine 运行测试脚本；
   出现============ All GOOD, End-2-End execution completed ============ 就大功告成；
 
五、可能遇到的问题
1、当需要更换证书或通道时，需要stop且rm掉容器，zookeeper可以不动，如果重复使用一个通道名，则需要连同kafka一起干掉；
	docker stop orderer2.lychee.com peer0.org1.lychee.com k1
	docker rm orderer2.lychee.com peer0.org1.lychee.com k1

2、重复使用同一个通道名称可能造成kafka识别问题，需要连同kafka一起干掉重建

3、注意看运行的日志，如果创建通道就有问题，则可能是hosts配置错误或证书配置问题，干掉重来；

4、如果日志已经创建成功，则看运行到哪一部，解决问题后，手动修改script.sh文件，注释掉已运行成功的函数；

5、如果要修改lychee.com 域，则需要修改证书生成配置文件和各个节点的文件夹映射关系，这个地方需要细心！！

6、运行过程中，尝试看对应节点的日志
	docker logs peerx.orgx.lychee.com

7、铲掉重来，无法报错问题
	因为最新的配置增加了数据持久化，所以需要每次

8、 BAD_REQUEST -- error authorizing update: error validating DeltaSet: invalid mod_policy for element [Policy] /Channel/Application/Writers: mod_policy not set
	铲掉重来可以解决，非常有可能是第一次搭建没有删除干净
9、ca启动后一会就宕机的原因是docker.yaml中的文件名称配置问题

10、'' has invalid keys: capabilities

11、创世区块通道tx生成时，x509问题，这个是之前旧证书混淆导致，删除历史的即可

还有一些设计或问题详细描述见：
https://www.jianshu.com/p/baaa828577e6

持续整理中……