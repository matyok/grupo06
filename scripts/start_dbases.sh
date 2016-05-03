#!/bin/bash

ssh ra137036@dbmaster2 'python dumpmaster.py'
ssh ra137036@dbslave2 'python reconf-dbslave.py'
