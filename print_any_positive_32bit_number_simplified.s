// This program is capable of converting any 32 bit positive number
// 	to it's ASCII representation, and printing it to the stdout.

// Please keep in mind that his program allocates memory
// 	from the operating system and doesn't free it in the end.
//  You will need to take care of this later if you will
//  re-use this piece of code.

.global _main
.align 3

.data
num: .word 123555

.text
_main:
    ; Load the address of num into x1
    adrp x1, num@PAGE
    ldr w0, [x1, num@PAGEOFF]

    ; itoa: converts a number to ASCII and stores it in a buffer
    ; input: x0: number to convert
    ; output: x1: address of buffer
    ; output: w2: length of buffer (including newline character)
    bl itoa

    ; Print the number
    mov x0, #1
    mov x16, #4
    svc 0

    ; Deallocate the buffer
    add sp, sp, x2

    mov x0, #0
    mov x16, #1
    svc 0

itoa:
    ; Args
    ; input: x0: number to convert
    ; output: x1: address of buffer
    ; output: x2: length of buffer (including newline character)
    ;
    ; Process
    ; 1. Count the number of digits in the number
    ; 2. Allocate space on the stack for the buffer
    ; 3. Convert the number to ASCII and store it in the buffer
    ; 4. Reverse the string in place
    ; 5. Return


    mov x2, x0                      ; Copy the number to x2 for manipulation
    mov x3, #0                      ; Initialize counter for digits
    mov x4, #10                     ; Set the divisor to 10
    mov x5, #0                      ; Initialize digit counter for buffer offset (itoa_loop)

.itoa_count_loop:
    ; x2 -> modifies the number
    ; x3 -> counts the number of digits
    ; x4 -> divisor
    cmp x2, #0                      ; Check if the number is 0
    beq .itoa_count_end             ; If it is, end the loop
    udiv x2, x2, x4                 ; Divide the number by 10
    add x3, x3, #1                  ; Increment the counter
    b .itoa_count_loop              ; Continue the loop

.itoa_count_end:
    ; x10 -> number of digits + 1 for \n
    ; x1 -> address of buffer
    mov x10, x3                     ; Copy the number of digits to x10, used for multiplication
    add x10, x10, #1                ; Add 1 for \n

    ; Allocate space on the stack for the buffer
    sub sp, sp, x10                 ; Allocate space on the stack
    mov x1, sp                      ; Set x1 to point to the stack space
    mov x2, x0                      ; Copy the number to x2 for manipulation, again

    ; Initialize the buffer with 0s
    mov x3, #0                      ; Register used for digit ascii conversion
    mov x4, #10                     ; Set the divisor to 10
    mov x5, #0                      ; Initialize digit counter for buffer offset
    mov x6, #0                      ; Initialize the quotient

.itoa_loop:
    udiv x6, x2, x4                 ; Divide the current number by 10, store quotient in x6
    msub x3, x6, x4, x2             ; (quotient * divisor) - current number to get the remainder
    add x3, x3, #48                 ; Convert remainder to ASCII
    strb w3, [x1, x5]               ; Store the digit in the buffer
    mov x2, x6                      ; Update the current number to the quotient for next iteration
    add x5, x5, #1                  ; Increment the digit counter
    cmp x2, #0                      ; Check if the current number is 0
    bne .itoa_loop                  ; If not, continue the loop

    ; Add \n to the buffer
    mov w3, #10
    strb w3, [x1, x5]

    ; Now, x5 contains the length of the string including the newline character
    ; Start reversal process
    mov x7, #0                      ; Start index
    sub x8, x5, #1                  ; End index (one less due to newline character)

.reverse_loop:
    cmp x7, x8                      ; Compare start and end indices
    bge .reverse_done               ; If start >= end, reversal is done

    ; Swap characters at x7 and x8
    ldrb w9, [x1, x7]               ; Load character at start index
    ldrb w2, [x1, x8]               ; Load character at end index
    strb w9, [x1, x8]               ; Store start character at end position
    strb w2, [x1, x7]               ; Store end character at start position

    ; Update indices
    add x7, x7, #1                  ; Increment start index
    sub x8, x8, #1                  ; Decrement end index
    b .reverse_loop                 ; Repeat

.reverse_done:
    ; mov x10 (number of digits) to x2
    mov x2, x10
    ret

