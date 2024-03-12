#include <stdio.h>
#include <unistd.h>

int main() {
	daemon(0, 1);
	printf("%d\n", getpid());
	fclose(stdin);
	fclose(stdout);
	fclose(stderr);
	sleep(30);

	return 0;
}
