#!/bin/sh

[[ -e ./setup_input.txt ]] || echo -e "\n\n" > ./setup_input.txt

cat ./setup_input.txt | ./setup.sh

