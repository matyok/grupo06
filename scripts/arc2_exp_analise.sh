echo $1
for FILE in $(seq 1 1 3 )
	do
		for LOAD_VAL in $(seq 2000 1000 4000)
			do
			sudo python ../rbe/analyze.py -f ../rbe/arc2/exp${1}/analise/run${FILE}_${LOAD_VAL} ../rbe/arc2/exp${1}/out-rbe-exp2-file${FILE}-load${LOAD_VAL}.m 
    			done
	done
