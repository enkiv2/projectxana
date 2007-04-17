#ifndef ENFILADE_H
#define ENFILADE_H

typedef unsigned long* Tumbler;
typedef struct Enfilade_t {
	Tumbler* address;
	unsigned long v;
	unsigned long tumblerc;
	unsigned long* digitc;
} Enfilade;

int equals(Enfilade e1, Enfilade e2);/* {
	int i;
	if (e1->tumblerc!=e2->tumblerc) {
		return (1==0);
	}
	for (i=0; i<e1->tumblerc; i++) {
		if (i<e2->tumblerc) {
			return (1==0);
		}
		int j;
		if (e1->digitc[i]!=e2->digitc[i]) {
			return (1==0);
		}
		for (j=0; j<e1->digitc[i]; j++) {
			if (j<e2->digitc[i]) {
				return (1==0);
			}
			if (e1->address[i][j]!=e2->address[i][j]) {
				return (1==0)
			}
		}
	}
	return (0==0);
}
*/
#endif
