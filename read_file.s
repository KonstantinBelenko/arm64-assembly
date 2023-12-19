.global _main
.align 3

.data
buffer: .space 64

.text
_main:
	// Save argc and argv
    mov x19, x0     // Save argc in x19
    mov x20, x1     // Save argv in x20

    // Check if argc is less than 2 (program name + 1 argument)
    cmp x19, #2
    blt terminate   // Exit if not enough arguments

    // Load filename from argv[1]
    ldr x0, [x20, #8] // argv[1] is at x20 + 8 bytes

	// prepare to read
	mov x1, #0		// 
	mov x16, #5		// #5 means open
	svc 0			// open file
	
	mov x19, x0		// save file descriptor in x19
	
_read_file_loop:

	// file descriptor -> x0
	// buffer address  -> x1
	// 64			   -> x2
	// 
	// READ SYSCALL -> [b_1024](x0) -> x1

	// file descriptor
	mov x0, x19	

	// save buffer address to x14 before the syscall
	adrp x14, buffer@PAGE
	add x14, x14, buffer@PAGEOFF 	// read the buffer address into x1
	
	// Save buffer address to stack
    sub sp, sp, #16
    str x14, [sp]

	// Prepare to read syscall
	mov x1, x14
	mov x2, #63						// read b_1024->x2
	mov x16, #3						// syscall for read
	svc 0

	// save the number of bytes read
	mov x20, x0


	cmp x0, #0
	beq _close_file


	// Null-terminate the buffer
    ldr x14, [sp]          // load buffer address
    add x14, x14, x20      // calculate the position for null byte
    mov w1, #0             // null byte
    strb w1, [x14]         // store null byte at the end of data

	
	// Restore buffer address from stack
    ldr x14, [sp]
    add sp, sp, #16

	// print the buffer
	mov x0, x14
	bl print
	b _read_file_loop

	
_close_file:
	mov x16, #6			// syscall 6 for close
	svc 0
	
	b terminate

terminate:
	mov x0, #0			// return 0
	mov x16, #1			// terminate
	svc 0				// syscall

print:
	mov x1, x0

_print_loop:
	ldrb w2, [x1]
	cmp w2, #0
	beq _print_end

	// Save x1 to stack
	sub sp, sp, #16
	str x1, [sp]	

	mov x0, 1
	mov x2, 1
	mov x16, 4
	svc 0

	// Restore x1 and clean the stack
	ldr x1, [sp]
	add sp, sp, #16

	// post increment x1 to next character
	add x1, x1, #1

	b _print_loop

_print_end:
	ret
