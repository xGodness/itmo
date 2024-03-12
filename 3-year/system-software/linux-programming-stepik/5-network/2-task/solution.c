#include <stdio.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>

#define BUFSZ 5000

int main(int argc, char *argv[]) {
	struct sockaddr_in sock_addr;
	int sock = socket(AF_INET, SOCK_DGRAM, 0);

	inet_aton("127.0.0.1", &sock_addr.sin_addr);
	sock_addr.sin_port = htons(atoi(argv[1]));
	sock_addr.sin_family = AF_INET;

	bind(sock, (struct sockaddr *) &sock_addr, sizeof(sock_addr));

	char buf[BUFSZ];
	
	int rc = read(sock, buf, BUFSZ);
	buf[rc] = '\0';
	while (strncmp(buf, "OFF\n", 4) != 0) {
		printf("%s\n", buf);
		rc = read(sock, buf, BUFSZ);
		buf[rc] = '\0';
	}

	return 0;
}
