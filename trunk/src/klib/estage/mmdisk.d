/+	mmdisk
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module mmdisk;

import Port;

public static const ubyte ENFS_PARTITION_CODE=0x30;

const ushort MAX_CYLINDERS=65535;
const ushort HEADS_PER_CYLINDER=16;
const ushort SECTORS_PER_TRACK=255;

const ushort DRIVE_AND_HEAD_PORT=0x1f6;
const ushort SECTOR_COUNT_PORT=0x1f2;
const ushort SECTOR_NUMBER_PORT=0x1f3;
const ushort CYLINDER_LOW_PORT=0x1f4;
const ushort CYLINDER_HIGH_PORT=0x1f5;
const ushort COMMAND_PORT=0x1f7;
const ushort STATUS_PORT=0x1f7;

const ushort DATA_PORT=0x1f0;

const ushort COMMAND_READ_WITH_RETRY=0x20;
const ushort COMMAND_WRITE_WITH_RETRY=0x30;

alias ulong LBA;

void[] HD_readd(ushort drive, ushort head, ulong cylinder, ushort sector, ushort len, ushort start=0) {
	ubyte[] buf;
	ubyte temp;
	outByte(DRIVE_AND_HEAD_PORT, cast(ubyte)((drive<<4)|head));
	outByte(SECTOR_COUNT_PORT, cast(ubyte)len);
	outByte(SECTOR_NUMBER_PORT, cast(ubyte)sector);
	outByte(CYLINDER_LOW_PORT, (cast(ubyte)cylinder));
	outByte(CYLINDER_HIGH_PORT, (cast(ubyte)(cylinder>>8)));
	outByte(COMMAND_PORT, COMMAND_READ_WITH_RETRY);
	for (int i=0; i<start; i++) {
		while (inWord(COMMAND_PORT)&255) {}
		inByte(DATA_PORT);
	}
	for (int i=0; i<len; i++) {
		while (inWord(COMMAND_PORT)&255){}
		temp=inByte(DATA_PORT);
		if (!(inWord(STATUS_PORT)&1)) {
			buf~=temp;
		}
	}
	return cast(void[]) buf;
}

int HD_writed(ushort drive, ushort head, ulong cylinder, ushort sector, void[] data) {
	int i=0;
	outByte(DRIVE_AND_HEAD_PORT, cast(ubyte)((drive<<4)|head));
	outByte(SECTOR_COUNT_PORT, cast(ubyte)data.length);
	outByte(SECTOR_NUMBER_PORT, cast(ubyte)sector);
	outByte(CYLINDER_LOW_PORT, (cast(ubyte) cylinder));
	outByte(CYLINDER_HIGH_PORT, (cast(ubyte)(cylinder>>8)));
	outByte(COMMAND_PORT, COMMAND_WRITE_WITH_RETRY);
	for (i=0; i<data.length; i++) {
		while (inByte(COMMAND_PORT)&255) {}
		outByte(DATA_PORT, cast(ubyte)data[i]);
		if (inByte(STATUS_PORT)&1) { return -1; }
	}
	return 0;
}

int HD_write(ushort drive, LBA lba, void[] data, ushort start_head=0, ushort end_head=HEADS_PER_CYLINDER, ushort start_cylinder=0, ushort end_cylinder=MAX_CYLINDERS, ushort start_sector=0, ushort end_sector=SECTORS_PER_TRACK) {
	ushort head;
	ushort cylinder;
	ushort sector;
	lba2chs (lba/512, head, cylinder, sector);
	ushort start=((lba/MAX_CYLINDERS)/HEADS_PER_CYLINDER)%512;
	head+=start_head;
	cylinder+=start_cylinder;
	sector+=start_sector;
	if (head<=end_head && cylinder <= end_cylinder && sector <= end_sector) {
		void[] temp=HD_readd(drive, head, cylinder, sector, 512);
		temp[start .. start+data.length]=data;
		return HD_writed (drive, head, cylinder, sector, temp);
	}
	return -1;
}

void[] HD_read(ushort drive, LBA lba, ushort len, ushort start_head=0, ushort end_head=HEADS_PER_CYLINDER, ushort start_cylinder=0, ushort end_cylinder=MAX_CYLINDERS, ushort start_sector=0, ushort end_sector=SECTORS_PER_TRACK) {
	ushort head;
	ushort cylinder;
	ushort sector;
	lba2chs (lba/512, head, cylinder, sector);
	ushort start=((lba/MAX_CYLINDERS)/HEADS_PER_CYLINDER)%512;
	head+=start_head;
	cylinder+=start_cylinder;
	sector+=start_sector;
	if (head <= end_head && cylinder <= end_cylinder && sector <= end_sector) {
		return HD_readd(drive, head, cylinder, sector, len)[start .. start+length];
	}
	ubyte[] x;
	return x;
}

