#!/bin/sh

echo "Put blank floppy in drive fd0 and press return"
read x
echo "Writing..."
dd of=/dev/fd0 if=./fd0.img
echo "Type the default mountpoint for fd0 (or return for /media/floppy0)"
read x
if [ "$x" == "" ]; then
	x="/media/floppy0"
fi
mount $x
rm ${x}/dnucleus.elf
rm ${x}/grub/menu.lst
cp menu.lst ${x}/grub/
cp ./bin/dnucleus.elf $x
umount $x
echo "Reading..."
dd of=./fd0.img if=/dev/fd0
echo "Done."

