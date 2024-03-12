#include <stdio.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>

#define BUFSZ 5000

int char_comp_rev(const void *e1, const void *e2) {
    char ch1 = *((char *) e1);
    char ch2 = *((char *) e2);
    return ch2 - ch1;
}

int main(int argc, char *argv[]) {
	struct sockaddr_in sock_addr;
	
	int master_sock = socket(AF_INET, SOCK_STREAM, 0);

	inet_aton("127.0.0.1", &sock_addr.sin_addr);
	sock_addr.sin_port = htons(atoi(argv[1]));
	sock_addr.sin_family = AF_INET;

	bind(master_sock, (struct sockaddr *) &sock_addr, sizeof(sock_addr));

	listen(master_sock, 5);

	int client_sock = accept(master_sock, NULL, NULL);

	char buf[BUFSZ];
	
	int rc = read(client_sock, buf, BUFSZ);
	while (strncmp(buf, "OFF", 3) != 0) {
		qsort(buf, rc, sizeof(char), char_comp_rev);
		buf[rc] = '\0';
		write(client_sock, buf, rc);
		rc = read(client_sock, buf, BUFSZ);
	}
	
	close(master_sock);
	
	return 0;
}
