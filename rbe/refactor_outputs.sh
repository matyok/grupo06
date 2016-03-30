#!/bin/bash

for i in $(seq 3)
do
	awk -F" " 'BEGIN {x=100}; {print x" " $2; x += 100}' rbe.EBTPCW"$i"Factory-summaries.txt > plot_data_$i
done

gnuplot plot.gnuplot
