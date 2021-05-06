configLocation="../../config/default-settings.json"
currentScript="topic-partition.sh"

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

address=$(sh $(find $commandPath  -name broker-all-settings.sh | head -n 1) $serverProperties zookeeper-address)
port=$(sh $(find $commandPath  -name broker-all-settings.sh | head -n 1) $serverProperties zookeeper-port)

echo ""
echo "##########################################################"
echo "# Qual tópico deve ter seu número de partições alterado? #"
echo "##########################################################"
read topico
echo "Novo número de partições para $topico:"
read partitionNumber

if [ "$partitionNumber" -eq "$partitionNumber" ]
then
	echo "Alterando o número de partições do tópico $topico para $partitionNumber."
	return=$(pwd)
	cd $kafkaPath
	bin/kafka-topics.sh --alter --zookeeper $address:$port  --topic $topico --partitions $partitionNumber
	echo "Alteração concluída."
fi

cd $return
sh topic-partition.sh
