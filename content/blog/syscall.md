+++
title  = "Print anything without printf in C/C++"
date = 2022-10-01
+++


We use printf function in c language which a wrapper function provided by GNU c library which provides us some extra functionality but under the hood in reality printf runs "write" which is deeper level system call

<!-- more -->

# System Call
```
// #include<stdio.h>

// int main(){
//      printf("Hello World");
//      return 0;
//}

int main(){
        write(1, "Hello", 5);
        return 0;
}
```

Every time we try to use system kernal functionality we use system calls (syscalls). Because at the end kernal is the real hero who does all the stuff. We write programs which runs syscall.


We programmers just get some wrapper functions like printf, scanf etc...


But the why we just use direct syscall? 🤔 It is because the are complicated than our lower level wrapper functions

```
write(1, "Hello", 5);
printf("Hello");
```

To use direct syscall we want to learn about our kernal how it works, what file discriptor is, and etc. Which is very important btw.


If want to know what syscall your programs are making you can use "strace" which trace system calls

```
gcc hello.c
strace ./a.out
```

```
strace ./a.out
execve("./a.out", ["./a.out"], 0x7ffeb1c81dd0 /* 53 vars */) = 0
brk(NULL)                               = 0x5632c52c5000
arch_prctl(0x3001 /* ARCH_??? */, 0x7ffe87771e90) = -1 EINVAL (Invalid argument)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa391dcb000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=125751, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 125751, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fa391dac000
close(3)                                = 0
openat(AT_FDCWD, "/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P4\2\0\0\0\0\0"..., 832) = 832
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
newfstatat(3, "", {st_mode=S_IFREG|0755, st_size=1953472, ...}, AT_EMPTY_PATH) = 0
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
mmap(NULL, 1994384, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa391bc5000
mmap(0x7fa391be7000, 1421312, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22000) = 0x7fa391be7000
mmap(0x7fa391d42000, 356352, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x17d000) = 0x7fa391d42000
mmap(0x7fa391d99000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1d4000) = 0x7fa391d99000
mmap(0x7fa391d9f000, 52880, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa391d9f000
close(3)                                = 0
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa391bc2000
arch_prctl(ARCH_SET_FS, 0x7fa391bc2740) = 0
set_tid_address(0x7fa391bc2a10)         = 6430
set_robust_list(0x7fa391bc2a20, 24)     = 0
rseq(0x7fa391bc3060, 0x20, 0, 0x53053053) = 0
mprotect(0x7fa391d99000, 16384, PROT_READ) = 0
mprotect(0x5632c4123000, 4096, PROT_READ) = 0
mprotect(0x7fa391dfe000, 8192, PROT_READ) = 0
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0
munmap(0x7fa391dac000, 125751)          = 0
write(1, "Hello", 5Hello)                    = 5
exit_group(0)                           = ?
+++ exited with 0 +++
```

Here you can see at the end we got this write syscall, Don't worry about the starting stuff it is not by our code it is something required to run a program like execp which executes the program referred by the pathname.


Let's create a simple program to open and close a file

```
#include<stdio.h>

int main(){
        FILE *a = fopen("Hello.txt", "w");
        fclose(a);
        return 0;
}
```
```
gcc hello.c
strace ./a.out

execve("./a.out", ["./a.out"], 0x7fffb7eb1e60 /* 53 vars */) = 0
brk(NULL)                               = 0x5606738c5000
arch_prctl(0x3001 /* ARCH_??? */, 0x7ffd8ee438e0) = -1 EINVAL (Invalid argument)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5707df6000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=125751, ...}, AT_EMPTY_PATH) = 0
mmap(NULL, 125751, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f5707dd7000
close(3)                                = 0
openat(AT_FDCWD, "/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P4\2\0\0\0\0\0"..., 832) = 832
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
newfstatat(3, "", {st_mode=S_IFREG|0755, st_size=1953472, ...}, AT_EMPTY_PATH) = 0
pread64(3, "\6\0\0\0\4\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0@\0\0\0\0\0\0\0"..., 784, 64) = 784
mmap(NULL, 1994384, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f5707bf0000
mmap(0x7f5707c12000, 1421312, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x22000) = 0x7f5707c12000
mmap(0x7f5707d6d000, 356352, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x17d000) = 0x7f5707d6d000
mmap(0x7f5707dc4000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1d4000) = 0x7f5707dc4000
mmap(0x7f5707dca000, 52880, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f5707dca000
close(3)                                = 0
mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5707bed000
arch_prctl(ARCH_SET_FS, 0x7f5707bed740) = 0
set_tid_address(0x7f5707beda10)         = 11075
set_robust_list(0x7f5707beda20, 24)     = 0
rseq(0x7f5707bee060, 0x20, 0, 0x53053053) = 0
mprotect(0x7f5707dc4000, 16384, PROT_READ) = 0
mprotect(0x560672ead000, 4096, PROT_READ) = 0
mprotect(0x7f5707e29000, 8192, PROT_READ) = 0
prlimit64(0, RLIMIT_STACK, NULL, {rlim_cur=8192*1024, rlim_max=RLIM64_INFINITY}) = 0
munmap(0x7f5707dd7000, 125751)          = 0
getrandom("\x81\xf2\xde\x60\xcb\xde\xf6\xa0", 8, GRND_NONBLOCK) = 8
brk(NULL)                               = 0x5606738c5000
brk(0x5606738e6000)                     = 0x5606738e6000
openat(AT_FDCWD, "Hello.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 3
close(3)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```

