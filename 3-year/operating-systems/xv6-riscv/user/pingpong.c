#include "kernel/types.h"
#include "user/user.h"

int
pingpong(void)
{
    /*
     * Pipe file descriptors
     * fd[0] -- read, fd[1] -- write
     * */
    int pipefd[2];
    int cpid;
    int bufsz = 4;
    char buf[bufsz];

    if (pipe(pipefd) == -1) {
        printf("pipe init error\n");
        return -1;
    }

    if ((cpid = fork()) == -1) {
        printf("fork error\n");
        return -1;
    }

    if (cpid == 0) {                            // Child process.
        read(pipefd[0], buf, bufsz);            // Read first message
        close(pipefd[0]);                       // and close fd for read.

        printf("%d got: %s\n", getpid(), buf);

        write(pipefd[1], "pong", bufsz);        // Write second message
        close(pipefd[1]);                       // and close fd for write.

        return 0;
    }

    else {                                      // Parent process,
        write(pipefd[1], "ping", bufsz);        // same logic as for child.
        close(pipefd[1]);                       // Except for here:
        wait(0);                                // we want to make sure child process has finished
                                                // before moving forward.
        read(pipefd[0], buf, bufsz);
        close(pipefd[0]);

        printf("%d got: %s\n", getpid(), buf);

        return 0;
    }

}

int
main(void)
{
    exit(pingpong());
}

