configLocation="../../config/default-settings.json"
currentScript="broker-quick-settings.sh"

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
rerun=$(echo sh $(find $commandPath  -name broker-quick-settings.sh | head -n 1))

if [ ! -z $1 ]
then
	serverProperties=$1
fi

execute() {
cd $(find $commandPath -name $1 | head -n 1 | sed 's/'$1'//')
gnome-terminal -- bash -c "sh $1 $serverProperties; exec bash"
}

repeat() {
	echo "Deseja configurar algum outro fator? [y] [n]"
	while [ $validator -eq 0 ]
	do
		read rawRes
		res=$(echo $rawRes | awk '{print tolower($0)}')
		case "$res" in
			"y")
				echo "Qual fator do broker será alterado?"
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


sh $(find $commandPath  -name broker-all-settings.sh | head -n 1) $serverProperties

echo "Qual fator do broker será alterado?"
echo "exemplo: broker-id"

validator=0
while [ $validator -eq 0 ]
do
	read rawChoice
	choice=$(echo $rawChoice | awk '{print tolower($0)}')
	case "$choice" in
		"broker-id")
			execute "server-id.sh"
			repeat
		;;
		
		"replication-factor")
			execute "default-replication-factor.sh"
			repeat
		;;
		
		"broker-address")
			execute "server-address.sh"
			repeat
		;;
		
		"broker-port")
			execute "server-port.sh"
			repeat
		;;
		
		"log-dir")
			execute "default-data-dir.sh"
			repeat
		;;
		
		"partition-number")
			execute "default-partition-number.sh"
			repeat
		;;
		
		"log-retention-time")
			execute "log-retention.sh"
			repeat
		;;
		
		"zookeeper-address")
			execute "zookeeper-address.sh"
			repeat
		;;
		
		"zookeeper-port")
			execute "zookeeper-port.sh"
			repeat
		;;
		
		*)
			echo "Fator inválido."
			validator=0;
		;;
	esac
done

if [ -z $1 ]
then
	cd $(find $commandPath -name broker-quick-settings.sh | head -n 1 | sed 's/broker-quick-settings.sh//')
	$rerun $serverProperties
fi
