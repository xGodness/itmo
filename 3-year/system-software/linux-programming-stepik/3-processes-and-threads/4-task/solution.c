#include <stdio.h>

void count_children(char *pid, int *counter) {
	char path[32];
	char cpid[8];

	sprintf(path, "/proc/%s/task/%s/children", pid, pid);
	FILE *file = fopen(path, "r");
	
	while (fscanf(file, "%s", cpid) != EOF) {
		(*counter)++;
		count_children(cpid, counter);
	}
}

int main(int argc, char *argv[]) {
	int counter = 1;
	count_children(argv[1], &counter);
	printf("%d\n", counter);
}

