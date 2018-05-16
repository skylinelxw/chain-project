#/bin/bash

docker pull hyperledger/fabric-tools:x86_64-1.1.0;
docker tag hyperledger/fabric-tools:x86_64-1.1.0 hyperledger/fabric-tools:latest;

docker pull hyperledger/fabric-orderer:x86_64-1.1.0;
docker tag hyperledger/fabric-orderer:x86_64-1.1.0 hyperledger/fabric-orderer:latest;

docker pull hyperledger/fabric-peer:x86_64-1.1.0;
docker tag hyperledger/fabric-peer:x86_64-1.1.0 hyperledger/fabric-peer:latest;

docker pull hyperledger/fabric-javaenv:x86_64-1.1.0;
docker tag hyperledger/fabric-javaenv:x86_64-1.1.0 hyperledger/fabric-javaenv:latest;

docker pull hyperledger/fabric-ccenv:x86_64-1.1.0;
docker tag hyperledger/fabric-ccenv:x86_64-1.1.0 hyperledger/fabric-ccenv:latest;

docker pull hyperledger/fabric-ca:x86_64-1.1.0;
docker tag hyperledger/fabric-ca:x86_64-1.1.0 hyperledger/fabric-ca:latest;

docker pull hyperledger/fabric-baseos:x86_64-0.4.6;
docker tag hyperledger/fabric-baseos:x86_64-0.4.6 hyperledger/fabric-baseos:latest;

docker pull hyperledger/fabric-couchdb:x86_64-0.4.6;
docker tag hyperledger/fabric-couchdb:x86_64-0.4.6 hyperledger/fabric-couchdb:latest;

docker pull hyperledger/fabric-kafka:x86_64-0.4.6;
docker tag hyperledger/fabric-kafka:x86_64-0.4.6 hyperledger/fabric-kafka:latest;

docker pull hyperledger/fabric-zookeeper:x86_64-0.4.6;
docker tag hyperledger/fabric-zookeeper:x86_64-0.4.6 hyperledger/fabric-zookeeper:latest ;