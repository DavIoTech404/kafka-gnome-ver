configLocation="./config/default-settings.json"
currentScript="index-kafka.sh"

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

rerun=$(echo sh $currentScript)
json=$(cat ./config/menu-config.json)


    echo "##########################################################"
    echo "###############   O QUE DESEJA EXECUTAR?   ###############"
    echo "##########################################################"
    
    
for row in $(echo "${json}" | jq -r '.[] | @base64'); do
    currentRow() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    key=$(currentRow '.key')
    description=$(currentRow '.name')
    
    echo "[$key]$description "
done
    
	echo "##########################################################"
	echo ""
	read keyPressed

if [ "$keyPressed" = "exit" ]
then
       exit
fi

rawIndex=$(echo "${json}" | jq -r '.[] | select(.key=='\"$keyPressed\"') | .execute')


if [ -z "$keyPressed" ] | [ "$rawIndex" = "null" ] | [ -z "$rawIndex" ]
then
	echo "Operação inválida"
	echo ""
else

	command=$(echo $(echo $rawIndex | sed -r 's/sh //g'))

	if [ -z "${rawIndex##*sh*}" ]
	then
		echo "#### Executando $command #####"
		echo ""
		
		commandPath=$(cat $configLocation | jq '.commandPath' | sed 's/"//g')
		#executa o comando em outra terminal
		cd $(find $commandPath -name $command | head -n 1 | sed 's/'$command'//')
		gnome-terminal -- bash -c "sh $command; exec bash"
	
		cd $(find $commandPath -name index-kafka.sh | head -n 1 | sed 's/index-kafka.sh//')
	else
		echo "#### Executando $command #####"
		echo ""
	
		gnome-terminal -- bash -c "$command; exec bash"
	fi
fi
$rerun