Here we can see at end kernal uses syscall called openat which is used to open or preview a file. Interesting right? syscalls are some special functions provided by kernal.

When you try to learn about this syscall like openat, write, etc. You'll notice one special topic File Discriptor. Which is very interesting. In linux everything is a file.

File Discriptor is just an integer which is assigned by the process to a file which we open.

```
openat(AT_FDCWD, "Hello.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 3
```

Here you can see when we create a call it returns 3

But why it's 3? not 1, not 2, not 0...?🤔

That is Because in Linux 0 assigned to standard input
1 is assigned to Standard output. That's why in our write syscall we passed 1 if you remember

```
write(1, "Hello World", 5);
```

2 is assigned to Standard error.
This are 3 numbers already assigned to processes. That's why when we create a file it returned value 3 and if we create or open another file look what happens


```
#include<stdio.h>

int main(){
        FILE *a = fopen("Hello.txt", "w");
        FILE *b = fopen("Hello1.txt", "w");
        fclose(a);
        return 0;
}
```


```
...
...
openat(AT_FDCWD, "Hello.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 3
openat(AT_FDCWD, "Hello1.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 4
close(3)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```

It's incrementing file to file. Awesome

But wait we talked 1 is assigned to standard output and 0 is assigned to standard input etc Which is a file discriptor. And we also know that in linux everything is a file right? So this stdin, stdout are actually files??? Yes they are...

Inside /dev directory you can find this three files stdin, stdout, stderr. And if we see in more detail.

```
ls -l std*
lrwxrwxrwx 1 root root 15 Oct  1 23:01 stderr -> /proc/self/fd/2
lrwxrwxrwx 1 root root 15 Oct  1 23:01 stdin -> /proc/self/fd/0
lrwxrwxrwx 1 root root 15 Oct  1 23:01 stdout -> /proc/self/fd/1
```

 We can see this are link files. And let me show you something really cool. if i echo something and store the output in a file like -

```
echo "hello world" >> foo.txt
```

It will save my output into foo.txt and not print anything in terminal but if i do the same thing with stdout file it will actually print the output also look -

```
cd /dev
echo "HaHaHa" > stdout
HaHaHa
```

To make it more clear let's run our old code again and strace it.

##### code
```
#include<stdio.h>
int main(){
	printf("Hello");
}
```
##### commands
```
gcc hello.c
./a.out
```
##### output
```
...
...
write(1, "Hello", 5Hello)                    = 5
exit_group(0)                           = ?
+++ exited with 0 +++
```

Here we can see our kernal call write function and it pass 1 at the starting and now we know why this one is got passed. Because 1 is a file discriptor assigned to standard output (stdout).


like when we use scanf to take inupt a systemcall read(0, "my text\n", 1024) is executed with File discriptor 0.


It is so so cool...

# System Call

A system call is an entry point into the Linux kernel. Usually, system calls are not invoked directly: instead, most system calls have corresponding C library wrapper functions which perform the steps required (e.g., trapping to kernel mode) in order to invoke the system call. Thus, making a system call looks the same as invoking a normal library function.

The system call is the fundamental interface between an application and the Linux kernel.

## Return Value

On error, most system calls return a negative error number. The C library wrapper hides this detail from the caller: when a system call returns a negative value, the wrapper copies the absolute value into the errno variable, and returns -1 as the return value of the wrapper.

The value returned by a successful system call depends on the call. Many system calls return 0 on success, but some can return nonzero values from a successful call. The details are described in the individual manual pages.








