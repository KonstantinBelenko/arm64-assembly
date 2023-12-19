// This program counts the number of digits a positive number has.

// Please keep in mind that his program allocates memory
// 	from the operating system and doesn't free it in the end.
//  You will need to take care of this later if you will
//  re-use this piece of code.

.global _main
.align 3

.data
num: .word 69696969

.text
_main:
    ; Load the address of num into x1
    adrp x1, num@PAGE
    ldr w0, [x1, num@PAGEOFF]

    bl itoa

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
    str w7, [x0]

    ; Add \n to the buffer
    mov w7, #10
    strb w7, [x0, 4]

    ; Print the number
    mov x1, x0          ; Move the address of the buffer to x1
    mov x0, #1
    mov x2, #5
    mov x16, #4
    svc 0

    mov x0, #0
    mov x16, #1
    svc 0

itoa:
    ; register usage:
    ; incoming | x0: number to convert
    ; used     | x1: address of buffer
    ; used     | x2: number to manipulate
    ; used     | x3: counter for digits
    ; used     | x4: 10
    ; outgoing | x7: number of digits

    // 1. Get the number of digits in the number to allocate the buffer
    mov x2, x0          ; Move the number to x2 for manipulation
    mov x3, #0          ; Initialize counter for digits (1 for the newline)
    mov x4, #10

.itoa_count_loop:
    cmp x2, #0          ; Check if the number is 0
    beq .itoa_count_end ; If it is, end the loop
    udiv x2, x2, x4    ; Divide the number by 10
    add x3, x3, #1      ; Increment the counter
    b .itoa_count_loop  ; Loop

.itoa_count_end:
    add x3, x3, #48
    mov x7, x3          ; Move the number of digits to x7
    ret
