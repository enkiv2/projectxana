/+	unreal
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module unreal;

protected bool isUnreal=0;

//private extern (C) void unreal();

public void setUnreal() {
	if (!isUnreal) {
//		unreal();
		isUnreal=1;
	}
}
