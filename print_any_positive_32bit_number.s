// This program is capable of converting any 32 bit positive number
// 	to it's ASCII representation, and printing it to the stdout.

// Please keep in mind that his program allocates memory
// 	from the operating system and doesn't free it in the end.
//  You will need to take care of this later if you will
//  re-use this piece of code.

.global _main
.align 3

.data
num: .word 1234567890

.text
_main:
    ; Load the address of num into x1
    adrp x1, num@PAGE
    ldr w0, [x1, num@PAGEOFF]
    mov x14, x0      ; Save the number in x9 for later use

    ; x3: number of digits in the number
    bl ilen

    ; Calculate number of characters to print
    mov x11, x3      ; Copy the number of digits to x11, used for printing
    add x11, x11, #1 ; Add 1 for \n

    ; Calculate the number of bytes to allocate
    ; by multiplying the number of digits by 4 and adding 1 for \n
    mov x10, x3      ; Copy the number of digits to x10, used for multiplication
    lsl x10, x10, #2  ; Multiply by 4
    add x10, x10, #1  ; Add 1 for \n

    ; Dynamically allocate memory for the buffer using mmap
    ; Arguments for mmap: void* addr, size_t length, int prot, int flags, int fd, off_t offset
    mov x0, #0
    mov x1, x10
    mov x2, #3
    mov x3, #0x1002
    mov x4, #-1
    mov x5, #0
    mov x16, #197
    svc 0
    ; x0 now contains the address of the allocated buffer

    mov x1, x0          ; Move the address of the buffer to x1
    mov x0, x14
    bl itoa

    ; Print the number
    mov x0, #1
    mov x2, x11
    mov x16, #4
    svc 0

    mov x0, #0
    mov x16, #1
    svc 0

itoa:
    ; register usage:
    ; incoming              | x0: number to convert
    ; incoming + outgoing   | x1: address of buffer
    ; used                  | x2: current number / quotient
    ; used                  | x3: remainder
    ; used                  | x4: 10
    ; used                  | x5: digit counter
    ; used                  | x6: temporary storage for quotient
    ; used                  | x7: start index for reversal
    ; used                  | x8: end index for reversal
    ; used                  | x9: temporary storage for character swap

    mov x2, x0          ; Copy the number to x2 for manipulation
    mov x4, #10         ; Set the divisor to 10
    mov x5, #0          ; Initialize counter for digits

.itoa_loop:
    udiv x6, x2, x4     ; Divide the current number by 10, store quotient in x6
    msub x3, x6, x4, x2 ; (quotient * divisor) - current number to get the remainder
    add x3, x3, #48     ; Convert remainder to ASCII
    strb w3, [x1, x5]   ; Store the digit in the buffer
    mov x2, x6          ; Update the current number to the quotient for next iteration
    add x5, x5, #1     ; Increment the digit counter
    cmp x2, #0          ; Check if the current number is 0
    bne .itoa_loop      ; If not, continue the loop

    ; Add \n to the buffer
    mov w3, #10
    strb w3, [x1, x5]

    ; Now, x5 contains the length of the string including the newline character
    ; Start reversal process
    mov x7, #0              ; Start index
    sub x8, x5, #1          ; End index (one less due to newline character)

.reverse_loop:
    cmp x7, x8              ; Compare start and end indices
    bge .reverse_done       ; If start >= end, reversal is done

    ; Swap characters at x7 and x8
    ldrb w9, [x1, x7]       ; Load character at start index
    ldrb w2, [x1, x8]       ; Load character at end index
    strb w9, [x1, x8]       ; Store start character at end position
    strb w2, [x1, x7]       ; Store end character at start position

    ; Update indices
    add x7, x7, #1          ; Increment start index
    sub x8, x8, #1          ; Decrement end index
    b .reverse_loop         ; Repeat

.reverse_done:
    ret


ilen:
    ; register usage:
    ; incoming | x0: number to convert
    ; used     | x1: address of buffer
    ; used     | x2: number to manipulate
    ; outgoing | x3: counter for digits
    ; used     | x4: 10

    mov x2, x0          ; Copy the number to x2 for manipulation
    mov x3, #0          ; Initialize counter for digits
    mov x4, #10         ; Set the divisor to 10

.ilen_count_loop:
    cmp x2, #0          ; Check if the number is 0
    beq .ilen_count_end ; If it is, end the loop
    udiv x2, x2, x4     ; Divide the number by 10
    add x3, x3, #1      ; Increment the counter
    b .ilen_count_loop  ; Continue the loop

.ilen_count_end:
    ret
