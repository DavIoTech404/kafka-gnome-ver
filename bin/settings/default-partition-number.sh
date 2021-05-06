configLocation="../../config/default-settings.json"
currentScript="default-partition-number.sh"

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
rerun=$(echo sh $(find $commandPath  -name default-partition-number.sh | head -n 1))

if [ ! -z $1 ]
then
	serverProperties=$1
fi

sed '/listeners=PLAINTEXT:\/\/:9092/c\listeners=PLAINTEXT:9092' -i $serverProperties
sed '/#/c\' -i $serverProperties

validator=0
while [ $validator -eq 0 ]
do
	if [ -z $2 ]
	then
		echo ''
		echo "#############################################################"
		echo "## Qual será o novo número Padrão de Partições por Tópico? ##"
		echo "#############################################################"
		read number
	else
		number=$2
	fi
	
	if [ "$number" -eq "$number" ]
	then
		sed '/num.partitions=/c\num.partitions='$number'' -i $serverProperties
		echo "Configuração concluída, novo número padrão de partições: $number"
		validator=1
	else
		echo "Número inválido"
		validator=0
	fi
done

if [ -z $1 ]
then
	$rerun
fi
