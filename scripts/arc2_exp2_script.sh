# arco2_exp2_script

# Experimento 1: sem replicação.

# Réplica primária ativa, réplica secundária desligada.

alias sshdbslave2='ssh ra137036@dbslave2'

RBE_CMD='java -Xmx8196m -cp /nfs/rbe/rbe.jar rbe.RBE'

#i = 3

for i in $(seq 1 1 3)
do
    echo "Iniciando run $i"
    echo; echo; echo;
    
    ### Restartando o tomcat
   # echo "Reiniciando tomcat"
   # sudo service tomcat7 restart

    echo; echo; echo;
    ## - Subir banco de dados primário
    echo "/===--- [Master Script]: subindo o banco primário ---===/"
    ssh ra137036@dbmaster2 'python dumpmaster.py'

    echo; echo; echo

    ## - Desligar banco de dados secundário
    echo "/===--- [Master Script]: Reconfigurando o banco secundário ---===/"
    ssh ra137036@dbslave2 './reconfslave.sh'

    sudo service tomcat7 restart

    echo; echo; echo

    ## - Iniciar RBE
    echo "/===--- [Master Script]: Chamando o RBE ---===/"

    EB_VAL="rbe.EBTPCW${i}Factory"

   # cat /dev/null > "exp2/$EB_VAL"-summaries.txt

    for LOAD_VAL in $(seq 2000 1000 4000)
    do
        OUT_FILE="exp2/out-rbe-exp2-file${i}-load$LOAD_VAL.m"
        ssh ra137036@cbn7 "$RBE_CMD -EB $EB_VAL $LOAD_VAL -OUT $OUT_FILE -MAXERROR 0 -WWW http://cbn6.lab.ic.unicamp.br:8080/tpcw/ -RU 5 -MI 90 -RD 5 > exp2/rbe_output${i}_load${LOAD_VAL}.txt"

    done
done


