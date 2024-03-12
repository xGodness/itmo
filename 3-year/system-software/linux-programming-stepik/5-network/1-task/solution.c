#include <stdio.h>
#include <netdb.h>
#include <arpa/inet.h>

int main(int argc, char *argv[]) {
	struct hostent *host;
	host = gethostbyname(argv[1]);

	char **addr_list = host->h_addr_list;
	int i = 0;
	struct in_addr *addr;
	while (addr_list[i] != NULL) {
		addr = (struct in_addr *) addr_list[i++];
		printf("%s\n", inet_ntoa(*addr));
	}

	return 0;
}
