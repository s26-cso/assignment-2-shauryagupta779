.section .rodata
fmt_first:
	.string "%d"
fmt_next:
	.string " %d"

.text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $40, %rsp

	movq %rsi, %r15
	movl %edi, %r14d
	subl $1, %r14d

	cmpl $0, %r14d
	jg .alloc_arrays
	movl $10, %edi
	call putchar@PLT
	xorl %eax, %eax
	jmp .main_cleanup

.alloc_arrays:
	movslq %r14d, %rax
	shlq $2, %rax
	movq %rax, -16(%rbp)

	movq -16(%rbp), %rdi
	call malloc@PLT
	movq %rax, %rbx
	testq %rbx, %rbx
	jne .alloc_res
	movl $1, %eax
	jmp .main_cleanup

.alloc_res:
	movq -16(%rbp), %rdi
	call malloc@PLT
	movq %rax, %r12
	testq %r12, %r12
	jne .alloc_stack
	movq %rbx, %rdi
	call free@PLT
	movl $1, %eax
	jmp .main_cleanup

.alloc_stack:
	movq -16(%rbp), %rdi
	call malloc@PLT
	movq %rax, %r13
	testq %r13, %r13
	jne .init_and_parse
	movq %r12, %rdi
	call free@PLT
	movq %rbx, %rdi
	call free@PLT
	movl $1, %eax
	jmp .main_cleanup

.init_and_parse:
	movl $0, -4(%rbp)

.parse_loop:
	movl -4(%rbp), %eax
	cmpl %r14d, %eax
	jge .compute_nge

	cltq
	movq 8(%r15,%rax,8), %rdi
	call atoi@PLT

	movl -4(%rbp), %edx
	movslq %edx, %rdx
	movl %eax, (%rbx,%rdx,4)
	movl $-1, (%r12,%rdx,4)

	addl $1, -4(%rbp)
	jmp .parse_loop

.compute_nge:
	movl $-1, %r10d
	movl %r14d, %ecx
	subl $1, %ecx

.nge_outer:
	cmpl $0, %ecx
	jl .print_result

.nge_pop_loop:
	cmpl $0, %r10d
	jl .nge_use_stack

	movslq %r10d, %rax
	movl (%r13,%rax,4), %edx
	movslq %edx, %rdx
	movl (%rbx,%rdx,4), %edx
	movslq %ecx, %r8
	movl (%rbx,%r8,4), %r9d
	cmpl %r9d, %edx
	jg .nge_use_stack

	subl $1, %r10d
	jmp .nge_pop_loop

.nge_use_stack:
	movslq %ecx, %r8
	cmpl $0, %r10d
	jl .nge_store_stack

	movslq %r10d, %rax
	movl (%r13,%rax,4), %edx
	movl %edx, (%r12,%r8,4)

.nge_store_stack:
	addl $1, %r10d
	movslq %r10d, %rax
	movl %ecx, (%r13,%rax,4)

	subl $1, %ecx
	jmp .nge_outer

.print_result:
	movl $0, -4(%rbp)

.print_loop:
	movl -4(%rbp), %eax
	cmpl %r14d, %eax
	jge .print_newline

	movslq %eax, %rdx
	movl (%r12,%rdx,4), %esi
	testl %eax, %eax
	jne .print_with_space

	leaq fmt_first(%rip), %rdi
	xorl %eax, %eax
	call printf@PLT
	jmp .print_next_i

.print_with_space:
	leaq fmt_next(%rip), %rdi
	xorl %eax, %eax
	call printf@PLT

.print_next_i:
	addl $1, -4(%rbp)
	jmp .print_loop

.print_newline:
	movl $10, %edi
	call putchar@PLT

	movq %r13, %rdi
	call free@PLT
	movq %r12, %rdi
	call free@PLT
	movq %rbx, %rdi
	call free@PLT
	xorl %eax, %eax

.main_cleanup:
	addq $40, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	popq %rbp
	ret

.section .note.GNU-stack,"",@progbits
