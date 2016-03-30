#!/bin/bash

#java -cp /nfs/rbe/rbe.jar rbe.RBE -EB rbe.EBTPCW2Factory 1 -OUT out-debug.m -CUST 14400 -ITEM 10000 -WWW http://localhost:8080/tpcw/ -RU 1 -MI 30 -RD 1 -DEBUG 10

#-EB parameters used:
#	rbe.EBTPCW1Factory		Browsing Mix
#	rbe.EBTPCW2Factory		Shopping Mix
#	rbe.EBTPCW3Factory		Ordering Mix
#
#-CUST is the parameter used for defining the number of simulated customers

RBE_CMD='java -cp /nfs/rbe/rbe.jar rbe.RBE'

cat /dev/null > all_outputs.txt

for i in $(seq 3)
do
	EB_VAL="rbe.EBTPCW"$i"Factory"
	echo $EB_VAL

	for LOAD_VAL in $(seq 100 100 4000)
	do
		OUT_FILE="out-rbe$i-cust$CUST_VAL.out"
		$RBE_CMD -EB $EB_VAL $LOAD_VAL -OUT $OUT_FILE -WWW http://localhost:8080/tpcw/ -RU 5 -MI 30 -RD 5 -DEBUG 10 >> all_outputs.txt

		./analyze.py -a "$EB_VAL"-summaries.txt -f "$i-$LOAD_VAL" $OUT_FILE
	done
done

./refactor_outputs.sh
