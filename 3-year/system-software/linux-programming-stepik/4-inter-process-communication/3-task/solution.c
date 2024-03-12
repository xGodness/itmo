#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

int sigusr1_cnt = 0;
int sigusr2_cnt = 0;

void sigusr1_handler(int sig) {
	sigusr1_cnt++;
}

void sigusr2_handler(int sig) {
	sigusr2_cnt++;
}

void sigterm_handler(int sig) {
	printf("%d %d\n", sigusr1_cnt, sigusr2_cnt);
	exit(0);
}

int main() {
	signal(SIGUSR1, sigusr1_handler);
	signal(SIGUSR2, sigusr2_handler);
	signal(SIGTERM, sigterm_handler);
	
	while (1);

	return 0;
}
