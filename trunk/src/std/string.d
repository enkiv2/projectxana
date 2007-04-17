/+	std.string
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
module std.string;

import klib.string;

alias klib.string.compare strcmp;
alias strcmp cmp;

alias klib.string.toString toString;
/+
char[] toString(uint i) {
	return "";	//not implemented
}+/
char[] toString(int i) {
	char[] temp;
	if (i<0) {
		temp~="-";
		i*=-1;
	}
	return temp~toString(cast(uint)i);
}
char [] toString(long l) {
	return toString(cast(int)l);
}
char [] toString(ulong l) {
	return toString(cast(uint)l);
}
char[] toString(Object o) {
	return o.stringOf();
}
char[] toString(double d) {
	char[] temp=toString(cast(int) d);
	d-=cast(int) d;
	double td=10;
	while (d) {
		td*=10;
		d-=d*10;
	}
	return temp~toString(cast(int)d);
}
	
int find(char[] s, char c) {
	foreach (int i, char k; s) {
		if (k==c) {
			return i;
		}
	}
	return -1;
}
int find(char[] s, char[] s2) {
	foreach (int i, char k; s) {
		if (k==s[0]) {
			bool found=1;
			foreach (int i2, char k2; s2) {
				if (i2+i>=s.length) {
					return -1;
				}
				if (found&&s[i+i2]!=s2[i2]) {
					found=0;
				}
			}
			if (found) {
				return i;
			}
		}
	}
	return -1;
}
char[][] split(char[] s, char[] delim) {
	char[][]ret;
	int pos=find(s, delim);
	if (pos==-1) {
		ret[0]= s;
		return ret;
	}
	int i=0;
	char[] temp=s;
	while (pos!=-1) {
		ret[i]=temp[0 .. pos];
		i++;
		temp=temp[pos+delim.length .. length];
		pos=find(temp, delim);
	}
	ret[i]=temp;
	return ret;
}

char[][] split (char[] s, char delim) {
	char[] x;
	x[0]=delim;
	return split(s, x);
}

char[] replace(char[] s, char[] orig, char[] rep, int iter=0) {
	char[] temp=s;
	char[] ret;
	int pos=find(s, orig);
	if (pos==-1) {
		return s;
	}
	temp=s;
	int i=0;
	while (pos!=-1 && (iter==0|iter>=i)) {
		i++;
		ret~=temp[0 .. pos]~rep;
		temp=temp[pos+rep.length .. length];
	}
	ret~=temp;
	return ret;
}


