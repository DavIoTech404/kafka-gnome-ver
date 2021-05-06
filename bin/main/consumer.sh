configLocation="../../config/default-settings.json"
currentScript="consumer.sh"

if [ ! -f "$configLocation" ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name $currentScript | grep -v Trash | head -n 1 | sed 's/'$currentScript'//')
	cd $currentScriptDir
fi
sh $(echo "$(echo $configLocation | awk -Fdefault-settings.json '{ print $1 }')dataVerifier.sh") $configLocation $currentScript
commandPath=$(cat $configLocation | jq '.commandPath' | sed 's/"//g')
kafkaPath=$(cat $configLocation | jq '.kafkaPath' | sed 's/"//g')

serverProperties=$(find $kafkaPath  -name  server.properties | head -n 1)

if [ ! -z $1 ]
then
	serverProperties=$1
fi

address=$(sh $(find $commandPath  -name broker-all-settings.sh | head -n 1) $serverProperties broker-address)
port=$(sh $(find $commandPath  -name broker-all-settings.sh | head -n 1) $serverProperties broker-port)

consumer=$(jq -r '.[].consumer' $(find $commandPath -name service-config.json | head -n 1))
cd $kafkaPath
    
echo "Criando consumer do tópico: $consumer"
bin/kafka-console-consumer.sh --topic $consumer --from-beginning --bootstrap-server $address:$port
