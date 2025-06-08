#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
  int a, b;

  a = atoi(argv[1]);
  b = atoi(argv[2]);

  // int c = a / b;

  if (b == 0) printf("oops!\n");

  // return c;
  return a / b; // Doing just this should trigger the bug via "time travel", but it does not
}
