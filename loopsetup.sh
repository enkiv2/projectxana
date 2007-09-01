./clean.sh
./compile.sh

[[ -e bin/dnucleus.elf ]] && ./loopcopy.sh && echo "Press return to test, ^c to ext" && read x && ./run.sh $@

