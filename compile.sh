#!/bin/sh

echo "Compiling std"
for item in src/std/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -isystem src/ -o obj/std.${item##src/std/}.o -Isrc/internal -Isrc/ -Isrc/klib -Isrc/xulib -Isrc/std  src/object.d $item
done
echo "Compiling std.c"
for item in src/std/c/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -isystem src/ -o obj/std.c.${item##src/std/c/}.o -Isrc/internal -Isrc -Isrc/klib -Isrc/xulib -Isrc/std src/object.d $item
done
echo "Compiling std (stage2)"
for item in src/std/stage2/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -isystem src/ -o obj/${item##src/}.o -Isrc/internal -Isrc -Isrc/klib -Isrc/xulib -Isrc/std -Isrc/std/stage2 -Isrc/xulib/estage src/object.d $item
done
echo "Compiling std.c (stage2)"
for item in src/std/stage2/c/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -isystem src/ -o obj/std/stage2/c.${item##src/std/stage2/c/}.o -Isrc/internal -Isrc -Isrc/klib -Isrc/xulib -Isrc/std -Isrc/std/stage2 -Isrc/xulib/estage src/object.d $item
done
echo "Compiling internals"
for item in src/internal/*.d ; do
	echo -e "\tCompiling $item"
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -fversion=OCD -c -isystem src/ -nostdinc -U object -U Object -U TypeInfo -U object.Typeinfo -o obj/internal.${item##src/internal/}.o -Isrc/internal -Isrc/ -Isrc/klib -Isrc/xulib -Isrc/std src/object.d  $item
done
echo "Compiling c internals"
for item in src/internal/*.c ; do
	gcc -c -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -nostdinc -isystem src/ -o obj/internal.${item##src/internal/}.o -Isrc/internal $item
done
echo "Assembling internals (GAS)"
for item in src/internal/*.S ; do
	gcc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -nostdinc -c -o obj/internal.${item##src/internal/}.o $item
done
#echo "Assembling internals (nasm)"
#for item in src/internal/*.asm ; do
#	nasm -o obj/internal.${item##src/internal/}.o $item
#done
echo "Compiling typeinfos"
for item in src/typeinfo/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -isystem src/ -nostdinc -o obj/typeinfo.${item##src/typeinfo/}.o -Isrc/internal -Isrc/ -Isrc/klib -Isrc/xulib -Isrc/typeinfo src/object.d $item
done
echo "Compiling stage2 typeinfos"
for item in src/typeinfo/stage2/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -isystem src/ -nostdinc -o obj/${item##src}.o -Isrc/internal -Isrc/ -Isrc/klib -Isrc/xulib -Isrc/typeinfo -Isrc/typeinfo/stage2 -Isrc/std/stage2 -Isrc/std src/object.d $item
done
echo "Compiling klib"
for item in src/klib/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc  -o obj/klib.${item##src/klib/}.o -Isrc/xulib -Isrc/klib -Isrc/internal -Isrc/ -Isrc/std  src/object.d $item
done
echo "Compiling klib (c)"
for item in src/klib/*.c ; do
	gcc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -c -nostdinc -o obj/klib.${item##src/klib/}.o -Isrc/klib $item
done
echo "Compiling klib (asm/GAS)"
for item in src/klib/*.s ; do
	gcc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -c -nostdinc -o obj/klib.${item##src/klib/}.o -Isrc/klib $item
done
echo "Compiling klib (estage)"
for item in src/klib/estage/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -o obj/${item##src/}.o -Isrc/klib -Isrc/xulib -Isrc/internal -Isrc/klib/estage -Isrc/xulib/estage -Isrc/ src/object.d $item
done
echo "Compiling klib (gstage)"
for item in src/klib/gstage/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -o obj/klib.gstage.${item##src/klib/gstage/}.o -Isrc/klib -Isrc/xulib -Isrc/std -Isrc/internal -Isrc/ src/object.d $item
done
echo "Compiling xulib"
for item in src/xulib/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease  -c -nostdinc -U object -U Object -U TypeInfo -U object.Typeinfo -o obj/xulib.${item##src/xulib/}.o -Isrc/xulib -Isrc/klib -Isrc/internal -Isrc/  src/object.d $item
done
echo "Compiling xulib (estage)"
for item in src/xulib/estage/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -o obj/${item##src/}.o -Isrc/klib -Isrc/xulib -Isrc/internal -Isrc/klib/estage -Isrc/xulib/estage -Isrc/ src/object.d $item
done
echo "Compling xulib.stage2"
for item in src/xulib/stage2/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -o obj/${item##src/}.o -Isrc/xulib -Isrc/klib -Isrc/xulib/stage2  -Isrc/internal -Isrc/xulib/estage -Isrc/klib/estage -Isrc/ src/object.d $item
done
echo "Compiling Aileta"
for item in src/aileta/*.d ; do
	gdc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -frelease -c -nostdinc -o obj/aileta.${item##src/aileta/}.o -Isrc/xulib -Isrc/klib -Isrc/internal -Isrc/xulib/estage -Isrc/klib/estage -Isrc/ src/object.d $item
done
echo "Assembling gdt"
nasm -f elf -o obj/00gdt.o src/nucleus/i386/gdt.asm
echo "Assembling entry"
nasm -f elf -o obj/000entry.o src/nucleus/i386/entry.asm
echo "Assembling unreal"
nasm -f elf -o obj/unreal.o src/nucleus/i386/unreal.asm
echo "Assembling irq"
nasm -f elf -o obj/irq.o src/nucleus/i386/irq.asm
echo "Compiling kmain"
gdc -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -m386 -frelease -c -nostdinc -mno-tls-direct-seg-refs -o obj/00kmain.o -Isrc/xulib -Isrc/typeinfo -Isrc/klib  -Isrc/internal -Isrc/ -Isrc/xulib/estage -Isrc/klib/estage -Isrc/aileta src/object.d src/nucleus/nucleus.d
echo "Compiling math"
for item in src/libm/*.c ; do
	gcc -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -mno-tls-direct-seg-refs -c -nostdinc -Isrc/libm -o obj/math/stage2/${item##src/libm/}.o $item
done
echo "Assembling math"
for item in src/libm/i386/*.S ; do
	gcc -c -m386 -mno-mmx -mno-3dnow -mno-sse2 -mno-sse3 -mno-sse -nostdinc -Isrc/libm -o obj/math/stage2/asm.${item##src/libm/i386/}.o $item
done
echo "Compiling Lua core"
cd src/lua
make core
cd ../..
echo "Linking"
ld  -nostdlib -z muldefs  -static -Tlink.ld -o bin/dnucleus.elf obj/*.o obj/*/estage/*.o 

