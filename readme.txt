Hyperledger fabric 1.0 多级部署实战;

本文实战的前置条件：
	1.安装部署了 fabric 1.0
	2.成功运行fabric 1.0 e2e_cli单机模式；（直接运行example脚本即可）
	3.可参考文章：https://www.jianshu.com/p/4ae6d070ddbb
 
本案例包含3个orderer节点、4个peer节点、以及4个kafka节点和3个zookeeper节点；
centos7.0系统；
部署情况：
10.0.200.111机器：
	|-orderer1.lychee.com

10.0.200.113机器：
	|-orderer2.lychee.com
	|-peer0.org1.lychee.com
	|-z1   (zookeeper)
	|-k1   (kafka)

10.0.200.114机器：
	|-orderer3.lychee.com
	|-peer1.org1.lychee.com
	|-z2
	|-k2

10.0.200.115机器：
	|-peer0.org2.lychee.com
	|-z3
	|-k3

10.0.200.116机器：
	|-peer1.org2.lychee.com
	|-k4

持续整理中……