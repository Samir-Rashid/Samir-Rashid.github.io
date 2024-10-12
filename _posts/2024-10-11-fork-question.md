---
title: "Bug snack: `fork`s upon `fork`s"
permalink: /fork
# redirect_from:
  # - /10
date: 2024-10-11
tags:
  - bug snack
---

I wouldn't eat a cockroach. But this bug snack is quite delectable. This "bug" is a fun little puzzle to solve. I think this is an interesting question to discriminate OS programming experience across a wide range of skill levels.

{% include toc %}

<br>

# Part 1
## By inspecting the code, how many processes are created and how many times is `ls` run?

```c
#include <stdio.h>
#include <unistd.h>

int main (int argc, char *arg[])
{
    fork ();

    if (fork ()) {
      fork ();
    } else {
        char *argv[2] = {"/bin/ls", NULL};
        execv (argv[0], argv);
        fork ();
    }
}
```

<details markdown="1"> <summary><b>Reveal Answer</b></summary>

Let's trace the execution of this code snippet.

The initial `fork()` call creates a child process, resulting in two processes. Now there are two processes which proceed to the `if (fork())`. Note that `if (fork())` is equivalent to `if (fork() != 0)`. `fork` works by cloning the entire data of the process. `fork` returns to the parent process with the process ID (PID) of the child and returns in the child process with `0`.

Thus, there are now two processes which return inside the `if (fork())` with a return code `> 0` and two with return code `== 0`.
Two processes fall through to the `if` block and then `fork()`, creating two more processes.

The other two processes take the `else` block. The `execv()` call switches the process to `ls`. `execv` replaces the current process with the `ls` command, so no additional processes are created.

Therefore, a total of six processes are created, and the ls command is run twice.

![tree diagram of the processes created](/images/bug_snacks/fork-tree.png)

</details>

# Part 2
## What is the output of this program? How many times do you think "start" and "else" are printed?

```c
#include <stdio.h>
#include <unistd.h>

int main (int argc, char *arg[])
{
    printf("start");
    fork ();

    if (fork ()) {
      fork ();
    } else {
        char *argv[2] = {"/bin/ls", NULL};
        execv (argv[0], argv);
        printf("else");
        fork ();
    }
}
```

<details markdown="1"> <summary><b >Reveal Answer</b></summary>

Answer: `startstartstartstart` is printed and `else` is not printed. (`else` could be printed in a weird edge case where `execv` fails, say due to exhausted process space or `/bin/ls` not existing.)

```sh
$ ./a.out 
startstartstartstarta.out  main.c
a.out  main.c
```

</details>

# Part 3 
## With access to edit and run the code, explain this behavior.

<details markdown="1"> <summary><b >Reveal Answer</b></summary>

In short, the `printf` does not have a `\n`, so the buffer does not get flushed. Each fork clones the entire process (and its unflushed buffer). All of the forked process' buffers get printed to the console.

This bug is kind of interesting because the `execv` is a red herring. If you change that line to something like `return` or `exit` you get a different number of prints. Moreover, this is not a bug at all — it's the defined behavior of `fork`. This makes the behavior undebuggable with gdb.


<div class="commentary-author"><a href="https://cseweb.ucsd.edu/~voelker/" style="color:white;">Geoffrey M. Voelker</a></div>
<div class="commentary-body" markdown="1">

in Unix, output is controlled by the line mode (a part of a larger
subsystem called the line discipline). essentially the line mode has
two options, cooked and raw (yes, those are the names). in cooked
mode, for efficiency, output from `printf` is buffered in the process
until a newline, at which point the buffer gets printed. so
`printf("hi")` gets buffered, but `printf("hi\n")` gets immediately
printed. and cooked mode is the default. in raw mode, everything
gets printed immediately (even single characters).

since `printf("hi")` is buffered, when the program calls fork the child
also has `"hi"` in its buffer (and also their children). this
eventually results in multiple processes printing hi even though only
the original parent called `printf`.

in short, on Unix the newline matters.

for your original program, running `stty raw` in your shell before you
run the program should make it behave more like you expect it would.

</div>

Don't believe me? How can we test this? Tools like gdb and strace will not be of much use. To test this theory, we need to realize that the unbuffered text does not get magically printed by the shell.

It is [`libc` semantics](https://superuser.com/a/1288912) to flush the buffer on clean exit. This is not OS semantics, but the implementation of how `libc` exits. Of course, if you print with a newline then this problem will never arise.

</details>

---

Thanks to Anon. Calc and Professor Voelker.
