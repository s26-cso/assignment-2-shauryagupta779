#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

typedef int (*op_fn)(int, int);

int main(void) {
	char line[256];

	while (fgets(line, sizeof(line), stdin) != NULL) {
		char op[16];
		int a, b;

		if (sscanf(line, "%15s %d %d", op, &a, &b) != 3) {
			continue;
		}

		char libname[32];
		snprintf(libname, sizeof(libname), "./lib%s.so", op);

		dlerror();
		void *handle = dlopen(libname, RTLD_LAZY);
		if (!handle) {
			fprintf(stderr, "%s\n", dlerror());
			return 1;
		}

		dlerror();
		op_fn fn = (op_fn)dlsym(handle, op);
		char *err = dlerror();
		if (err != NULL || fn == NULL) {
			fprintf(stderr, "%s\n", err ? err : "symbol lookup failed");
			dlclose(handle);
			return 1;
		}

		int result = fn(a, b);
		printf("%d\n", result);

		dlclose(handle);
	}

	return 0;
}
