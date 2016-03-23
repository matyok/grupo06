#!/usr/bin/python

import sys
from optparse import OptionParser
from math import sqrt

usage = "Usage: %prog [OPTIONS] <data files>\nTry --help for more help."
description = ("Processes and analyzes data produced by a single run" +
               " of the TPC-W RBE. Data comes from the Matlab" +
               " files produced by all nodes. The final result is" + 
               " a time histogram (and associated GnuPlot files) and" +
               " a summary file that can be further analyzed.")
parser = OptionParser(usage=usage, description=description)
parser.disable_interspersed_args()
parser.add_option("-s", "--span", type="int", default=1,
            metavar="TIME",
            help="Sets the time span for the histogram in seconds." +
                 " Default: %default")
parser.add_option("-t", "--trim", action="store_true", default=False,
            help="Trims off the ramp up and ramp down times." +
                 " Default: %default")
parser.add_option("-b", "--begin", type="int", default=0,
            metavar="TIME",
            help="Sets the time point to begin the histogram in seconds." +
                 " Default: %default")
parser.add_option("-e", "--end", type="int",
            metavar="TIME",
            help="Sets the amount of time to include in the histogram in" +
                 " seconds. Default: all time, respecting trim.")
parser.add_option("-f", "--file-prefix", type="str", default="tpcw-run",
            metavar="PREFIX",
            help="Sets a prefix for the name of the files created" +
                 " including the path. Default: %default")
parser.add_option("-d", "--data-index", type=int, default=0,
            metavar="INDEX",
            help="Sets an index for the summary data line." +
                 " Default: %default")
parser.add_option("-a", "--append-summary", type="str",
            metavar="FILE",
            help="Appends the summary data line created to FILE, instead of" +
                 " creating a .summary file. Default: %default")

(options, args) = parser.parse_args()

if options.span < 1:
    parser.error("time span must be positive")
if len(args) == 0:
    parser.error("data files missing")


rtimes = {}
intervals = {}
span = options.span

def get_interval(n):
    if n in intervals:
        return intervals[n]
    return 0


for arg in args:
    file = open(arg)

    wirt_started = 0
    wirt_paused = 0
    wirt_finished = 0
    wips_started = 0
    wips_finished = 0
    i = 0
    i_max = 0

    for linha in file:
        if not wirt_started:
            if linha[0] == '%':
                type = linha.split()[1]
                value = linha.split()[-1]
                if type == '-RU':
                    if options.trim:
                        i -= int(value)
                    else:
                        i_max += int(value)
                if type == '-MI':
                    i_max += int(value)
                if type == '-RD':
                    if not options.trim:
                        i_max += int(value)
                    i -= options.begin
                    i_max -= options.begin
                    if options.end != None and i_max > options.end:
                        i_max = options.end
            else:
                wirt_started = linha[:8] == 'dat.wirt'
        elif wirt_finished < 15:
            if wirt_paused:
                wirt_paused = linha[-6:-1] != 'h = ['
            elif linha[:2] == '];':
                wirt_paused = 1
                wirt_finished += 1
            else:
                rt = int(linha.split()[0])
                count = int(linha.split()[1])
                if count != 0:
                    if rt in rtimes:
                        rtimes[rt] += count
                    else:
                        rtimes[rt] = count
        elif not wips_started:
            if linha[:8] == 'dat.wips':
                wips_started = 1
        elif not wips_finished:
            if linha[:2] == '];':
                wips_finished = 1
            elif i >= 0 and i < i_max:
                start = i / span
                interval = get_interval(start)
                interval += int(linha)
                intervals[start] = interval
            i += 1


if len(rtimes) > 0:
    keys = rtimes.keys()
    keys.sort()
    first = keys[0]
    count = rtimes[first]
    avrg_wirt = first
    sum = 0
    i = count
    for rt in keys[1:]:
        count = rtimes[rt]
        new_avrg = avrg_wirt + ((rt - avrg_wirt) / float(i + count)) * count
        sum += (rt - avrg_wirt) * (rt - avrg_wirt) * count
        avrg_wirt = new_avrg
        i += count
    stddev_wirt = sqrt(sum / float(i - 1))


if len(intervals) > 0:
    histogram_file = options.file_prefix + ".histogram"
    file = open(histogram_file, "w")
    keys = intervals.keys()
    keys.sort()
    first = keys[0]
    interval = intervals[first]
    total_wi = interval
    avrg_wips = interval / float(span)
    sum = 0
    i = 1
    print >>file, first * span, avrg_wips
    for start in keys[1:]:
        interval = intervals[start]
        total_wi += interval
        interval /= float(span)
        new_avrg = avrg_wips + (interval - avrg_wips) / float(i + 1)
        sum += (interval - avrg_wips) * (interval - avrg_wips)
        avrg_wips = new_avrg
        print >>file, start * span, interval
        i += 1
    stddev_wips = sqrt(sum / float(i - 1))
    file.close()

    file = open(options.file_prefix + ".plot", "w")
    print >>file, 'plot "' + histogram_file + '" using 1:2 title "WIPS" with lines'
    file.close()


print total_wi, "operations completed in", i_max, "seconds"
print "Average WIPS:", avrg_wips, "stddev:", stddev_wips
print "Average WIRT:", avrg_wirt, "stddev:", stddev_wirt

if options.append_summary == None:
    file = open(options.file_prefix + ".summary", "w")
else:
    file = open(options.append_summary, "a")
print >>file, options.data_index, avrg_wips, avrg_wirt
file.close()