LBA chs2lba(ushort head, ushort cylinder, ushort sector) {
	return (((cylinder * HEADS_PER_CYLINDER + head) * SECTORS_PER_TRACK) + sector) -1;
}

void lba2chs (in LBA lba, out ushort head, out ushort cylinder, out ushort sector) {
	cylinder=lba/(HEADS_PER_CYLINDER * SECTORS_PER_TRACK);
	ushort temp=lba%(HEADS_PER_CYLINDER * SECTORS_PER_TRACK);
	head=temp/SECTORS_PER_TRACK;
	sector=temp%SECTORS_PER_TRACK + 1;
}

struct MMDisk {
	ulong size;
	ubyte drive=0x0a;
	ulong len;
	void init() {
		len=size;
	}
	void* opIndex(ulong i) {
		if (i>size) {
			return null;
		}
		return &(HD_read(drive, i, 1)[0]);
	}
	void opIndexApply(ubyte value, ulong i) {
		if (i<=size) {
			ubyte[] temp;
			temp[0]=value;
			HD_write(drive, i, temp);
		}
	}
	void[] opSlice(ulong start, ulong end) {
		return HD_read(drive, start, end-start);
	}
	void opSliceAssign(void[] value, ulong start, ulong end) {
		if ((end-start)!=value.length) {
			HD_write(drive,start+value.length, HD_read(drive, start, value.length+(size-(end-start))-start)); // Move stuff over
		}
		HD_write(drive, start, value);
	}
	void opSliceAssign(void[] value) {
		opSliceAssign(value, 0, size);
	}
}

struct MMPart {
	ulong size;
	ubyte drive=0x0a;
	ushort partnumber=0; // 0-3
	bool bootable;
	ulong start_cylinder;
	ubyte start_sector;
	ulong end_cylinder;
	ubyte end_sector;
	ubyte start_head;
	ubyte end_head;
	ubyte fs_type;
	ulong len;
	void init() {
		bootable=((cast(ubyte)HD_read(drive, 446, 1)[0])==0x80);
		start_head=(cast(ubyte[])HD_read(drive, 446+1, 1))[0];
		end_head=(cast(ubyte[])HD_read(drive, 446+5, 1))[0];
		ubyte[] temp=cast(ubyte[])(HD_read(drive, 446+2, 2));
		temp~=cast(ubyte[])(HD_read(drive, 446+6, 2));
		start_cylinder=(((cast(ushort)temp[0])<<8)|(cast(ushort)temp[1]));
		start_sector=(temp[0]&0x1F);
		end_cylinder=(((cast(ushort)temp[2])<<8)|(cast(ushort)temp[3]));
		end_sector=(temp[2]&0x1F);
		fs_type=(cast(ubyte[])HD_read(drive, 446+4, 1))[0];
		len=size;
	}
	void* opIndex(ulong i) {
		return &(HD_read(drive, i, 1, start_head, end_head, start_cylinder, end_cylinder, start_sector, end_sector)[0]);
	}
	void opIndexApply(ubyte value, ulong i) {
		ubyte[] temp;
		temp[0]=value;
		HD_write(drive, i, cast(void[])temp, start_head, end_head, start_cylinder, end_cylinder, start_sector, end_sector);
	}
	void[] opSlice(ulong start, ulong end) {
		return HD_read(drive, start, end-start, start_head, end_head, start_cylinder, end_cylinder, start_sector, end_sector);
	}
	void opSliceAssign(void[] value, ulong start, ulong end) {
		if ((end-start) != value.length) {
			HD_write(drive, start+value.length, HD_read(drive, start, value.length+(size-(end-start)+start), start_head, end_head, start_cylinder, end_cylinder, start_sector, end_sector), start_head, end_head, start_cylinder, end_cylinder, start_sector, end_sector);
		}
		HD_write(drive, start, value, start_head, end_head, start_cylinder, end_cylinder, start_sector, end_sector);
	}
	void opSliceAssign(void[] value) {
		opSliceAssign(value, 0, size);
	}
}

