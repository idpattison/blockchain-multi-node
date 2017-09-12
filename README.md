# Multi-Node Hyperledger Composer

These instructions walk you through setting up a Hyperledger Composer business network running on 2 separate servers.
_Server 1_ will have the Orderer, a Certificate Authority, Peer0 and its associated CouchDB database. _Server 2_ will have Peer1 and its CouchDB database.

You will need to have two servers available, which could be separate physical machines, or two VMs.  Each machine will need to be able to _ping_ the other, and you will need to open ports in the firewall, or turn the firewall off altogether.

To start, clone the repo to both servers
```bash
git clone https://github.com/idpattison/blockchain-multi-node.git
cd blockchain-multi-node/composer
```

## Set up the /etc/hosts file
Edit the _/etc/hosts_ file on each server to point at the other.  You can do this with `atom /etc/hosts` if you have Atom installed, or use your favourite editor. We've assumed that the IP address of server 1 is _192.168.1.101_ and that of server 2 is _192.168.1.102_, but you'll need to find that out for your own setup from `ifconfig`.

Add these lines at the end - Server 1:
```
192.168.1.102  peer1.org1.example.com
```

Server 2:
```
192.168.1.101  orderer.example.com
192.168.1.101  ca.org1.example.com
192.168.1.101  peer0.org1.example.com
```

You will also need to make sure each machine can see the other, and that the following ports are open for inbound & outbound TCP traffic:
- 7050 (orderer)
- 7051 (peer requests)
- 7053 (peer events)
- 7054 (certificate authority)

The way you do that depends on your OS (for Mac it's `pfctl`); if you're behind a NAT firewall it may be easier to turn off the software firewall while you test this. You can check that the ports are open with `telnet`.


## Set up Hyperledger Fabric on Server 1
This step is similar to setting up Composer on a single server, the main differences:
- a new volume is added to the _peer0.org1.example.com_ container; this allows us to copy and extract the channel block so we can copy it to the other server.
- _crypto-config.yaml_ is updated with a Count of 2, to show we have 2 peers in Org1.
- the connection profile contains details of the second peer (_peer1.org1.example.com_) on the other server.

Run the setup scripts to create the profile, start the fabric and create a channel:
```bash
cd local-hyperledger-1
./createComposerProfile.sh
./startFabric.sh
```

Verify that your Fabric is up and running with `docker ps -a`.

You'll find a copy of the _composerchannel.block_ file created at channel creation in the _channel-block_ directory.  Copy that file to the other server, and place it in the _local-hyperledger-2/channel-block_ directory. You'll need to use a USB stick, or AirDrop, or email, or some other way of moving it.

## Set up Hyperledger Fabric on Server 2
This step will add a second peer and its database, and connect it to the channel we set up in the previous step. Note that the connection profile points back to the orderer, certificate authority and peer0 on server 1.

Make sure the channel block file has been copied to the  _local-hyperledger-2/channel-block_ directory.

Run the setup scripts to create the profile, start the fabric and join the local peer to the channel:
```bash
cd local-hyperledger-2
./createComposerProfile.sh
./startFabric.sh
```

Again, verify with `docker ps -a`.

## Deploy a business network
To test, deploy the provided business network on _Server 1_. You should always re-create the business network archive (_*.bna_) file first, to make sure it's using the same version of Composer.  Then deploy to the fabric.
```bash
cd ../business-network
composer archive create -a digital-property.bna -t dir -n .
composer network deploy -a digital-property.bna -p hlfv1 -i PeerAdmin -s anything
```

This should deploy the business network to all peers listed in the profile.  You can check on both servers that a chaincode container (beginning with _dev_) has been created.

Run the Composer REST Server on both servers, and check that changes made to one server are propagated through to the other.
```bash
composer-rest-server -n digital-property -p hlfv1 -i PeerAdmin -s anything -N never
```

You should now have a working Hyperledger Composer business network, running on two servers.

## A note on credentials
The credentials in the _creds_ directory have been pre-generated and match those in the _crypto-config_ directory.  If you change the network (for example by adding a third peer) you will need to regenerate the crypto material and the genesis/channel blocks. Remember to copy them to all servers.
```bash
cd local-hyperledger-1
cryptogen generate --config=./crypto-config.yaml
configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block
configtxgen -profile ComposerChannel -outputCreateChannelTx ./composer-channel.tx -channelID composerchannel
```

You'll then need to create a new set of credentials for your _PeerAdmin_ user, replacing _key-name_ with the actual file name.
> **NB:** there should only be one file in the _keystore_ directory, just hit TAB to auto-fill.

```bash
composer identity import -p hlfv1 -u PeerAdmin -c crypto-config/peerOrganizations/org1.example.com/users/Admin\@org1.example.com/msp/signcerts/Admin\@org1.example.com-cert.pem -k crypto-config/peerOrganizations/org1.example.com/users/Admin\@org1.example.com/msp/keystore/<key-name>
```

This will create a set of credentials in _~/.composer-credentials_; copy them to the _creds_ directory on both servers, as the script wipes the _~/.composer-credentials_ directory each time.
