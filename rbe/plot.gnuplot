set terminal png size 1200,600 enhanced font "Helvetica,20"
set output 'plot_1_browsing.png'
plot 'plot_data_1' using 1:2 title "WIPS"
set output 'plot_2_shopping.png'
plot 'plot_data_2' using 1:2 title "WIPS"
set output 'plot_3_ordering.png'
plot 'plot_data_3' using 1:2 title "WIPS"

set output 'plot_all.png'
plot 'plot_data_1' using 1:2 title "Browsing", \
	'plot_data_2' using 1:2 title "Shopping", \
	'plot_data_3' using 1:2 title "Ordering"
