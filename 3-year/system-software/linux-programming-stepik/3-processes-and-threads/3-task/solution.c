#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
	char *pid = argv[1];	
	char path[32];
	FILE *file;
	size_t ppid;

	printf("%s\n", pid);
	while (strcmp(pid, "1")) {
		sprintf(path, "/proc/%s/stat", pid);
		file = fopen(path, "r");
		fscanf(file, "%*d %*s %*c %lu", &ppid);

		sprintf(pid, "%lu", ppid);
		printf("%s\n", pid);
	}

	return 0;
}

