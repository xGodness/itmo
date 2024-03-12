all:
	gcc solution.c -fPIC -ldl '-Wl,-rpath=.' -o solution

test: solution test.c test.h
	gcc -shared test.c -fPIC -o libtest.so
	./solution libtest.so testf 32

solution:
	gcc solution.c -fPIC -ldl '-Wl,-rpath=.' -o solution

clean:
	-rm libtest.so solution *.o 2>/dev/null
