#!/bin/sh


if ps -x | grep '[x]inudox.pl'
then
  exit
else
  perl /home/xinudox/xinudox.pl -l -f -o &
fi


exit
