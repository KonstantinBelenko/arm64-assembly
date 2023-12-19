.global _main
.align 3

.data
string_1: .asciz "test\n"

.text
_main:
	adrp x0, string_1@PAGE
	add x0, x0, string_1@PAGEOFF
	bl print

	adrp x0, string_2@PAGE
	add x0, x0, string_2@PAGEOFF
	bl print

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
