#!/bin/sh

mount ./fd0.img ./mnt -o loop

rm ./mnt/dnucleus.elf
rm ./mnt/grub/menu.lst
cp ./menu.lst ./mnt/grub/
cp ./bin/dnucleus.elf ./mnt/

umount ./mnt

