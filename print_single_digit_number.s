// Please keep in mind that his program allocates memory
// 	from the operating system and doesn't free it in the end.
//  You will need to take care of this later if you will
//  re-use this piece of code.

.global _main
.align 3

.data
num: .word 1

.text
_main:
    ; Load the address of num into x1
    adrp x1, num@PAGE
    ldr w1, [x1, num@PAGEOFF]

    ; Add 48 to number value
    add w1, w1, #48
    mov w8, w1


    ; Dynamically allocate memory for the buffer using mmap
    ; Arguments for mmap: void* addr, size_t length, int prot, int flags, int fd, off_t offset
    mov x0, #0
    mov x1, #5
    mov x2, #3
    mov x3, #0x1002
    mov x4, #-1
    mov x5, #0
    mov x16, #197
    svc 0
    ; x0 now contains the address of the allocated buffer

    ; Store the number in the buffer
    str w8, [x0]

    ; Add \n to the buffer
    mov w8, #10
    strb w8, [x0, 4]

    ; Print the number
    mov x1, x0          ; Move the address of the buffer to x1
    mov x0, #1
    mov x2, #5
    mov x16, #4
    svc 0

    mov x0, #0
    mov x16, #1
    svc 0

