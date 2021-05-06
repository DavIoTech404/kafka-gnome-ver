commandPath=$(cat $1 | jq '.commandPath' | sed 's/"//g')
concat="config/default-settings.json"
if [ ! -f $commandPath$concat ]
then
	echo "Houve uma falha ao tentar localizar um dos arquivos, procurando os arquivos novamente e atualizando a base de dados do sistema."
	commandPath=$(find $HOME -name index-kafka.sh | grep -v Trash | head -n 1 | sed 's/index-kafka.sh//')
	sed '/\"commandPath\":/c\\"commandPath\": \"'$commandPath'\"' -i $1
	echo "Dados atualizados com sucesso."
fi

kafkaPath=$(cat $1 | jq '.kafkaPath' | sed 's/"//g')
concat="bin/kafka-server-start.sh"
if [ ! -f $kafkaPath$concat ]
then
	echo "Houve uma falha ao tentar localizar os arquivos do Kafka, procurando os arquivos novamente e atualizando a base de dados do sistema."
	kafkaPath=$(find $HOME -name kafka-server-start.sh | grep -v Trash | head -n 1 | sed 's/bin\/kafka-server-start.sh//')
	echo 
	sed '/\"kafkaPath\":/c\\"kafkaPath\": \"'$kafkaPath'\",' -i $1
	echo "Dados atualizados com sucesso."
fi
