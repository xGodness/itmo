#include <stdio.h>
#include <string.h>

void count_genenv(char *pid, int *counter) {
	char path[32];
	char cpid[8];
	char procname[64];

	sprintf(path, "/proc/%s/stat", pid);
	FILE *file = fopen(path, "r");
	fscanf(file, "%*d %s", procname);
	fclose(file);
	
	if (!strcmp(procname, "(genenv)")) (*counter)++;

	sprintf(path, "/proc/%s/task/%s/children", pid, pid);
	file = fopen(path, "r");
	
	while (fscanf(file, "%s", cpid) != EOF) {
		count_genenv(cpid, counter);
	}

	fclose(file);
}

int main() {
	int counter = 0;
	count_genenv("1", &counter);
	printf("%d\n", counter);
}

