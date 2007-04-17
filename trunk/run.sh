#!/bin/sh

qemu -fda fd0.img -no-acpi -boot a $@
