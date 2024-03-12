#include <fcntl.h>
#include <stdio.h>
#include <sys/select.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
	int fds[2];
	char buf[4096];
	int i, rc, maxfd;
	fd_set watchset; 
	fd_set inset;
	int s = 0;

	fds[0] = open("in1", O_RDONLY | O_NONBLOCK);
	fds[1] = open("in2", O_RDONLY | O_NONBLOCK);

	FD_ZERO(&watchset);
	FD_SET(fds[0], &watchset);
	FD_SET(fds[1], &watchset);

	maxfd = fds[0] > fds[1] ? fds[0] : fds[1];

	while (FD_ISSET(fds[0], &watchset) || FD_ISSET(fds[1], &watchset)) {
		inset = watchset;
		select(maxfd + 1, &inset, NULL, NULL, NULL);

		for (i = 0; i < 2; i++) {
			if (FD_ISSET(fds[i], &inset )) {
		 		rc = read(fds[i], buf, sizeof (buf) - 1);
				
				if (rc == 0) {
					close(fds[i]);
					FD_CLR(fds[i], &watchset);
				} else if (rc > 0) {
					buf[rc] = '\0';
					s += atoi(buf);
				}
			}
		}
	}

	printf("%d\n", s);

	return 0;
}
