configLocation="../../config/default-settings.json"
currentScript="broker-cluster-quick-settings.sh"

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
	serverPath=$(echo ${broker} | base64 --decode | jq -r '.path')
	sh $(find $commandPath -name broker-all-settings.sh | head -n 1) $serverPath
done

repeat() {
	echo "Deseja alterar a configuração de mais algum broker? [y] [n]"
	while [ $validator -eq 0 ]
	do
		read rawRes
		res=$(echo $rawRes | awk '{print tolower($0)}')
		case "$res" in
			"y")
				echo "Qual o Id do broker que será alterado?"
				validator=0
			;;
			"n")
				validator=1
			;;
			*)
				echo "Operação inválida."
				validator=0
			;;
		esac
	done
}

echo "Qual o Id do broker que será alterado?"
validator=0
while [ $validator -eq 0 ]
do
	read id
	if [ ! -z "$id" ] | [ "$id" -eq "$id" ]
	then
		serverPath=$(echo "${brokerCluster}" | jq -r '. | select(.id=='\"$id\"') | .path')
		if [ ! -z "$serverPath" ]
		then
			sh $(find $commandPath -name broker-quick-settings.sh | head -n 1) $serverPath
			repeat
		else
			echo "Broker não foi encontrado..."
			validator=0
		fi
	else
		echo "Id inválido."
		validator=0
	fi
done
