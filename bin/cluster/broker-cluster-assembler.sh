configLocation="../../config/default-settings.json"
currentScript="broker-cluster-assembler.sh"

if [ ! -f "$configLocation" ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name $currentScript | grep -v Trash | head -n 1 | sed 's/'$currentScript'//')
	cd $currentScriptDir
fi
sh $(echo "$(echo $configLocation | awk -Fdefault-settings.json '{ print $1 }')dataVerifier.sh") $configLocation $currentScript
commandPath=$(cat $configLocation | jq '.commandPath' | sed 's/"//g')

brokerCluster=$(cat $(find $commandPath -name broker-cluster.json | head -n 1))
json=$(echo "${brokerCluster}" | jq -r '. | @base64')
mainServerPath=$(echo $json | base64 --decode --ignore-garbage | jq -r '.path' | head -n 1)


configBroker()
{
	echo "==================================================================================================="
	echo "Configurando o broker: "$id
	sh $(find $commandPath -name server-id.sh | head -n 1) $serverPath $id
	sh $(find $commandPath -name server-port.sh | head -n 1) $serverPath $port
	sh $(find $commandPath -name default-data-dir.sh | head -n 1) $serverPath $dir
	echo "Broker: "$id", criado e configurado com sucesso!"
	echo "==================================================================================================="
}

for broker in $(echo "${brokerCluster}" | jq -r '. | @base64'); do
	serverPath=$(echo ${broker} | base64 --decode | jq -r '.path')
	id=$(echo ${broker} | base64 --decode | jq -r '.id')
	port=$(echo ${broker} | base64 --decode | jq -r '.port')
	dir=$(echo ${broker} | base64 --decode | jq -r '.dir')
	
	if [ ! "$serverPath" = "$mainServerPath" ]
	then
		if [ ! -z "$serverPath" ]
		then
			if [ -e "$serverPath" ]
			then
				echo "Editando broker existente..."
				configBroker
			else
				echo "Criando broker..."
				cp $mainServerPath $serverPath
				configBroker
			fi
		fi
	fi
done

echo "#####################################################################"
echo "### Todos os brokers disponíveis já foram criados e configurados. ###"
echo "#####################################################################"
