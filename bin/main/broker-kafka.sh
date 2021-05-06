configLocation="../../config/default-settings.json"
currentScript="broker-kafka.sh"

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

serverProperties=$(find $kafkaPath -name  server.properties | head -n 1)
echo "Inicializando broker..."


if [ ! -z $1 ]
then
	serverProperties=$1
fi

cd $kafkaPath

bin/kafka-server-start.sh $serverProperties

echo ""
echo "Não foi possível estabelecer conexão com Zookeeper, tentando novamente."
echo ""

bin/kafka-server-start.sh $serverProperties

echo ""
echo "Não foi possível estabelecer conexão com Zookeeper, tentando pela última vez."
echo ""

bin/kafka-server-start.sh $serverProperties

echo ""
echo "Não foi possível estabelecer conexão com Zookeeper."
