set terminal png size 1200,600 enhanced font "Helvetica,20"
set output 'teste.png'
set xlabel 'Number of Customers'
set ylabel 'WIPS'
plot 'tpcw-run.histogram' using 1:2 title "Browsing" pt 6 ps 2

