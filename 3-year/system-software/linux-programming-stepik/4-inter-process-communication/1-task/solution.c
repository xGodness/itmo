#include <stdio.h>

int main(int argc, char *argv[]) {
	char call_arg[128];
	sprintf(call_arg, "%s %s", argv[1], argv[2]);
	
	FILE *f = popen(call_arg, "r");

	char c = fgetc(f);
	int counter = 0;
	while (c != EOF) {
		if (c == '0') counter++;
		c = fgetc(f);
	}

	pclose(f);
	
	printf("%d\n", counter);

	return 0;
}
