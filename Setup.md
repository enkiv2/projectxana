# You will need #
  * A blank floppy
  * An x86 computer with a floppy drive
  * GCC ( http://gcc.gnu.org )
  * GDC ( http://dgcc.sf.net )
  * BASH/Bourne shell
  * dd
  * UNIX (for installation)
  * TAR


# Compiling #

1) Download a tarball of the XANA source. If you want the latest release (if there is one) use the downloads section of this site. If you want the latest buildable copy (recommended, for now), then download it from:
  * http://projectxana.twilightparadox.com/xana.tgz
  * http://hakware.oopsilon.com/xana/xana.tgz (mirror -- slow; use only if the first is down)

2) Expand it. This is done by:

> tar -xzf xana.tgz

3) Go into the xana/ directory.

4) If you want to just try out the build image, go to the next section. If you want to be able to modify anything, go on to the next step in this section.

5) Build the kernel. This is done by:

> ./clean.sh

> ./compile.sh



# Writing the image #

If your floppy drive is on /dev/fd0

> su -c "./copy.sh"

If your floppy drive is elsewhere, you will have to write it manually, by doing the following:

> dd if=./fd0.img of=/dev/fd0

> mount /media/floppy0

> cp ./bin/dnucleus.elf /media/floppy0

> cp ./menu.lst /media/floppy0/grub

> umount /media/floppy0

> dd if=/dev/fd0 of=./fd0.img

Note that /dev/fd0 is replaced by the path to your floppy device, and /media/floppy0 is replaced with the path to that device's mountpoint. Also, the last line is only necessary if you are going to be using the disk image for something else (for example, an emulator, or distribution).



# Running #

You can run XANA either on a computer (using the floppy you wrote to) or in an emulator. Different emulators require different steps to run a standard image (I will not list them here).

To try XANA on a computer, insert the floppy into the primary floppy drive of the computer you wish to run it on, and boot from the floppy. It doesn't do much at the time of this writing (pre 0.01 release), but it's nice to see that it does anything at all ;-).