#!/bin/bash

max=15
format="%d"
fade=

if [ "$1" = "fade" ]; then
    fade=1
elif [ "$1" = "flash" ]; then
    fade=0
else
    echo "usage: $0 (fade|flash)"
    exit 1
fi

if [ "$fade" = "1" ]; then
    echo "FadeCurve:"
else
    echo "FlashCurve:"
fi

for y in `seq 0 $max`; do
    echo -ne "\tdc.b\t"
    for x in `seq 0 $max`; do
	if [ "$x" != "0" ]; then
	    echo -ne ","
	fi

	if [ "$fade" = "1" ]; then
	    printf "$format" "$(((x*y+max/2)/max))"
	else
	    printf "$format" "$((15-(x*(max-y)+max/2)/max))"
	fi
    done
    echo -ne "\n"
done
