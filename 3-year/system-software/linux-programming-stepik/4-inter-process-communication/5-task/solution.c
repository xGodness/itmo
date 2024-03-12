#include <sys/ipc.h>
#include <sys/shm.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
	key_t shm1_key = atoi(argv[1]);
	key_t shm2_key = atoi(argv[2]);

	key_t key = ftok(".", 'F');
	key_t shm3_id = shmget(key, 1000, 0666 | IPC_CREAT);
	key_t shm1_id = shmget(shm1_key, 1000, 0600 | IPC_CREAT);
	key_t shm2_id = shmget(shm2_key, 1000, 0600 | IPC_CREAT);

	int *shm1 = (int *) shmat(shm1_id, NULL, 0);
	int *shm2 = (int *) shmat(shm2_id, NULL, 0);
	int *shm3 = (int *) shmat(shm3_id, NULL, 0);

	int i;
	for (i = 0; i < 100; i++) {
		*shm3++ = *shm1++ + *shm2++;
	}

	printf("%d\n", key);

	return 0;
}
