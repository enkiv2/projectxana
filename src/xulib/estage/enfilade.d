/+	enfilade.d
 +	(c) 2007 John Ohno
 +	Licensed under the GNU LGPL
 +	Part of Project XANA
 +/
import std.stdint;
import std.string;

typedef uint64_t[uint64_t] Tumbler;
struct Enfilade {
	Tumbler[uint64_t] address;
	uint64_t v;
	
	Tumbler opIndex(uint64_t i) {
		if (i<this.address.length) {
			return address[i];
		}
		if (i==this.address.length) {
			Tumbler tmp;
			tmp[1]=v;
			return tmp;
		}
		Tumbler tmp;
		return tmp;
	}
	hash_t toHash () {
		uint64_t x=1;
		foreach (Tumbler t; address) {
			foreach (uint64_t i; t) {
				x/=2*(x+i);
			}
			x*=7;
		}
		return x/(2*(x+v));
	}
	int opEquals (Enfilade e) {
		return ((e.address==address) && (e.v==v));
	}
	int opCmp (Enfilade e) {
		if (e.address==this.address) {
			return this.v > e.v;
		}
		return this.address > e.address;
	}
	Enfilade opAdd (Enfilade e) {
		Enfilade tmp;
		foreach (uint64_t i, Tumbler t; e.address) {
			Tumbler tmp2;
			Tumbler addrcopy;
			if (i<this.address.length) {
				addrcopy=this.address[i];
			}
			foreach (uint64_t j, uint64_t val; t) {
				if (j<addrcopy.length) {
					tmp2[j]=val+addrcopy[j];
				} else {
					tmp2[j]=val;
				}
			}
			tmp.address[i]=tmp2;
		}
		tmp.v=e.v+this.v;
		return tmp;
	}
	void opAddAssign (Enfilade e) {
		Enfilade tmp=opAdd(e);
		this.address=tmp.address;
		this.v=tmp.v;
	}
	Enfilade opCat (Tumbler t) {
		Enfilade tmp;
		uint64_t i=1;
		foreach (Tumbler t2; this.address) {
			tmp.address[i]=t2;
			i++;
		}
		tmp.address[i]=t;
		return tmp;
	}
	Enfilade opCat (Enfilade e) {
		Enfilade tmp;
		foreach (Tumbler t; this.address) {
			tmp~=t;
		}
		foreach (Tumbler t; e.address) {
			tmp~=t;
		}
		return tmp;
	}
	Enfilade opCat (uint64_t i) {
		Tumbler t;
		t[1]=i;
		Enfilade tmp;
		tmp.address=this.address;
		tmp.v=this.v;
		return tmp~t;
	}
	Enfilade opCatAssign (Enfilade e) {
		Enfilade tmp;
		tmp.address=this.address;
		tmp.v=this.v;
		tmp=tmp~e;
		this.address=tmp.address;
		this.v=tmp.v;
		return tmp;
	}
	Enfilade opCatAssign (uint64_t i) {
		Enfilade tmp;
		tmp.address=this.address;
		tmp.v=this.v;
		tmp=tmp~i;
		this.address=tmp.address;
		this.v=tmp.v;
		return tmp;
	}
	Enfilade opCatAssign (Tumbler t) {
		Enfilade tmp;
		tmp.address=this.address;
		tmp.v=this.v;
		tmp=tmp~t;
		this.address=tmp.address;
		this.v=tmp.v;
		return tmp;
	}
	Enfilade[] opShr (Enfilade e) {
		Enfilade[] ret;
		foreach (uint64_t i, Tumbler t; e.address) {
			foreach (uint64_t j, uint64_t n; t) {
				uint64_t ax;
				if (i<this.address.length && j<this.address[i].length) {
					ax=this.address[i][j];
				} else {
					ax=1;
				}
				for (ax=ax; ax<e.address[i][j]; ax++) {
					Enfilade tmp;
					for (int i2=1; i2<e.address.length; i2++) {
						Tumbler tmp2;
						for (int j2=1; j2<e.address[i].length; j2++) {
							if (i==i2&&j==j2) {
								tmp2[j]=ax;
							} else {
								if (i<this.address.length && j<this.address[i].length) {
									tmp2[j]=this.address[i][j];
								}
							}
						}
						tmp~=tmp2;
					}
					ret~=tmp;
				}
			}
		}
		return ret;
	}
	int opApply (int delegate(inout uint64_t, inout Tumbler) dg) {
		int result;
		foreach (uint64_t i, Tumbler t; this.address) {
			result=dg(i, t);
			if(result) {
				break;
			}
		}
		return result;
	}
	int opApply (int delegate(inout Tumbler) dg) {
		int result;
		foreach (Tumbler t; this.address) {
			result=dg(t);
			if(result) {
				break;
			}
		}
		return result;
	}
	char[] stringOf() {
		char[] temp;
		foreach (Tumbler t; this.address) {
			foreach (uint64_t i; t) {
				temp~=toString(i)~".";
			}
			temp~="0.";
		}
		temp=temp[0 .. length-3];
		if (this.v!=0) {
			temp~="v"~toString(this.v);
		}
		return temp;
	}
}

char[] enfiladeSerialize(Enfilade x) {
	return x.stringOf();
}

