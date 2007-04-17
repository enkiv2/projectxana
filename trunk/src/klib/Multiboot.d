/+	ocd.klib.Multiboot
 +	(c) 2007 Alexander Panek
 +	Licensed under the ZLIB license
 +	Part of Project XANA
 +/
module ocd.klib.multiboot;

const uint pageAlign   = 1 << 0;
const uint memoryInfo  = 1 << 1;
const uint headerMagic = 0x1badb002;
const uint headerFlags = pageAlign | memoryInfo;
const uint checkSum    = -(headerMagic + headerFlags);

struct MultibootHeader {
	align(4) uint magic = headerMagic,
		          flags = headerFlags,
		          checksum = checkSum;
/+
	static MultibootHeader opCall ( uint m, uint f, uint c ) {
		MultibootHeader header;

		header.magic    = m;
		header.flags    = f;
		header.checksum = c;

		return header;
	}
+/
}

struct MultibootInfo {
	uint flags,
		 mem_lower,
		 mem_upper,
		 boot_device,
		 cmdline,
		 mods_count,
		 mods_addr,
		 mmap_len,
		 mmap_addr;
}

static MultibootInfo theMultiboot;
