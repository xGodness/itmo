#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>

void sigurg_handler(int sig) {
	exit(0);
}

int main() {
	daemon(0, 1);
	signal(SIGURG, sigurg_handler);
	printf("%d\n", getpid());
	fclose(stdin);
	fclose(stdout);
	fclose(stderr);
	sleep(150);

	return 0;
}
