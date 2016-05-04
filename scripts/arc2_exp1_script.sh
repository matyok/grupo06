# arco2_exp1_script

# Experimento 1: sem replicação.

# Réplica primária ativa, réplica secundária desligada.

alias sshdbslave2='ssh ra137036@dbslave2'

RBE_CMD='java -Xmx8196m -cp /nfs/rbe/rbe.jar rbe.RBE'

for i in $(seq 1 1 3)
do
    echo "Iniciando run $i"
    echo; echo; echo;
    
    ## - Subir banco de dados primário
    echo "/===--- [Master Script]: subindo o banco primário ---===/"
    ssh ra137036@dbmaster2 'python dumpmaster.py'

    echo; echo; echo

    ## - Desligar banco de dados secundário
    echo "/===--- [Master Script]: desligando o banco secundário ---===/"
    ssh ra137036@dbslave2 'pg_ctlcluster 9.5 grupo06 stop -m fast'

    echo; echo; echo
    sudo service tomcat7 restart
    ## - Iniciar RBE
    echo "/===--- [Master Script]: Chamando o RBE ---===/"

    EB_VAL="rbe.EBTPCW"$i"Factory"

    cat /dev/null > "exp1/$EB_VAL"-summaries.txt

    for LOAD_VAL in $(seq 2000 1000 4000)
    do
        OUT_FILE="exp1/out-rbe-exp1-file${i}-load$LOAD_VAL.m"
        ssh ra137036@cbn7 "$RBE_CMD -EB $EB_VAL $LOAD_VAL -OUT $OUT_FILE -MAXERROR 0 -WWW http://cbn6.lab.ic.unicamp.br:8080/tpcw/ -RU 5 -MI 90 -RD 5 -DEBUG 10 > exp1/rbe_output${i}_load${LOAD_VAL}.txt"

#        ../rbe/analyze.py -a "../rbe/arc2/exp1/$EB_VAL"-summaries.txt -f "$i-$LOAD_VAL" $OUT_FILE
    done
done


