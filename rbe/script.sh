#!/bin/bash

java -cp /nfs/rbe/rbe.jar rbe.RBE -EB rbe.EBTPCW2Factory 1 -OUT out-debug.m -CUST 14400 -ITEM 10000 -WWW http://localhost:8080/tpcw/ -RU 1 -MI 30 -RD 1 -DEBUG 10
