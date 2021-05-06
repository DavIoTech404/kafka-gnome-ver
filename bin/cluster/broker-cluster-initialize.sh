configLocation="../../config/default-settings.json"
currentScript="broker-cluster-initialize.sh"

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

for broker in $(echo "${brokerCluster}" | jq -r '. | @base64'); do
	serverProperties=$(echo ${broker} | base64 --decode | jq -r '.path')
	id=$(echo ${broker} | base64 --decode | jq -r '.id')
	echo "Incializando o broker: "$id
	sh $(find $commandPath -name broker-kafka.sh | head -n 1) $serverProperties &
done
