#!/bin/bash
# set globals for Hyperledger peers

if [ $1 -eq 0 -o $1 -eq 1 ] ; then
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  if [ $1 -eq 0 ]; then
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
  else
    export CORE_PEER_ADDRESS=peer1.org1.example.com:7051
  fi
else
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  if [ $1 -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
  else
    export CORE_PEER_ADDRESS=peer1.org2.example.com:7051
  fi
fi
echo "Setting CORE_PEER_LOCALMSPID:" $CORE_PEER_LOCALMSPID
echo "Setting CORE_PEER_ADDRESS:" $CORE_PEER_ADDRESS
echo "Setting CORE_PEER_TLS_ROOTCERT_FILE:" $CORE_PEER_TLS_ROOTCERT_FILE
echo "Setting CORE_PEER_MSPCONFIGPATH:" $CORE_PEER_MSPCONFIGPATH
