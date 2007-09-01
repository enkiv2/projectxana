double udiv(int x, int y, int z) {
	x=y%z;
	double tmp= ((double)y)/z;
	if (tmp<0) {
		tmp=tmp*-1;
	}
	return tmp;
}
double div(int x, int y, int z) {
	x=y%z;
	return ((double)y)/z;
}
double umod(int x, int y, int z) {
	return (udiv(x, y, z));
}
