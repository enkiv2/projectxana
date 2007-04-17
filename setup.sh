#!/bin/sh

./clean.sh
./compile.sh
[[ -e bin/dnucleus.elf ]] && ./copy.sh && echo "Press return to test, ^c to exit" && read x && ./run.sh $@

