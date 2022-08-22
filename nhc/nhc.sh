#!/bin/bash


CONFYAML="roomit-aptos-checker"
CONFYAMLPRETTY="RoomIT Aptos Nodes"
KINDNODE="validator" #validator or fullnode
URL="http://cikuray.roomit.xyz/"
CHAINID=43
OPTIONS=$1


function help(){
echo -e "
1. Running NHC
nhc.sh [start
2. Generate Config NHC
nhc.sh generate
3. Start Container
nhc.sh container"
}

function nhc:config(){
mkdir -p conf
if [ ${KINDNODE} == "validator" ]
then
docker run -v $(pwd)/conf:/nhc -t aptoslabs/node-checker:nightly /usr/local/bin/aptos-node-checker configuration create --configuration-name ${CONFYAML} --configuration-name-pretty "${CONFYAMLPRETTY}" --url ${URL} --chain-id ${CHAINID} --role-type validator --evaluators  consensus_proposals api_latency consensus_round api_transaction_availability
else 
docker run -v $(pwd)/conf:/nhc -t aptoslabs/node-checker:nightly /usr/local/bin/aptos-node-checker configuration create --configuration-name ${CONFYAML} --configuration-name-pretty "RoomIT Aptos Nodes" --url http://cikuray.roomit.xyz/ --evaluators consensus_proposals consensus_round consensus_timeouts api_latency network_peers_within_tolerance | tee conf/${CONFYAML}.yaml
fi
}

function nhc:container(){
docker stop ${CONFYAML}
docker rm ${CONFYAML}
docker run -d --name=${CONFYAML} -p 20121:20121 -v $(pwd)/conf:/nhc -t aptoslabs/node-checker:nightly /usr/local/bin/aptos-node-checker server run --baseline-node-config-paths /nhc/${CONFYAML}.yaml
}

case "${OPTIONS}" in
	generate)
	nhc:config;
	;;
        container)
	nhc:container
	;;
        start)
	nhc:config;
	nhc:container;
	;;
        *)
	help;
	;;
esac
