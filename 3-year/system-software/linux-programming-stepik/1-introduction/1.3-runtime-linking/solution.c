#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

int (*function)(int);

int main(int argc, char *argv[]) {
	char *funname = argv[2];
	int val;
	sscanf(argv[3], "%d", &val);

	void *hdl = dlopen(argv[1], RTLD_LAZY);
	function = (int (*)(int)) dlsym(hdl, funname);

	printf("%d\n", function(val));

	return 0;
}
