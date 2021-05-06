configLocation="../../config/default-settings.json"
currentScript="server-port.sh"

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
rerun=$(echo sh $(find $commandPath  -name server-port.sh | head -n 1))

if [ ! -z $1 ]
then
	serverProperties=$1
fi

sed '/#listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

if [ -z $2 ]
then	
	echo ''
	echo "########################################"
	echo "## Qual será a Porta a ser utilizada? ##"
	echo "########################################"
	read port
else
	port=$2
fi

address=$(sh $(find $commandPath  -name broker-all-settings.sh | head -n 1) $serverProperties broker-address)

if [ "$port" -eq "$port" ]
then
	sed '/listeners=PLAINTEXT:/c\listeners=PLAINTEXT://'$address':'$port'' -i $serverProperties
	echo "Configuração concluída, nova porta: $port"
fi

if [ -z $1 ]
then
	$rerun
fi
