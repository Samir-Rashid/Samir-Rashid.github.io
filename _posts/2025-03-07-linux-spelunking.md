---
title: "Linux Spelunking: How are processes loaded?"
permalink: /process-loading/
date: 2025-03-07
tags:
  - research
---

# Outline

TODO: verbiage review with hemingwayapp. Writing is too informal/flowery/not simple words

TODO: who is this post for? write intro explaining background needed

TODO: redo without nix store

# Linux Spelunking: How are processes loaded? How would I figure it out?

Let's journey into Linux to find out how programs are loaded.
Building new systems requires you to understand how the current system actually works — not how it works according to the documentation.
This post is meant for people who want to learn more about kernel internals but have been hesitating to dive in for themselves.
We will explore how to deal with ambiguity and come out with an understanding for the exact actions Linux takes when loading a realistic program.

> **Goal**: How does Linux load a program?

The first thing you may note is that this question is a bit odd. There are several interpretations for what it means to "load a program".
This is a good point. However, a priori, I cannot know what the correct question to ask is.
Our journey will start assuming only basic C knowledge and become more complex. We will learn about Linux and its internal mechanisms from scratch.

{% include toc %}

<br>

We have to step in any direction to get started.
The results of each experiment will allow us to keep iterating, refining our questions, and learn new concepts.

On first blush, the question seems obvious. Running a program simply means going to the first instruction and running in order until the end. Let's test this theory.

## Load a program

Let's try running a simple program and inspect what it is doing.

