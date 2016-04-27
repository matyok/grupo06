#!/bin/bash

alias sshdbslave2='ssh ra137036@dbslave2'

## - Subir banco de dados primário
echo "/===--- [Master Script]: subindo o banco primário ---===/"
ssh ra137036@dbmaster2 'python dumpmaster.py'

echo; echo; echo

## - Subir slave como secundário em hot standby
echo "/===--- [Master Script]: Subindo o secundário como hot standby ---===/"
ssh ra137036@dbslave2 'python reconf-dbslave.py'

echo; echo; echo

## - Iniciar RBE
echo "/===--- [Master Script]: Chamando o RBE ---===/"
java -Xmx8196m -cp /nfs/rbe/rbe.jar rbe.RBE -WWW http://localhost:8080/tpcw/ -RU 5 -MI 20 -RD 5 &

echo; echo; echo

echo "Time until shutting down primary... 15"
for i in $(seq 15)
do
	sleep 1
	echo "Time until shutting down primary... $[15-$i]"
done

## - Parar o primeiro banco
echo "/===--- [Master Script]: Parando o banco primário ---===/"
ssh ra137036@dbmaster2 'pg_ctlcluster 9.5 grupo06 stop -m fast'

echo; echo; echo

## - Promove o segundo banco a primário
echo "/===--- [Master Script]: Promovendo o segundo banco a primário ---===/"
ssh ra137036@dbslave2 'pg_ctlcluster 9.5 grupo06 promote'
