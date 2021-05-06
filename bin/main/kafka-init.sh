configLocation="../../config/default-settings.json"
currentScript="kafka-init.sh"

if [ ! -f "$configLocation" ]
then
	echo "Alterando o diretório de trabalho..."
	echo "[DICA]: para evitar lentidões e possíveis bugs na execução dos serviços, entre no diretório de trabalho do script."
	currentScriptDir=$(find $HOME -name $currentScript | grep -v Trash | head -n 1 | sed 's/'$currentScript'//')
	cd $currentScriptDir
fi
sh $(echo "$(echo $configLocation | awk -Fdefault-settings.json '{ print $1 }')dataVerifier.sh") $configLocation $currentScript
commandPath=$(cat $configLocation | jq '.commandPath' | sed 's/"//g')

echo "Iniciando Zookeeper..."
gnome-terminal -- bash -c "sh $(find $commandPath -name zookeeper.sh | head -n 1); exec bash" &&

echo "Iniciando Broker..."
gnome-terminal -- bash -c "sh $(find $commandPath -name broker-kafka.sh | head -n 1); exec bash" &&

echo "Criando tópicos..."
gnome-terminal -- bash -c "sh $(find $commandPath -name topic.sh | head -n 1); exec bash" &&

echo "Fim da rotina."
