#!/bin/bash
#
       ls -1 step* >& list

       while read line; do
             sed 's/\t/       /g' $line >& ${line}2
	     mv ${line}2 ${line}
	     chmod +x $line
       done < list


#
#   the end
#
