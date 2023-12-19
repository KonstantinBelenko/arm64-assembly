.global _main
.align 2

helloworld: .ascii "hello world\n"


_main:
	mov x3, 0

loop:
	cmp x3, 5
	bge _terminate	

	// print "hello world"
	bl _printf

	// Increment X0
	add x3, x3, 1
	b loop


_terminate:
	mov x0, #0			// return 0
	mov x16, #1			// terminate
	svc 0				// syscall


_printf:
	mov x0, #1  		// stdou
	adr x1, helloworld  // address of hello world string
	mov x2, #12			// length of the hello world string
	mov x16, #4 		// write to stdout
	svc 0
	ret
