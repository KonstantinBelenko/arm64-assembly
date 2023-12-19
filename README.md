# Arm64 Assembly Programs

Just a list of random small programs like hello world, converting a number to a string, loops, and other small scripts that I wrote in order to teach myself arm assembly on my m1 mac.

# How to assemble:

I used these commands to assemble and link the code to object files and then executable binaries.

```bash
# Assemble code
as -g temp.s -o temp.o

# Link 
ld temp.o -o temp -L `xrun --sdk macosx --show-sdk-path`/usr/lib -lSystem -e _main -arch arm64
```
