#!/bin/bash

# Exit on first error, print all commands.
set -ev

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#
docker-compose -f "${DIR}"/docker-compose.yml down
docker-compose -f "${DIR}"/docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, set the sleep timer to a larger number of seconds
echo "Waiting for 15 seconds..."
sleep 15

# Create the channel
docker exec peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c composerchannel -f /etc/hyperledger/configtx/composer-channel.tx

# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b composerchannel.block

cd ../..
