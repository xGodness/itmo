#include <stdio.h>

int main() {
	FILE *file = fopen("/proc/self/stat", "r");
	size_t ppid;

	fscanf(file, "%*d %*s %*c %lu", &ppid);
	
	printf("%lu\n", ppid);
	return 0;
}

