#include <stdio.h>
void main(int argc, char** argv) {
  if (argc < 2) {
    printf("hello: error with argc\n");
    return;
  }

	printf("hello, %s!\n", argv[1]);
}

