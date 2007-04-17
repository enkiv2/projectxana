int pow(int x, int y) {
	int ax=y;
	for (int i=0; i<x-1, i++) {
		ax*=y;
	}
	return ax;
}