[`nautilus`](https://apps.gnome.org/Nautilus/) is the file explorer application that ships with GNOME.
We want to know what Linux is doing when nautilus starts. It would be neat if there was a way to see every call into Linux.
Luckily, there is a tool called `strace` which will record every call to the Linux kernel.

Before we look at the output, let's stop to recursively explain what is going on.

> :information_desk_person:: Why Nautilus?
> 
> No reason. I just wanted a simple program that doesn't do much.

> :raising_hand:: How do you know to look at calls into the kernel?
> 
> Think about how the way programs run. Starting any process requires the kernel to be notified of the program you are starting.
> These interactions are called **syscalls**. These functions are how a user programs ask the operating system to do something privileged.
> For example, a process cannot open a file without asking for permission first. You can think of system calls as normal function calls for the purposes of this exercise.


```
$ strace nautilus
execve("/run/current-system/sw/bin/nautilus", ["nautilus"], 0x7ffe54d428a0 /* 75 vars */) = 0
brk(NULL)                               = 0x30e3a000
------ 23,744 lines snipped ---------
```

What was that output???? My terminal gets flooded with nautilus' tens of thousands of syscalls. I have clearly made a grave mistake. That's okay, it's too early to get demoralized. Clearly, my mental model that a program which does not *appear* to be doing anything is doing *nothing* is wrong. How can we adjust course to make better progress? 

### Load "Hello World"

We can write a minimal `hello_world.c` program to test with.

```c
#include <stdio.h>

void main() {
        printf("hello world!\n");
}

```
```bash
$ gcc hello_world.c
$ ./a.out
hello world!
```

Aha, we have solved the puzzle! `printf` is just a function call. Spoiler alert: this is wrong. We still haven't explained what this `printf` reference is.

> :angry:: You said I wouldn't need any prerequisite knowledge to understand this. I don't understand these keywords. What is this weird void thing?
> 
> If you haven't seen this before, I think you can ignore it for now. It just means that the function has no input and no output.

> :confounded:: What is that `\n` after hello world?
> 
> Wonderful question, though you may not realize it :smile:. Simply, the `\n` asks `printf` to print a newline. Check out my [fork](/fork) post and the resources on `printf` at the end of this post to get closer to what all `\n` *actually* does.

In fact, if we remove all unfamiliar syntax, the program behaves the same as before.

```c
main() {
        printf("hello world!\n");
}
```
```bash
$ gcc hello_world.c
$ ./a.out
hello world!
```

This time our compiler, `gcc`, complains with a bunch of warnings:

```c
hello_world.c:1:2: warning: return type defaults to ‘int’ [-Wimplicit-int]
    1 |  main() {
      |  ^~~~
hello_world.c: In function ‘main’:
hello_world.c:2:9: warning: implicit declaration of function ‘printf’ [-Wimplicit-function-declaration]
    2 |         printf("hello world!\n");
      |         ^~~~~~
hello_world.c:1:1: note: include ‘<stdio.h>’ or provide a declaration of ‘printf’
  +++ |+#include <stdio.h>
    1 |  main() {
hello_world.c:2:9: warning: incompatible implicit declaration of built-in function ‘printf’ [-Wbuiltin-declaration-mismatch]
    2 |         printf("hello world!\n");
      |         ^~~~~~
hello_world.c:2:9: note: include ‘<stdio.h>’ or provide a declaration of ‘printf’
```

This is weird. The program runs the same, so why are we getting all these warnings?
One line jumps out at me. `gcc` warns us **four** times about something to do with the "declaration of 'printf'".
Before we get ahead of ourselves, allow me to fix these compiler warnings. Fixing these warnings will prevent any weird unrelated issues that interfere with our later debugging results.

```diff
> #include <stdio.h>
 
> void main() {
        printf("hello world!\n");
  }

```

Following the error message `include ‘<stdio.h>’ or provide a declaration of ‘printf’` tells us precisely how to fix the error and gives a pointer on what the problem was.
C knows about functions it can link with using header files. Including `stdio.h` tells `gcc` about the definition of `printf`.

### Load "Hello {name}"

We tried declaring victory on the puzzle. Can we double check our intuition matches something else. We want to confirm `printf` is a function the same as any other, so let's print something else out.

```diff
> void main(int argc, char** argv) {
>   if (argc < 2) {
>     printf("hello: error with argc\n");
>     return;
>   }
<       printf("hello world!\n");
>       printf("hello, %s!\n", argv[1]);
  }
```

> [!WARNING]
> TODO: Need to integrate this better. May need to move later since `puts` has not been introduced yet.

Now we print out a name given to us from the command line, as so `./a.out Samir`. As we go through, I am going to reduce the handholding. Take a moment to think about whether you understand the change I just made.

<details markdown="1">
  <summary>Can you explain what argc is and why I check if it is 2? Why not 1? Why do I index 1 into argv if C arrays are zero indexed?</summary>
> Practice looking this question up. Stack overflow is a wonderful library of questions. Try searching "what is argc and argv in C".

</details>


## It's a function call

Let's verify this conclusion we have reached. Let's run `strace` on `hello_world` and save the output to a file "hello_world.strace".

```bash
$ gcc hello_world.c
$ strace -o hello_world.strace ./a.out
```
```c
execve("./a.out", ["./a.out"], 0x7ffc3c8056d0 /* 158 vars */) = 0
brk(NULL)                               = 0x33d6f000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5e57473000
access("/etc/ld-nix.so.preload", R_OK)  = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/glibc-hwcaps/x86-64-v4/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/glibc-hwcaps/x86-64-v4/", 0x7ffc1f6fbf30, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/glibc-hwcaps/x86-64-v3/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/glibc-hwcaps/x86-64-v3/", 0x7ffc1f6fbf30, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/glibc-hwcaps/x86-64-v2/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/glibc-hwcaps/x86-64-v2/", 0x7ffc1f6fbf30, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/sga46w4h0l00adh433634s7kp724czvn-shell/lib/", 0x7ffc1f6fbf30, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/glibc-hwcaps/x86-64-v4/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/glibc-hwcaps/x86-64-v4/", 0x7ffc1f6fbf30, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/glibc-hwcaps/x86-64-v3/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/glibc-hwcaps/x86-64-v3/", 0x7ffc1f6fbf30, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/glibc-hwcaps/x86-64-v2/libc.so.6", O_RDONLY|O_CLOEXEC) = -1 ENOENT (No such file or directory)
newfstatat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/glibc-hwcaps/x86-64-v2/", 0x7ffc1f6fbf30, 0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 4
read(4, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\244\2\0\0\0\0\0"..., 832) = 832
pread64(4, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
fstat(4, {st_mode=S_IFREG|0555, st_size=2335712, ...}) = 0
pread64(4, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
mmap(NULL, 2067928, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 4, 0) = 0x7f5e5727a000
mmap(0x7f5e572a2000, 1474560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x28000) = 0x7f5e572a2000
mmap(0x7f5e5740a000, 352256, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x190000) = 0x7f5e5740a000
mmap(0x7f5e57460000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x1e5000) = 0x7f5e57460000
mmap(0x7f5e57466000, 52696, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f5e57466000
close(4)                                = 0
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5e57277000
arch_prctl(ARCH_SET_FS, 0x7f5e57277740) = 0
set_tid_address(0x7f5e57277a10)         = 467906
set_robust_list(0x7f5e57277a20, 24)     = 0
rseq(0x7f5e57278060, 0x20, 0, 0x53053053) = 0
mprotect(0x7f5e57460000, 16384, PROT_READ) = 0
mprotect(0x403000, 4096, PROT_READ)     = 0
mprotect(0x7f5e574aa000, 8192, PROT_READ) = 0
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=16384*1024, rlim_max=RLIM64_INFINITY}) = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0x2), ...}) = 0
getrandom("\xc3\xaa\x18\x11\xb5\x45\x97\x82", 8, GRND_NONBLOCK) = 8
brk(NULL)                               = 0x33d6f000
brk(0x33d90000)                         = 0x33d90000
write(1, "hello world!\n", 13)          = 13
exit_group(13)                          = ?
+++ exited with 13 +++
```

Oh my. Have we even gotten closer to the solution? The output has a lot of information we do not understand yet, and I do not know what data we want to look for.
On the positive side, at least the output fits on a screen now. Directly tracing the output hasn't gotten us anywhere and these syscalls still look daunting.

We need to break out our debugging hats :tophat:. If we have faith that we will be able to solve this problem, then we will be able to figure out what is going on.
Let us try repeating the strategy of looking at the output of our tools. This time `gcc` and the standard output on the command line haven't suggested anything to us. 

This will be quite tedious. Can we offload the busy work an LLM and see what it says?
We live in the 21st century, so although I wouldn't trust an LLM to give the correct answer, but it can be helpful by suggesting terms we should look at.

![asking chatgpt to explain the syscalls](/images/spelunking/chatgpt_syscall.png)

> Instructor: You are going down the wrong track. Let's back up.

We need to take a moment to think about the approach. `strace` is a bit too hard to interpret, especially since it requires us to understand what all these syscalls are and then to fill in the blanks of what is going on.

Maybe we should take a look at a different level of abstraction? There is nothing more we can learn from the source C file.
It seems like we need to go deeper. Is there another file we have?

> ↛ Load and trace a "simple" program
>
> ↛ Load a minimal program
>
> ⇝ Idea: `printf` is a function call
>
> ⇝ dead end...?

## Binary spelunking

What is inside this `a.out` thing? I know it is a compiled binary, so this must contain all the machine code instructions that are running, right?

```
vim a.out
```

Uh, that's not right. I don't think there is anything useful here to see. I do see some characters rendering correctly, but they look like nonsense. I see "ELF" and then some file paths at the start and end of this file.

![garbled vim buffer](/images/spelunking/vim_binary.png)

Let's put a pin in this stuff we have seen in case it comes up later. Writing a log of what you have tried while debugging is essential to be able to keep all the relevant context in your head. What works as well as what didn't helps narrow the scope of debugging.

> ⇝ dead end...?

### How to open a binary?

> Hey search engine, how can I open `a.out` C binary file?

The internet reveals the tool we need: `objdump`. You probably already have `objdump` installed as it comes with the `gcc` package. This bundling tells us that both `objdump` is probably very useful and it's a default tool which is important to be familiar with.

I see some nonsense in the objdump. I cannot recognize this is the same as my original `hello_world.c`.

First we must recompile with debug flags to make this easier. Now I think we have explored our way to the right level of abstraction on what printf is actually doing.
Binary spelunking is the perfect way to see what the CPU is running in order to get us to hello world showing up.

Every time we try something new, I want to try doing the simplest thing so my brain isn't getting overloaded with unneeded context. Let's first try out this new tool on our `hello_world` binary.

```
gcc -g hello_world.c
objdump -D ./a.out
```

There are many flags to `objdump`. You can read the `man` page to learn more, but I can recommend some to save time. We might need to try a few times until we see something that can help us. Again, the goal is to both induct new hypotheses on what is happening and deduct possibilities that are definitely not valid explanations for the behavior we are seeing.

> TODO: diagram of cutting search space in half (maybe from that prof howto debug post)

The name of the game is persistence. If it was easy to understand how things work, making new systems wouldn't be much fun at all. I promise at the end, your appreciation for the scope of how much work goes into everything will grow.

```
objdump -p ./a.out
objdump -h ./a.out
```

Ooh, I like the output of `-h`. It's concise enough for me to read and doesn't have too much unfamiliar. However, we are definitely getting somewhere, so I want to be more thoughtful about what step we take next. Trying a few more commands...

```
objdump -D ./a.out
```

... this one also looks helpful. Okay let's recap. What can we check out next. There is this thing called "ELF". I dismissed it before when looking at the binary, but it keeps coming up. We should look into that. I think that will help us understand the rest of this objdump output. I also want to look at the disassembly. Clearly something that I did not predict is going on here.

A spoiler, as it turns out, we are going to need to understand both of these things, so the order doesn't matter.

### `dump`ster fire

Online it seems there is a file format called ELF.


There's a lot of output from this disassembly. I scrolled through it to see anything interesting. The ordering of these instructions is a bit confusing, so it may not be productive to jump into tracing the instructions of printf.





### where art thou, `printf`?

We are close, I can feel it. Find printf with grep. 

```
objdump -D ./a.out | grep "printf"
```

> Student: wtf?
> Student: You know, I have a great idea how to finish debugging this. Let's give up.

The challenge is what makes it fun. Anticipate how much satisfaction you'll feel when we figure
this out together. Just stick with me for a moment. Perhaps there is something simple we have missed, just like how we skipped over the references to "ELF"?


Another low hanging fruit to investigate I noticed while scrolling through the file is all these sections.
The objdump is too much data to interpret, so this might be easier to digest.

```
objdump -D ./a.out | grep "section"
```

We did turn on debug symbols, what gives? Honestly, I have no idea how to proceed myself from this. Since we're stuck, we might have done something wrong previously. Let's backtrack and see what's up.

Okay now that I think about it, I have no idea why we are looking at some contrived program I wrote. Let's go back to a real ~~simple~~ program like nautilus.

```
objdump -D $(which nautilus) | grep "printf"
0000000000401080 <__asprintf_chk@plt>:
  401080:       ff 25 4a 3f 00 00       jmp    *0x3f4a(%rip)        # 404fd0 <__asprintf_chk@GLIBC_2.8>
  40132f:       e8 4c fd ff ff          call   401080 <__asprintf_chk@plt>
```

{ diagram of person staring into abyss of a wall }

Okay what? I was not expecting this at all. I was staring at this wall we got stuck at and thought I would have to try a bunch of things to get through. But this is something we didn't expect. Why did changing the binary we use make a difference?

We have found something that doesn't fit in our mental model. Great! Now we get another opportunity to learn something very cool and update our knowledge.

Does this weird thing also happen for `hello_name.c`? Indeed, we see `printf`.

Let's go back to our lab notebook and mark this behavior as something we will have to reconcile later. For now, let's stay calm and explore on.

```
objdump -D ./a.out | grep "printf"
0000000000401040 <__printf_chk@plt>:
  401040:       ff 25 a2 2f 00 00       jmp    *0x2fa2(%rip)        # 403fe8 <__printf_chk@GLIBC_2.3.4>
  401067:       e9 d4 ff ff ff          jmp    401040 <__printf_chk@plt>
```

This is just a few lines, so we can check this manually. If we go in the objdump to where this is found.

No expert tooling needed
```
objdump -D ./a.out | less
# then type "/printf" <enter>
```

```
Disassembly of section .plt:

0000000000401020 <puts@plt-0x10>:
  401020:       ff 35 aa 2f 00 00       push   0x2faa(%rip)        # 403fd0 <_GLOBAL_OFFSET_TABLE_+0x8>
  401026:       ff 25 ac 2f 00 00       jmp    *0x2fac(%rip)        # 403fd8 <_GLOBAL_OFFSET_TABLE_+0x10>
  40102c:       0f 1f 40 00             nopl   0x0(%rax)

0000000000401030 <puts@plt>:
  401030:       ff 25 aa 2f 00 00       jmp    *0x2faa(%rip)        # 403fe0 <puts@GLIBC_2.2.5>
  401036:       68 00 00 00 00          push   $0x0
  40103b:       e9 e0 ff ff ff          jmp    401020 <_init+0x20>

0000000000401040 <__printf_chk@plt>:
  401040:       ff 25 a2 2f 00 00       jmp    *0x2fa2(%rip)        # 403fe8 <__printf_chk@GLIBC_2.3.4>
  401046:       68 01 00 00 00          push   $0x1
  40104b:       e9 d0 ff ff ff          jmp    401020 <_init+0x20>

Disassembly of section .text:

0000000000401050 <main>:
  401050:       83 ff 01                cmp    $0x1,%edi
  401053:       7e 17                   jle    40106c <main+0x1c>
  401055:       48 8b 56 08             mov    0x8(%rsi),%rdx
  401059:       bf 02 00 00 00          mov    $0x2,%edi
  40105e:       31 c0                   xor    %eax,%eax
  401060:       48 8d 35 b4 0f 00 00    lea    0xfb4(%rip),%rsi        # 40201b <_IO_stdin_used+0x1b>
  401067:       e9 d4 ff ff ff          jmp    401040 <__printf_chk@plt>
```

```
Disassembly of section .plt:
[...]
0000000000401040 <__printf_chk@plt>:
  401040:       ff 25 a2 2f 00 00       jmp    *0x2fa2(%rip)        # 403fe8 <__printf_chk@GLIBC_2.3.4>
  401046:       68 01 00 00 00          push   $0x1
  40104b:       e9 d0 ff ff ff          jmp    401020 <_init+0x20>

Disassembly of section .text:
[...]
0000000000401050 <main>:
  [...]
  401067:       e9 d4 ff ff ff          jmp    401040 <__printf_chk@plt>
```

### Pretty Little Thing

We see all these references to `plt`. Looking this up, it turns out that the PLT has a table with pointers
to the real locations of functions.

Why would we not know where printf is? Aha we need to remember this is from libc. In fact it says it in the
dump that this is defined from GLIBC version 2.3.4.

So we have debunked the theory that printf is a normal function call. What is it? No matter how hard you try to find a definition of `printf` in the objdump, you will not be able to find anything.

> Student: how can I be sure `printf` is *actually* a part of libc? You're a rando on the internet, not my teacher.

Spoken like a true skeptic. (Reed University). So if we are looking at every instruction in our binary and can't find printf, then what is happening? When I run a binary, all the OS does is go to main() and then start executing instructions. My entire binary has been printed, so something is wrong with objdump.

Alas, another twist in the road. First one nitpick -- main() is not the first thing that runs. If you look at the dump you will see something called `_start` that calls some libc main. (TODO: find execve in kernel and look for _start.) Yes, it is the case that we have the whole binary. Think back to when we opened `a.out` in `vim`. Did we see something in addition to some uninterpretable binary? Hint: at the start and end of the file.

### Return of the Elves

Yes! There are ELF headers. Let's look at those for some hints about printf. Looking this up tells us we can read elf headers

The `man` page suggests to use `-a` to print all headers. We can use our newfound knowledge of PLTs to `grep` for `plt`. This leads us to the "Relocation section" of the `readelf` output. For readability, we can print just this section and inspect it manually.

```c
$ readelf -r ./a.out
Relocation section '.rela.dyn' at offset 0x5f0 contains 2 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000403ff0  000100000006 R_X86_64_GLOB_DAT 0000000000000000 __libc_start_main@GLIBC_2.34 + 0
000000403ff8  000300000006 R_X86_64_GLOB_DAT 0000000000000000 __gmon_start__ + 0

Relocation section '.rela.plt' at offset 0x620 contains 2 entries:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000403fe0  000200000007 R_X86_64_JUMP_SLO 0000000000000000 puts@GLIBC_2.2.5 + 0
000000403fe8  000400000007 R_X86_64_JUMP_SLO 0000000000000000 __printf_chk@GLIBC_2.3.4 + 0
```

Lucky! `printf` has conveniently appeared here. Indeed, these addresses match up with the offsets we saw in the binary. A call to `printf` will dereference the value at the offset and use that implementation `# 403fe8 <__printf_chk@GLIBC_2.3.4>`. 

We can see that the compiler has told us in the "Sym[bol] Value" column that `printf` is located at 0x0. But wait, isn't that a suspicious address? 0x0 is a NULL pointer.

We have all the information we need. Let's continue backtracking and synthesizing the intel we gathered under our refined understanding for what we are looking for.


Let's go back to strace. This will capture everything happening at runtime and in what order it happens. 

If we ignore all the noise of failures of looking for libc. The program takes a few steps once it finds `libc`.

```c
openat(AT_FDCWD, "/nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 4
read(4, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\244\2\0\0\0\0\0"..., 832) = 832
pread64(4, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
fstat(4, {st_mode=S_IFREG|0555, st_size=2335712, ...}) = 0
pread64(4, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
mmap(NULL, 2067928, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 4, 0) = 0x7f5c576cd000
mmap(0x7f5c576f5000, 1474560, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x28000) = 0x7f5c576f5000
mmap(0x7f5c5785d000, 352256, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x190000) = 0x7f5c5785d000
mmap(0x7f5c578b3000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x1e5000) = 0x7f5c578b3000
mmap(0x7f5c578b9000, 52696, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f5c578b9000
close(4)                                = 0
```

*summary of the syscalls, steal from https://www.maizure.org/projects/printf/dynamic_strace_walkthrough.txt* 

Look, if you just roll up your sleeves and do some good old-fashioned documentation sleuthing, we can understand what this previously overwhelming `strace` output means. And we now also know that our LLM above was speaking confidently about things it doesn't know. Although it looks believable, it got several things completely wrong.

Instead of LLMs, let's apply our willpower to see what these straced lines mean.


> Student: I'm still not satisfied. We never saw any reference to any logic of looking for libc in our objdump.
> Instructor: That's the spirit. Do you have any ideas?
> Student: The first thing that pops into my mind is let's open this file `.../libc.so.6` in `vim`
> Instructor: Good idea. I can't discern anything from this file, but I do see this "ELF" mention again. What do we do when we see this?
> Student: `readelf`!

```
$ readelf -a .../libc.so.6
```

There is a lot of output, but we can take a few seconds to skim the output. I piped this multi-thousand line output into `less` and held the spacebar to skim if anything catches my eye. I do see a huge section 
"Symbol table '.dynsym' contains 3158 entries" which has a lot of "FUNC" entries. It appears to contain a reference to every function in libc. But why are these all in the dynamic symbol section again?

It appears this file doesn't know where these functions are located. The rabbit hole goes deeper; let's not lose hope.


## Go Deeper, Brother

We can use `gdb` to gain confidence (or to invalidate) our new theory.
We know the address of our `plt`, so let's print out that memory and see if it got loaded even before our code runs.

Cool. And we can confirm this points to the area of virtual memory which `strace` told us that `libc` got read to. So this is definitley not a function call inside our code. `libc` is providing the implementation.

Armed with this knowledge, we can both understand the world and bend it to our will. Let's use `gdb` to change where the function points. If I write a second function and recompile, I can modify execution from printf to my own function! How does it feel to be able to grok the system and control its real behavior?

> Instructor: That's great you know that. But what is it *actually doing*?
> Instructor: Cool. But what sequence of instructions *actually run* to do that?
> Instructor: Neat. How would you do that if you were designing it?

We learned how processes are loaded and how libraries can by dynamically loaded. We even know how to manipulate a running program.

## Knowledge Check

Can you find an input to this function [link to starcode and liveoverflow video]
With what you know, you should be able to complete this fun and difficult exercise using normal control flow.


## Now it's your turn

> Hey, here's a fun idea. How about I sit on the couch and I watch you next time. I want to hear you tell a joke when no one's laughing in the background.

We have covered everything now. Can you explain it? Do it, I'm serious. I'm listening from the other side of your screen. Draw out all the steps.

To make sure we haven't missed anything, we can map these to all the syscalls that get called.

1. Write `./a.out` in bash
2. `bash` will fork and then execve `./a.out`
3. Linux reads the ELF and loads the headers
4. ld-loader
5. libc start
6. run app
7. printf
8. exit


For a detailed explanation of every line, expand this dropdown:
{include https://www.maizure.org/projects/printf/dynamic_strace_walkthrough.txt}

We can be confident that these are the steps that get taken. We found a path that definitely explains the chain of events. However, the question remains: *who* is doing all this work?

Nothing happens by magic. There is code somewhere that is populating our plt table, and it sure isn't anywhere in a.out. Or is it?

There are two cases. Either this logic is in `a.out` or it is somehow done in the background by the kernel when it is setting up out process in `execve`.

Now it's easy to blame things we don't understand for behavior we don't understand. In either case, we should be able to trace what is going on. What if I told you dynamic loading isn't using any special kernel features? We saw every syscall that gets called. If `strace` is observing a syscall happening, then it must be getting triggered by something in userspace. All the syscalls we see getting called are completely general. I don't see a syscall called "dynamic load" or anything like that to suggest a special mechanism is happening. Unix is all about simplicity. Given this hint, let's take it from the top and trace to see where the code is coming from.

Let's take a look at the bytes of `a.out` in `vim` again. I can see there is a bunch of text at the start and end of the binary. There is compile-time info at the end. This suggests that the text at the end is debug info and the text at the start is the ELF headers. Let's recompile without debug flags. Minimizing the test case will make it easier to find the relevant code in `a.out`.

TODO: I thought all debug info would be gone. What is that at the bottom?

If we look carefully this time at the binary and readelf, there is this file path in both places, which we have been skipping.

```md
[Requesting program interpreter: /nix/store/nqb2ns2d1lahnd5ncwmn6k84qfd7vx2k-glibc-2.40-36/lib/ld-linux-x86-64.so.2]
```

Aha, just like how you might have seen in bash, this is like a shebang that specified something which will run or ELF. This loader program is what does the work of loading our libraries.

Isn't that cool? We loaded libraries with standard kernel mechanisms.

Now this will blow your mind. 

Programs are files. Code is just binary wrapped with some ELF headers sitting on your disk drive. We can see dynamic linking is accomplished by using normal file operations. All it takes to dynamically load is to map the library into the memory space at runtime. Using `mmap` does just this! Programs can modify their own address space and load libraries however they wish. This requires no special kernel support! Linux provides us with these general syscall mechanisms which we can flexibly use.

If we zoom out, what was the point of dynamically loading in the first place. We have observed most programs are dynamically loading libc. But it is all just code in the end, why not just include it in the same file? Indeed, this would have less runtime overhead since you don't have to do any loading. 

{ look how big the statically linked version of this is}

Clearly, we save a lot of space on disk by not duplicating the same logic for libc functions like printf. So if we load many programs, these same functions will get duplicated in the code of every program.

Every program is loading libc, so can we share these in memory? How would you change the way that libraries are being loaded to support using the same physical memory.

Consider that loading libraries is just putting things in memory. Remember that all these applications are running in their own virtual memory spaces.
What if we could load libc once and then share this same physical memory.

```
          phys mem
P1 ----->  libc
      |
P2 ---- 
```

How would you change the way libraries are loaded in order to support this feature?

Let's dive into what mmap is doing to figure it out.

TODO: man page

Wait, so it is magic? Operating systems sure are magic. 

This is hard to test because the Linux kernel does a lot of optimizations. If you don't trust me, you can read the official kernel docs.

### Gimme a man

Look at the man pages. What is private? Let's look at the older man page.
Need to look at both man pages, man 2 is up to date but links to man mmap.

## Kernel Sourcerers

Ooh let's look at source code.
mmap goes nowehre
looking it up let's find sys_mmap

footnote: path to finding this is using this post https://stackoverflow.com/questions/14542348/how-to-find-a-definition-of-a-specific-syscall-in-linux-sources and then use regex "." syntax to find the definition of mmap

https://github.com/torvalds/linux/blob/v6.13/arch/arm64/kernel/sys.c#L28

https://livegrep.com/search/linux?q=file%3A.c%20sys_mmap%20path%3Aarm64&fold_case=auto&regex=false&context=true

calls some function which we can use github to quickly find definitions.
https://github.com/torvalds/linux/blob/master/mm/mmap.c#L569

You will notice the logic is in `do_mmap`
https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/mmap.c#L280

Now here we have a source code comment that tells us the exact mechanics of what is happening. It fills in some of the implementation details.

You can see all this function does is a whole lot of permission checking. Here we find the source of truth for https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/mmap.c#L469 the MAP_PRIVATE flag.

We can trace the function calls `mmap_region` https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/vma.c#L2509
⟶ `__mmap_region`

[Virtual Memory Areas](https://www.kernel.org/doc/gorman/html/understand/) full details are in this document.
We can ignore the details about virtual memory. We can focus on the note about the file which is being loaded.

```
 * @file: If a file-backed mapping, a pointer to the struct file describing the
 * file to be mapped, otherwise NULL.
```


If you continue tracing you will get stuck. How is the file never actually used in any of this code?
Now this is why looking at real OS code can be complicated. We need to first understand what we are looking at.

Linux tries to be as fast as possible. It is not going to load data from disk if it does not have to. So this mmap is
actually a lie. It is not loading any files. It is just setting up page table entries for the virtual memory space.

Can you think about how the OS would know when it has to load a page in?

The pages it marks are valid mapping so the hardware knows that these virtual memory addresses are allowed, but they have not been mapped yet, so the permission bits will indicate that the hardware should fault into the OS in the case that these pages do get accessed.

So now, you might guess that we need to look at the logic on a page fault of one of these addresses. 

Inside of arm64's `do_page_fault` we see where the memory mapping code gets called

https://github.com/torvalds/linux/blob/ffd294d346d185b70e28b1a28abe367bbfe53c04/arch/arm64/mm/fault.c#L647
⟶
https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/memory.c#L6177

`__handle_mm_fault`
https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/memory.c#L5950

Are you getting a hang of it? Even though there is a lot of code, the kernel source is extremely high quality code and you can quickly pick up
the conventions they use such as `do_` functions do the work, `sys_` and `SYSCALL_DEFINE` help you find where syscalls enter, and `__` functions are internal functions that implement all the logic and get called once all permission checks are done.

Reading unfamiliar code is difficult, but you can follow the same process we have been using: recursively explore function definitions until you understand what the acronyms are, what functions do, and what the jargon means in context.

You will realize these function calls are not relevant. They have to do with unrelated unhappy paths that can get hit on a page fault. This code walks and allocates the multi-level page table.

⟶ `handle_pte_fault` https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/memory.c#L5856
now the fault must get handled. The backing memory must become valid before the OS can return to the faulted program.
This function does these steps
```chatgpt
Overview of Execution Flow

    Check if the Page Middle Directory (PMD) is present.
    Get or allocate a Page Table Entry (PTE).
    Determine the type of fault and handle it accordingly:
        Page is missing → Allocate a new page (do_pte_missing()).
        Page is swapped out → Swap it back in (do_swap_page()).
        Page migration/NUMA fault → Handle it (do_numa_page()).
        Write protection fault → Handle copy-on-write (COW) (do_wp_page()).
        Otherwise, mark the page as accessed and dirty if needed.
```
```
If the Page Middle Directory (PMD) entry is missing, it means there’s no page table yet.
If the PTE is empty (pte_none()), then the page is not allocated yet, so we will handle it as a missing page. 

```

```
Execution Path to Disk Access

When the faulted page is missing or swapped out, the execution path continues as follows:

    Page is missing → do_pte_missing()
        If the mapping is anonymous, a new page is allocated.
        If the mapping is file-backed, the function calls filemap_fault() to fetch data from disk.

    Page is swapped out → do_swap_page()
        Reads the page from swap storage.
        Inserts it back into the process’s address space.

    File-backed page → filemap_fault()
        If the page is not in memory, it requests disk access via the block layer.

    Disk access happens via the filesystem & block layer
        The requested page is fetched from disk into the page cache.
        Once loaded, the page is mapped and execution continues.
```
⟶ We fall into [`do_pte_missing`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/memory.c#L4053) because the page for this mmap has not been created nor has the file been loaded. 

This page is not a normal stack or heap page, so we need to do work to load the file. We fall into `do_fault`
⟶ [`do_fault`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/memory.c#L5507)

The code branches on the types of faults
⟶ This is a [`do_read_fault`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/memory.c#L5383)
⟶ [`__do_fault`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/mm/memory.c#L4961)

This leads to a function pointer for the exact fault handler we want to use for this filesystem

This allows the implementation to be general for the exact filesystem being used. [VFS](https://en.wikipedia.org/wiki/Virtual_file_system)
```c
ret = vma->vm_ops->fault(vmf);
```
The types help us figure this out [`struct vm_fault`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/include/linux/mm.h#L560) ⟶ [`vm_area_struct`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/include/linux/mm_types.h#L681) ⟶ [`vm_operations_struct`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/include/linux/mm.h#L611)

Bingo. We now know what the type of `fault` is: `vm_fault_t (*fault)(struct vm_fault *vmf);`.

Although we have hit a dead end, applying the same exploration tricks gets us to [`filemap_fault`](https://github.com/torvalds/linux/blob/ffd294d346d185b70e28b1a28abe367bbfe53c04/fs/ext4/file.c#L796). `grep` finds us many definitions, but we can choose the `ext4` filesystem as an example. We can use the types to find this does nothing other than call the generic implementation of [`filemap_fault`](https://github.com/torvalds/linux/blob/ffd294d346d185b70e28b1a28abe367bbfe53c04/mm/filemap.c#L3293). Yet again, the comments on the function are extremely helpful and let us confirm we are in the right place.

Let's update our snapshot of our current understanding.

```chatgpt
How Data is Fetched from Disk

If the requested page is not in the page cache, execution proceeds as follows:

    block_page_mkwrite() or ext4_filemap_fault() is called, depending on the filesystem.
    The page is checked in the page cache:
        If present, it is mapped into the process.
        If not present, the function requests a disk read via the block I/O layer.
    The request goes through the I/O scheduler and block device driver.
    The disk fetches the page into the page cache.
    The page is marked present, and the fault handling completes.

Summary of Execution Path

    A missing file-backed page triggers handle_pte_fault().
    It calls do_pte_missing(), which routes to do_fault().
    do_fault() identifies the fault as a read fault and calls do_read_fault().
    This invokes vma->vm_ops->fault(), which for files is filemap_fault().
    filemap_fault() checks if the page is in the page cache.
        If present → Map it into the process and return.
        If missing → Request disk I/O via the block layer.
    The page is read from disk into the page cache.
    The page is mapped, and execution resumes.
```

This looks much more precise than before.


We can continue recursively unfolding function defintions. There is a call to `filemap_get_folio` which returns a `folio` type. The type's comment indicates something interesting. 

[`folio`](https://github.com/torvalds/linux/blob/7eb172143d5508b4da468ed59ee857c6e5e01da6/include/linux/mm_types.h#L324)

Both the filesystem function and this function mntions a "page cache"
``` 
 * A folio is a physically, virtually and logically contiguous set
 * of bytes.  It is a power-of-two in size, and it is aligned to that
 * same power-of-two.  It is at least as large as %PAGE_SIZE.  If it is
 * in the page cache, it is at a file offset which is a multiple of that
 * power-of-two.
```

A `folio` is a reference counted page cache entry. We are loading a new file for the first time, so this won't be in the page cache.


Or will it? What file are we loading again? We are loading libc. Effectively every program is using libc, so this file will surely be in memory already. Alas, this file is being used by other processes, so we cannot reuse the file. Or can we? Let's look back at the syscall we are executing in the first place.

Take a look at the flags. We only want to execute libc, so actually every program is going to get the same read-only copy of this physical memory mapped into their virtual address spaces.

This is magic. There was no coordination between the programs reading this same file. No special mechanisms are being used in the kernel. This is all the same ideas of virtual memory (which uses demand paging) working in harmony to make dynamic library loading work. 




```chatgpt
Tracing to Disk Access

Now, let's follow the path when a file-backed page is missing and needs to be read from disk.

    handle_pte_fault()
        If the page is not present, it calls do_fault().

    do_fault()
        If the mapping is from a file, it calls filemap_fault().

    filemap_fault()
        This function tries to load the missing page from disk.
        It calls page_cache_read() if the page is not already cached.

    page_cache_read()
        Reads the page from the filesystem's page cache.
        If the page is not cached, it requests disk access via the block layer.

    Block Layer → Disk
        The block layer processes the request and fetches the data from the disk into RAM.

    Page is Inserted into Memory
        Once loaded, the page is mapped into the process's address space.

Final Summary

When a page fault occurs:

    The kernel walks the page table in __handle_mm_fault().
    If the page is missing, handle_pte_fault() is called.
    For file-backed pages, filemap_fault() is invoked.
    The filesystem attempts to retrieve the page, possibly reading it from disk.
    The block layer fetches the data from storage.
    The page is mapped, and execution resumes.
```


### "It's for the pedagogy" [amy]

> Student: Holupaminnit, how did we get to `printf`? I thought we were talking about loading binaries?

Alas, I have tricked you into learning something new. One way to ask this question is to ask
what happens when there is a `printf` in your code, but I think the framing of our initial
question at the start led us along a more interesting route.

Undoubtedly, there are many other aspects of loading a program I have skipped. The point to
take home is that exploring is very nonlinear. All the irrelevant things we tried while
inspecting what is going on turned out to be completely relevant! There is a lot going on, but
I hope you will believe me and believe yourself that you could have figured this out.

I like this approach for figuring this out because it works in general. Particularly for kernel code,
the better approach is probably to go directly to kernel documentation and to start reading the
source code.

TODO: objdump the binary to find the label and table
TODO: try mapping things to the kernel
TODO: dump elf headers



# What we didn't cover

Think about these for yourself. Can you write a C program to test your mental model? Can you spelunk your kernel to find out? Remember, just because LLMs act authoritative, it does not mean they know anything.

- How do we know when a program has finished executing? What does it mean to be the last instruction of the file?
- How does printf actually work. I think [this post](https://www.maizure.org/projects/printf/index.html) is supremely interesting. I love the presentation of the post and it goes into much more detail than I get into here. If you think you can explain how `printf` works, this is going to humble you.
- Okay but how is each of these instructions actually executing? What hardware is involved? What is the hardware doing?
- Can you have multiple versions of the same library installed?
- Can you explain why the `hello_world.c` program returns `13`? Hint: what does the `void` keyword mean? Where are return values stored?
- Remaining questions: Why does a simple addition program still load libc? Hint try looking at the output of strace. What is the last system call called by the program?



# Wrapping up

The great part about learning things this way is that you feel empowered to learn anything. The power of open source allows us to figure absolutely anything out with enough effort. We also do not need to trust anything. We have looked at the source ourselves and can be quite confident that we have created a mental model accurate to the real world.

I have surely gotten details wrong in the post. I am sorry. Point them out!

Happy exploring.

<!--
Pierre Habouzit
-->

Think about what it means to load a program. What is a program? (a file) What is a library? (a file) Are programs any different than normal files? (yes, executable. but still just bytes on disk) How does a program modify it's own addr space with a file? (use read() and open() the file, but even better to use mmap since it will handle all the mapping for you) okay now we can load for one program, how to share? what mechanisms need to be added? (nothing, sharing is totally transparent via file cache)

This post was inpspired by this video on linux signals. It's one of the best videos I've ever seen. I rewatch it every few months to remind myself how beautiful it is to be able to understand these precise and complex beasts of machines we use.

I hope you can appreciate the beauty of the ridiculous world we live in. All it takes is a sense of wonder and you can build anything.

### Further Reading:

- [Dynamic linker wiki](https://en.wikipedia.org/wiki/Dynamic_linker)
- [`mmap` wiki](https://en.wikipedia.org/wiki/Mmap)
- [How statically linked programs run on Linux (and how you get from libc to the start symbol)](https://eli.thegreenplace.net/2012/08/13/how-statically-linked-programs-run-on-linux)

The objective is curiosity maximization.

I tried to make the logical steps explicit. If anything was unclear, please send me an email or leave a comment. When you are debugging for real, you should reach directly to the best tool for the job instead of the winding path I took. For example, I used `vim` to open files just to show that binary is not scary. You would never look at a binary in a normal text editor like vim -- reach directly for `objdump` or `readelf`.

Footnote:

Nachos is confusing because semantics do not quite match linux
confused the semantics of mmap and readVM/writeVM.
